{...}: {
  imports = [
    ../hw/hw-p71.nix
    # ../modules/backup.nix
    # ../modules/cuda.nix
    ../modules/db.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hidpi.nix
    ../modules/hw.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    # ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/screen.nix
    ../modules/services-raid.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    # ../modules/wireguard.nix
    ../modules/xrandr.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  system.nixos.tags = ["kde"];
  services.xserver.videoDrivers = ["intel" "nvidia"];

  services.resolved.enable = true;

  networking.hostName = "nixos-p71";
  networking.wireless.enable = true;
  networking.wireless.interfaces = ["wlp4s0"];

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  system.stateVersion = "22.05";
}
