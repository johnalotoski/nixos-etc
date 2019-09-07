{ config, pkgs, ... }:
let
  secrets = import ../secrets/secrets.nix;
in {
  environment.etc."per-user/${secrets.priUsr}/gitconfig-w".text = import ../dotfiles/gitconfig-w.nix;
  environment.etc."per-user/${secrets.priUsr}/gitconfig-p".text = import ../dotfiles/gitconfig-p.nix;
  environment.etc."per-user/root/gitconfig-p".text = import ../dotfiles/gitconfig-p.nix;
  environment.etc."per-user/${secrets.priUsr}/gitconfig-wo".text = import ../dotfiles/gitconfig-wo.nix;
  environment.etc."per-user/${secrets.priUsr}/gitconfig-po".text = import ../dotfiles/gitconfig-po.nix;
  environment.etc."per-user/${secrets.priUsr}/gitignore".text = import ../dotfiles/gitignore.nix;
  environment.etc."per-user/root/gitignore".text = import ../dotfiles/gitignore.nix;

  system.activationScripts.gitconfig = {
    text = ''
      ln -sfn /etc/per-user/${secrets.priUsr}/gitconfig-w /home/${secrets.priUsr}/.gitconfig;
      ln -sfn /etc/per-user/${secrets.priUsr}/gitignore /home/${secrets.priUsr}/.gitignore;
      ln -sfn /etc/per-user/root/gitconfig-p /root/.gitconfig;
      ln -sfn /etc/per-user/root/gitignore /root/.gitignore;
    '';
    deps = [];
  };
}
