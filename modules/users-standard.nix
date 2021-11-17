{ config, pkgs, secrets, ... }:
{
  users.mutableUsers = false;

  users.users."${secrets.priUsr}" = {
    isNormalUser = true;
    extraGroups = [ "docker" "lxd" "networkmanager" "scanner" "wheel" "vboxusers" "libvirtd" "plugdev" ];
    hashedPassword = secrets.hashedPassword;
    openssh.authorizedKeys.keys = secrets.sshAuthKey;
    shell = pkgs.bash;
  };

  users.users."${secrets.secUsr}" = {
    isNormalUser = true;
    extraGroups = [ "docker" "lxd" "networkmanager" "scanner" "wheel" "vboxusers" "libvirtd" "plugdev" ];
    hashedPassword = secrets.hashedPassword;
    openssh.authorizedKeys.keys = secrets.sshAuthKey;
    shell = pkgs.bash;
  };

  security.sudo.wheelNeedsPassword = true;
  users.groups.plugdev = { members = [ "${secrets.priUsr}" "${secrets.secUsr}" ]; };
}
