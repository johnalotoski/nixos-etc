{ config, pkgs, ... }:

{
  nix.binaryCaches = [ "https://hydra.iohk.io" "https://cache.nixos.org/" ];
  nix.binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  system.stateVersion = "19.03";
}
