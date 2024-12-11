{
  self,
  config,
  lib,
  ...
}: {
  imports = [
    (self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (self.inputs.disko.nixosModules.disko)
    (import ./disko-config-serval.nix {})
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["intel_idle.max_cstate=1"];
  boot.extraModulePackages = [];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "conservative";

  hardware.system76.enableAll = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
