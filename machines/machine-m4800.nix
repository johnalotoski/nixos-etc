{ config, pkgs, ... }:

{
  imports = [
    ../hw/hw-m4800.nix
    ../modules/backup.nix
    ../modules/firewall.nix
    ../modules/flatpak.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    ../modules/modargs.nix
    ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/services-standard.nix
    ../modules/screen.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/vim.nix
    ../modules/virtualization.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  system.nixos.tags = [ "kde" ];
  networking.hostName = "nixos-m4800";
  services.xserver.videoDrivers = [ "nvidia" ];
}
