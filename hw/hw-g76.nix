{self, ...}: {
  imports = [
    (self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (self.inputs.disko.nixosModules.disko)
    (import ./disko-config-g76.nix {})
  ];

  boot = {
    # Auto-generated during the initial nixos install via nixos-generate-config -> hardware-configuration.nix
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];

    loader.grub.mirroredBoots = [
      {
        devices = ["/dev/disk/by-partlabel/disk-main-esp"];
        path = "/boot";
      }
      {
        devices = ["/dev/disk/by-partlabel/disk-storage-recovery"];
        path = "/recovery";
      }
    ];
  };

  hardware = {
    nvidia = {
      # From machine eval:
      #   You must configure `hardware.nvidia.open` on NVIDIA driver versions >= 560.
      #   It is suggested to use the open source kernel modules on Turing or later GPUs (RTX series, GTX 16xx), and the closed source modules otherwise.
      open = true;

      prime = {
        sync.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };

    system76.enableAll = true;
  };
}
