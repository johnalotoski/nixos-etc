{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (self.inputs.disko.nixosModules.disko)
    (import ./disko-config-p71.nix {})
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];
  boot.blacklistedKernelModules = ["nouveau"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11.bin];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  sound.enable = true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
