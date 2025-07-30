{
  self,
  pkgs,
  ...
}: let
  inherit (pkgs) writeShellApplication;
  inherit (pkgs.lib) mkForce;

  bootstrap-help = writeShellApplication {
    name = "bootstrap-help";
    text = ''
      echo "# Find zfs devices:"
      echo "sudo zpool import"
      echo
      echo "# Import specific zfs device:"
      echo "sudo zpool import \$POOL"
      echo
      echo "# Apply zfs encryption key:"
      echo "sudo zfs load-key \$POOL"
      echo
      echo "# Mount the decrypted zfs pool:"
      echo "sudo zfs mount \$POOL"
      echo
      echo "# Unmount the decrypted zfs pool:"
      echo "sudo zfs unmount \$POOL"
      echo
      echo "# Export the zfs pool:"
      echo "sudo zpool export \$POOL"
    '';
  };
in
  with pkgs; {
    imports = [(self.inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix")];

    boot.supportedFilesystems = ["zfs"];
    boot.kernelParams = ["console=ttyS0,115200n8"];

    nixpkgs.config.allowUnfree = true;

    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    environment.systemPackages = [
      bootstrap-help
      curl
      file
      gnupg
      openssl
      paperkey
      pinentry
      pv
      (unixtools.xxd)
      wget
    ];

    services = {
      openssh.enable = mkForce false;
      pcscd.enable = true;
      udev.packages = [yubikey-personalization];
    };
  }
