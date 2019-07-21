{ config, pkgs, ... }:

{
  imports = [
    ../hw/hw-p71.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hidpi.nix
    ../modules/iohk-csl-nginx.nix
    ../modules/intl.nix
    ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/sarov.nix
    ../modules/scanner-brotherDSSeries.nix
    ../modules/services-luksClose.nix
    ../modules/services-raid.nix
    ../modules/services-standard.nix
    ../modules/services-toxvpn.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
  ];

  system.nixos.tags = [ "kde" ];
  networking.hostName = "nixos-p71";
  services.xserver.videoDrivers = [ "intel" "nvidia" ];

  users.users.jlotoski.shell = pkgs.lib.mkForce pkgs.bash;
}
