{ config, pkgs, ... }:

{
  environment.etc."per-user/jlotoski/gitconfig-w".text = import ../dotfiles/gitconfig-w.nix;
  environment.etc."per-user/jlotoski/gitconfig-p".text = import ../dotfiles/gitconfig-p.nix;
  environment.etc."per-user/jlotoski/gitconfig-wo".text = import ../dotfiles/gitconfig-wo.nix;
  environment.etc."per-user/jlotoski/gitconfig-po".text = import ../dotfiles/gitconfig-po.nix;
  environment.etc."per-user/jlotoski/gitignore".text = import ../dotfiles/gitignore.nix;

  system.activationScripts.dotfiles = {
    text = ''
      ln -sfn /etc/per-user/jlotoski/gitconfig-w /home/jlotoski/.gitconfig;
      ln -sfn /etc/per-user/jlotoski/gitignore /home/jlotoski/.gitignore;
      ln -sfn /etc/per-user/jlotoski/gitconfig-p /root/.gitconfig;
      ln -sfn /etc/per-user/jlotoski/gitignore /root/.gitignore;
    '';
    deps = [];
  };
}