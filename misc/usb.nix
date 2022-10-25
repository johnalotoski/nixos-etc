{
  nixpkgs ? <nixpkgs>,
  system ? "x86_64-linux",
}: let
  config = {pkgs, ...}: {
    imports = [<nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-kde.nix>];
    boot.supportedFilesystems = ["zfs"];
    boot.kernelParams = ["console=ttyS0,115200n8"];
    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    services.pcscd.enable = true;
    services.udev.packages = [pkgs.yubikey-personalization];
    environment.systemPackages = with pkgs; [
      curl
      gnupg # GNU Privacy Guard
      openssl # Avoid pattern based encryption attacks
      paperkey # Store OpenPGP or GnuPG on paper
      pinentry_ncurses # GnuPG’s interface to passphrase input, ncurses
      pinentry_qt5 # GnuPG's interface to passphrase input, qt5
      pv # For monitoring data progress through a pipeline
      (unixtools.xxd) # For checking block device writes
      wget
    ];
    nixpkgs.config.allowUnfree = true;
    services.openssh.enable = pkgs.lib.mkForce false;
  };
  evalNixos = configuration:
    import <nixpkgs/nixos> {
      inherit system configuration;
    };
in {
  iso = (evalNixos config).config.system.build.isoImage;
}
