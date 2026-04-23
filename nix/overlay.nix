self: final: prev: let
  nixpkgs-user = self.inputs.nixpkgs-user.legacyPackages.${prev.stdenv.hostPlatform.system};
in {
  inherit
    (nixpkgs-user)
    eternal-terminal
    ;

  # nixos-rebuild-ng generates _nixos-rebuild via installShellCompletion in postInstall,
  # colliding with nix-zsh-completions (added by programs.zsh.enableCompletion).
  # Remove the duplicate from nixos-rebuild-ng; nix-zsh-completions owns it.
  nixos-rebuild-ng = prev.nixos-rebuild-ng.overrideAttrs (old: {
    postInstall =
      old.postInstall
      + ''
        rm -f $out/share/zsh/site-functions/_nixos-rebuild
      '';
  });
}
