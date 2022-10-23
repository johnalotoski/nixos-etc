{ config, pkgs, ... }:
{
  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services.udev.extraRules = let
    dependencies = with pkgs; [ coreutils gnupg gawk gnugrep ];
    clearYubikey = pkgs.writeScript "clear-yubikey" ''
      #!${pkgs.stdenv.shell}
      export PATH=${pkgs.lib.makeBinPath dependencies};
      keygrips=$(
        gpg-connect-agent 'keyinfo --list' /bye 2>/dev/null \
          | grep -v OK \
          | awk '{if ($4 == "T") { print $3 ".key" }}')
      for f in $keygrips; do
        rm -v ~/.gnupg/private-keys-v1.d/$f
      done
      gpg --card-status 2>/dev/null 1>/dev/null || true
    '';
    clearYubikeyUser = pkgs.writeScript "clear-yubikey-user" ''
      #!${pkgs.stdenv.shell}
      ${pkgs.sudo}/bin/sudo -u jlotoski ${clearYubikey}
    '';
  in ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", RUN+="${clearYubikeyUser}"
  '';

  services.udev.packages = [ pkgs.yubikey-personalization ];

  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry
    paperkey
    yubioath-desktop
    yubikey-manager
  ];

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    # If root, own the tty to allow gpg pinentry
    # Ref: https://wiki.archlinux.org/title/GnuPG#su
    if [ "$UID" = "0" ]; then
      # Ref: https://wiki.archlinux.org/title/GnuPG#su
      echo "Chowning tty $GPG_TTY as root for gpg pinentry"
      chown root "$GPG_TTY"
    fi
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  '';
}
