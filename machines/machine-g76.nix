{config, ...}: {
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

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = ["i8042.direct" "i8042.dumbkbd"];

  services.xserver = {
    exportConfiguration = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  networking = {
    hostId = "defe72a9";
    hostName = "nixos-g76";
    nat.externalInterface = "wlp0s20f3";
    wireless.interfaces = ["wlp0s20f3" "wifi-tplink"];
  };

  system.stateVersion = "22.11";
}
