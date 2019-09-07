{ config, pkgs, ... }:
let
  secrets = import ../secrets/secrets.nix;
in {
  nix.binaryCaches = [ "https://hydra.iohk.io" "https://cache.nixos.org/" ];
  nix.binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  nix.trustedUsers = [ "root" "${secrets.priUsr}" ];
  system.stateVersion = "19.03";
}
