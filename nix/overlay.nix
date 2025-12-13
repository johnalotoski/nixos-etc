self: final: prev: let
  nixpkgs-user = self.inputs.nixpkgs-user.legacyPackages.${prev.stdenv.hostPlatform.system};
in {
  inherit
    (nixpkgs-user)
    eternal-terminal
    ;
}
