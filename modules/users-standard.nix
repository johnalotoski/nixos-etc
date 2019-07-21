{ config, pkgs, ... }:
let
  secrets = import ../secrets/secrets.nix;
in {
  users.mutableUsers = false;

  users.users.jlotoski = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "scanner" "wheel" "vboxusers" ];
    hashedPassword = secrets.hashedPassword;
    openssh.authorizedKeys.keys = [ secrets.sshAuthKey ];
    shell = pkgs.zsh;
  };

  users.users.backup = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "scanner" "wheel" "vboxusers" ];
    hashedPassword = secrets.hashedPassword;
    openssh.authorizedKeys.keys = [ secrets.sshAuthKey ];
  };

  security.sudo.wheelNeedsPassword = true;
}
