{lib, ...}: {
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.cr0 = {
    device = "/dev/disk/by-uuid/a0b9d5cc-5cdb-42ba-aa4b-c0a6e9c83ac1";
    allowDiscards = true;
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

  hardware.bluetooth.enable = true;
  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
