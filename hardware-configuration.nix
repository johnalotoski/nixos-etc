{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "nvme" "sd_mod" "sr_mod" ];

  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  nix.maxJobs = lib.mkDefault 2;
  virtualisation.virtualbox.guest.enable = true;
}
