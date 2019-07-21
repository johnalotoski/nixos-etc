{ config, pkgs, ... }:

{
  imports = [
    ../hw/hw-m4800.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/firewall.nix
    ../modules/intl.nix
    ../modules/networking.nix
    ../modules/nas.nix
    ../modules/nix.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/vim.nix
    ../modules/virtualization.nix
  ];

  system.nixos.tags = [ "kde" ];
  networking.hostName = "nixos-m4800";
  services.xserver.videoDrivers = [ "nvidia" ];
}
