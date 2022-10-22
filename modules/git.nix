{ config, pkgs, lib, secrets, ... }:
let
  inherit (lib) pipe recursiveUpdate;
in {
  environment.etc = let
    mkImport = user: file: {"per-user/${user}/${file}".text = import ../dotfiles/${file}.nix;};
  in lib.pipe {} [
    (recursiveUpdate (mkImport secrets.priUsr "gitconfig-w"))
    (recursiveUpdate (mkImport secrets.priUsr "gitconfig-p"))
    (recursiveUpdate (mkImport secrets.priUsr "gitconfig-wo"))
    (recursiveUpdate (mkImport secrets.priUsr "gitconfig-po"))
    (recursiveUpdate (mkImport secrets.priUsr "gitignore"))
    (recursiveUpdate (mkImport "root" "gitconfig-p"))
    (recursiveUpdate (mkImport "root" "gitignore"))
  ];

  system.activationScripts.gitconfig = {
    text = ''
      ln -svfn /etc/per-user/${secrets.priUsr}/gitconfig-w /home/${secrets.priUsr}/.gitconfig;
      ln -svfn /etc/per-user/${secrets.priUsr}/gitignore /home/${secrets.priUsr}/.gitignore;
      ln -svfn /etc/per-user/root/gitconfig-p /root/.gitconfig;
      ln -svfn /etc/per-user/root/gitignore /root/.gitignore;
    '';
    deps = [];
  };
}
