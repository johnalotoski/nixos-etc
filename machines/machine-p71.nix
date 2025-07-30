{...}: {
  imports = [
    ../hw/hw-p71.nix
    ../modules/common.nix
    ../modules/distributed-builds.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hidpi.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/yubikey.nix
  ];

  networking = {
    hostId = "35c02924";
    hostName = "nixos-p71";
    nat.externalInterface = "wlp4s0";
    wireless.interfaces = ["wlp4s0" "wifi-tplink"];
  };

  system.stateVersion = "22.11";
}
