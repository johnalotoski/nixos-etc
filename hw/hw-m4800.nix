{self, ...}: {
  imports = [
    (self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
  ];

  boot = {
    # Auto-generated during the initial nixos install via nixos-generate-config -> hardware-configuration.nix
    initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci"];

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = ["nodev"];
        gfxmodeEfi = "1280x1024";
      };
      systemd-boot.enable = false;
    };

    initrd.luks.devices.cr0 = {
      device = "/dev/disk/by-uuid/a0b9d5cc-5cdb-42ba-aa4b-c0a6e9c83ac1";
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot1";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-label/swap";}];
}
