{...}: {
  imports = [
    ../hw/hw-p71.nix
    # ../modules/backup.nix
    # ../modules/cuda.nix
    ../modules/cardano-node.nix
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
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/tailscale.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    # ../modules/wireguard.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  # networking.extraHosts = ''
  #   127.0.0.1 explorer.cardano.org
  # '';

  networking.hostId = "35c02924";

  system.nixos.tags = ["kde"];
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  networking.hostName = "nixos-p71";
  networking.wireless.interfaces = ["wlp4s0"];

  system.stateVersion = "22.11";
}
