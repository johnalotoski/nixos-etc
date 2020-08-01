{ config, pkgs, ... }:
{
  imports = [
    ../hw/hw-g76.nix
    ../modules/backup.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    ../modules/modargs.nix
    ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.xserver.videoDrivers = [ "intel" ];
  #hardware.nvidia.prime.offload.enable = true;
  #hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  #hardware.nvidia.prime.intelBusId = "PCI:0:2:0";

  networking.hostName = "nixos-g76";
  networking.hostId = "defe72a9";
  networking.wireless.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp8s0f1.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
}
