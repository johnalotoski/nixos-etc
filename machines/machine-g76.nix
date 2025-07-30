{config, ...}: {
  imports = [
    ../hw/hw-g76.nix
    # ../modules/backup.nix
    ../modules/cardano-node.nix
    # ../modules/cuda.nix
    ../modules/db.nix
    # ../modules/fax.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hw.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    # ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/nvidia-fix.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/sops.nix
    ../modules/system-packages.nix
    ../modules/tailscale.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
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
