{ config, pkgs, lib, secrets, ... }:
let
  unstable = import <nixpkgsunstable> {
    config.allowUnfree = true;
  };
  nixSrc = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nix";
    rev = "2.11.1";
    sha256 = "sha256-qCV65kw09AG+EkdchDPq7RoeBznX0Q6Qa4yzPqobdOk=";
  };
in {
  nix.package = (import nixSrc).packages.${pkgs.system}.nix;
  nix.sandboxPaths = [
    "/etc/skopeo/auth.json=/etc/nix/skopeo/auth.json"
  ];
  nix.binaryCaches = [
    "https://cache.iog.io"
    # "https://hydra.iohk.io"
    # "https://cache.nixos.org/"
    # "https://johnalotoski.cachix.org"
  ];
  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    # "johnalotoski.cachix.org-1:TG39n8kXcHfU9o2aMvxVwy4+NDKswAu/7/jiJuNV5iM="
  ];
  nix.trustedUsers = [ "root" "${secrets.priUsr}" ];
  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
    experimental-features = nix-command flakes
  '';
}
