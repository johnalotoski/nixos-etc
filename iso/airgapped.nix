{
  self,
  pkgs,
  ...
}: let
  inherit (pkgs) writeShellApplication;
  inherit (pkgs.lib) mkForce;
  selfPath = self.inputs.nixpkgs.outPath;

  airgapped-help = writeShellApplication {
    name = "airgapped-help";
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
    imports = [(selfPath + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix")];

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
      airgapped-help # Reminder commands for secure ZFS import/export
      curl
      file
      gnupg # GNU Privacy Guard
      openssl # Avoid pattern based encryption attacks
      paperkey # Store OpenPGP or GnuPG on paper
      pinentry # GnuPG’s interface to passphrase input
      pv # For monitoring data progress through a pipeline
      (unixtools.xxd) # For checking block device writes
      wget
    ];

    services = {
      openssh.enable = mkForce false;
      pcscd.enable = true;
      udev.packages = [yubikey-personalization];
    };
  }
