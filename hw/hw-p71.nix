{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [(self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];
  boot.blacklistedKernelModules = ["nouveau"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11.bin];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # RAID1 array configuration.  Generated after RAID creation with `mdadm --detail --scan`
  boot.initrd.services.swraid.mdadmConf = "ARRAY /dev/md0 metadata=1.2 name=nixos:0 UUID=c5cb0286:a9a92645:2a354d88:941aa36d";

  boot.initrd.luks.devices.cr0 = {
    device = "/dev/disk/by-uuid/a8b83540-8db1-4612-b75b-901718b34c5e";
    allowDiscards = true;
  };

  boot.initrd.luks.devices.cr1 = {
    device = "/dev/disk/by-uuid/5a321a3f-11b9-45b5-90e7-d1ebf12700d4";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot1";
    fsType = "vfat";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
  };

  swapDevices = [{device = "/dev/disk/by-label/swap";}];
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  sound.enable = true;
}
