{
  self,
  pkgs,
  lib,
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

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = ["nodev"];
        gfxmodeEfi = "1280x1024";
        mirroredBoots = [
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
      systemd-boot.enable = false;
    };
  };

  # From machine eval:
  #   You must configure `hardware.nvidia.open` on NVIDIA driver versions >= 560.
  #   It is suggested to use the open source kernel modules on Turing or later GPUs (RTX series, GTX 16xx), and the closed source modules otherwise.
  hardware.nvidia.open = false;
}
