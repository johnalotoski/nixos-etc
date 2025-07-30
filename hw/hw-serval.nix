{self, ...}: {
  imports = [
    (self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (self.inputs.disko.nixosModules.disko)
    (import ./disko-config-serval.nix {})
  ];

  boot = {
    # Auto-generated during the initial nixos install via nixos-generate-config -> hardware-configuration.nix
    initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci"];

    # Prevents power state related system freezes
    kernelParams = ["intel_idle.max_cstate=1"];

    loader.grub.mirroredBoots = [
      {
        devices = ["/dev/disk/by-partlabel/disk-zroot1-esp"];
        path = "/boot";
      }
      {
        devices = ["/dev/disk/by-partlabel/disk-zroot2-recovery"];
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
