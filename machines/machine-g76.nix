{...}: {
  imports = [
    ../hw/hw-g76.nix
    ../modules/common.nix
    ../modules/distributed-builds.nix
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
    hostId = "d4a77fc1";
    hostName = "nixos-g76";
    nat.externalInterface = "wlp0s20f3";
    wireless.interfaces = ["wlp0s20f3" "wifi-tplink"];
  };

  system.stateVersion = "25.05";
}
