{ config, pkgs, secrets, ... }:
{
  users.mutableUsers = false;

  users.users."${secrets.priUsr}" = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "scanner" "wheel" "vboxusers" ];
    hashedPassword = secrets.hashedPassword;
    openssh.authorizedKeys.keys = secrets.sshAuthKey;
    shell = pkgs.bash;
  };

  users.users."${secrets.secUsr}" = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "scanner" "wheel" "vboxusers" ];
    hashedPassword = secrets.hashedPassword;
    openssh.authorizedKeys.keys = secrets.sshAuthKey;
  };

  security.sudo.wheelNeedsPassword = true;
}
