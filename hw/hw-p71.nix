{
  config,
  self,
  ...
}: {
  imports = [
    (self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (self.inputs.disko.nixosModules.disko)
    (import ./disko-config-p71.nix {})
  ];

  boot = {
    # Auto-generated during the initial nixos install via nixos-generate-config -> hardware-configuration.nix
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];

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

  # From machine eval:
  #   You must configure `hardware.nvidia.open` on NVIDIA driver versions >= 560.
  #   It is suggested to use the open source kernel modules on Turing or later GPUs (RTX series, GTX 16xx), and the closed source modules otherwise.
  hardware.nvidia.open = false;

  # The Quadro P3000 Mobile (GP104, Pascal) was dropped from NVIDIA's driver
  # after the 580 series; the nixos-26.05 default (>= 595) no longer probes the
  # GPU, leaving the machine on simpledrm with no external outputs.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
}
