{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../hw/hw-serval.nix
    # ../modules/backup.nix
    # ../modules/cardano-node.nix
    # ../modules/cuda.nix
    ../modules/db.nix
    # ../modules/fax.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hp-envy-5000-aio.nix
    ../modules/hw.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    # ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/nvidia-fix.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/sops.nix
    ../modules/system-packages.nix
    ../modules/tailscale.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "wlp0s20f3";
  };

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  services.xserver = {
    exportConfiguration = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [libGL];
    setLdLibraryPath = true;
  };

  hardware.pulseaudio = {
    support32Bit = true;
    extraConfig = ''
      load-module module-card-restore restore_bluetooth_profile=true
      load-module module-bluetooth-policy auto_switch=false
      load-module module-bluetooth-discover headset=auto
    '';
  };

  networking.hostName = "nixos-serval";
  networking.hostId = "d8fcf199";
  networking.wireless.interfaces = ["wlp0s20f3"];

  system.stateVersion = "23.05";
}
