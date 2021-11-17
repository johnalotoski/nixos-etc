{ config, pkgs, ... }:
{
  imports = [
    ../hw/hw-p71.nix
    ../modules/backup.nix
    ../modules/cuda.nix
    ../modules/db.nix
    ../modules/ddclient.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hidpi.nix
    ../modules/hw.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    ../modules/modargs.nix
    ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/screen.nix
    ../modules/services-luksClose.nix
    ../modules/services-raid.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    ../modules/wireguard.nix
    ../modules/xrandr.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  networking.wireless.interfaces = [ "wlp4s0" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;


  system.nixos.tags = [ "kde" ];
  networking.hostName = "nixos-p71";
  services.xserver.videoDrivers = [ "intel" "nvidia" ];

  networking.wireless.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;
}
