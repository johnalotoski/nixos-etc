{...}: {
  imports = [
    ../hw/hw-serval.nix
    ../modules/common.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/yubikey.nix
  ];

  networking = {
    hostId = "d8fcf199";
    hostName = "nixos-serval";
    nat.externalInterface = "wlp0s20f3";
    wireless.interfaces = ["wlp0s20f3" "wifi-tplink"];
  };

  system.stateVersion = "23.05";
}
