{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../hw/hw-g76.nix
    # ../modules/backup.nix
    ../modules/cardano-node.nix
    # ../modules/cuda.nix
    ../modules/db.nix
    # ../modules/fax.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
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
  boot.kernelParams = ["i8042.direct" "i8042.dumbkbd"];

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
  hardware.pulseaudio.support32Bit = true;

  networking.hostName = "nixos-g76";
  networking.hostId = "defe72a9";
  networking.wireless.interfaces = ["wlp0s20f3"];

  system.stateVersion = "22.11";
}
