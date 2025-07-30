{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) pipe recursiveUpdate;
in {
  programs.bash.interactiveShellInit = ''
    if [ "$USER" != "builder" ]; then
      source "${pkgs.gitFull}/share/bash-completion/completions/git"
    fi
  '';

  environment = {
    etc = let
      mkImport = user: file: {"per-user/${user}/${file}".text = import (./. + "/../dotfiles/${file}.nix");};
    in
      pipe {} [
        (recursiveUpdate (mkImport "jlotoski" "gitconfig-w"))
        (recursiveUpdate (mkImport "jlotoski" "gitconfig-p"))
        (recursiveUpdate (mkImport "jlotoski" "gitconfig-wo"))
        (recursiveUpdate (mkImport "jlotoski" "gitconfig-po"))
        (recursiveUpdate (mkImport "jlotoski" "gitignore"))
        (recursiveUpdate (mkImport "root" "gitconfig-p"))
        (recursiveUpdate (mkImport "root" "gitignore"))
      ];
  };

  system.activationScripts.gitconfig.text = ''
    ln -svfn /etc/per-user/jlotoski/gitconfig-w /home/jlotoski/.gitconfig;
    ln -svfn /etc/per-user/jlotoski/gitignore /home/jlotoski/.gitignore;
    ln -svfn /etc/per-user/root/gitconfig-p /root/.gitconfig;
    ln -svfn /etc/per-user/root/gitignore /root/.gitignore;
  '';
}
