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
    (import ./disko-config-serval.nix {})
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  powerManagement.cpuFreqGovernor = lib.mkDefault "conservative";
  sound.enable = true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
