self: final: prev: let
  unstablePkgs = self.inputs.nixos-unstable.legacyPackages.${prev.system};
in {
  inherit
    (unstablePkgs)
    eternal-terminal
    ;

  # Until flake compat is fixed: https://github.com/NixOS/nixpkgs/issues/97855
  nixos-option = let
    prefix = ''(import ${self.inputs.flake-compat} { src = /etc/nixos; }).defaultNix.nixosConfigurations.\$(hostname)'';
  in
    prev.runCommandNoCC "nixos-option" {buildInputs = [prev.makeWrapper];} ''
      makeWrapper ${prev.nixos-option}/bin/nixos-option $out/bin/nixos-option \
        --add-flags --config_expr \
        --add-flags "\"${prefix}.config\"" \
        --add-flags --options_expr \
        --add-flags "\"${prefix}.options\""
    '';
}
