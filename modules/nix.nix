{ config, pkgs, secrets, ... }:
{
  nix.package = pkgs.nixFlakes;
  nix.binaryCaches = [
    "https://hydra.iohk.io"
    "https://cache.nixos.org/"
    "https://johnalotoski.cachix.org"
  ];
  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "johnalotoski.cachix.org-1:TG39n8kXcHfU9o2aMvxVwy4+NDKswAu/7/jiJuNV5iM="
  ];
  nix.trustedUsers = [ "root" "${secrets.priUsr}" ];
  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
    experimental-features = nix-command flakes
  '';
  system.stateVersion = "20.09";
}
