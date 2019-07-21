{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11.bin ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Required for the LUKS key volume to mount to the loopback device during boot.
  boot.initrd.kernelModules = [ "loop" ];

  # RAID1 array configuration.  Generated after RAID creation with `mdadm --detail --scan`
  boot.initrd.mdadmConf = "ARRAY /dev/md0 metadata=1.2 name=nixos:0 UUID=c5cb0286:a9a92645:2a354d88:941aa36d";

  # Append the LUKS key image to initrd.  The nix anti-quoting in the statement below
  # of ${ ... } and enclosed in double quotes is important to make this work.
  boot.initrd.prepend = ["${/boot/lk0.img.cpio.gz}"];

  # Unlock the main LUKS image key on boot to enable a single password prompt boot up.
  # Even though the image name is 'lk0.img', the LUKS image is mapped as '0lk' to ensure
  # it is opened as the first LUKS device to then be used as the key for other LUKS devices
  # Also, even though this file was created at /boot/lk0.img, the path during boot is
  # relative to only the mounted boot partition at /.
  boot.initrd.luks.devices."0lk" = { device = "/lk0.img"; };
  boot.initrd.luks.devices.cr0 = {
    device = "/dev/disk/by-uuid/a8b83540-8db1-4612-b75b-901718b34c5e";
    allowDiscards = true;
    keyFile = "/dev/mapper/0lk";
    fallbackToPassword = true;
  };
  boot.initrd.luks.devices.cr1 = {
    device = "/dev/disk/by-uuid/5a321a3f-11b9-45b5-90e7-d1ebf12700d4";
    keyFile = "/dev/mapper/0lk";
    fallbackToPassword = true;
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
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
