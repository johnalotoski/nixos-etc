{
  config,
  pkgs,
  ...
}:
with pkgs; let
  gpg-pin = writeShellApplication {
    name = "gpg-pin";
    runtimeInputs = [coreutils gnupg];
    text = ''
      SERIAL=$(gpg-connect-agent 'scd serialno' /bye | head -n 1 | cut -f3 -d' ')
      gpg-connect-agent "scd checkpin $SERIAL" /bye
    '';
  };

  gpg-reload = writeShellApplication {
    name = "gpg-reload";
    runtimeInputs = [coreutils gnupg];
    text = ''
      gpg-connect-agent reloadagent /bye
    '';
  };

  gpg-ssh = writeShellApplication {
    name = "gpg-ssh";
    runtimeInputs = [coreutils gnupg openssh];
    text = ''
      echo "Ssh keys currently added:"
      ssh-add -l
      echo
      echo "Ssh public keys currently added:"
      ssh-add -L
      echo
      echo "Testing connection to github:"
      ssh git@github.com
    '';
  };

  gpg-stop = writeShellApplication {
    name = "gpg-stop";
    runtimeInputs = [bash findutils procps sudo];
    text = ''
      # For sudo security wrapper
      export PATH=/run/wrappers/bin/:$PATH

      sudo bash -c 'pgrep gpg-agent | xargs kill -9'
    '';
  };

  gpg-switch = writeShellApplication {
    name = "gpg-switch";
    runtimeInputs = [bash findutils gnupg gpg-stop procps sudo];
    text = ''
      gpg-stop
      gpg --card-status
    '';
  };

  gpg-test = writeShellApplication {
    name = "gpg-test";
    runtimeInputs = [coreutils gnupg];
    text = ''
      echo "Test sign" | gpg --clearsign
    '';
  };

  gpg-tty = writeShellApplication {
    name = "gpg-tty";
    runtimeInputs = [coreutils gnupg];
    text = ''
      # Checks tty for pinentry ownership requirement
      # Ref: https://wiki.archlinux.org/title/GnuPG#su
      USER=$(whoami)
      TTY_OWNER=$(stat -c "%U" "$(tty)")
      if [ "$USER" = "$TTY_OWNER" ]; then
        echo "Ok: user $USER owns the current tty: $(tty)"
      else
        echo "Error: user $USER does not own the current tty: $(tty)"
      fi
      ls -la "$(tty)"
    '';
  };

  scdaemonConf = ''
    # Uncomment below to allow non-exclusive smartcard sharing
    # This will allow yubikey re-use across multiple users but will also prompt for unlock on every use
    # Ref: https://wiki.archlinux.org/title/GnuPG#GnuPG_with_pcscd_(PCSC_Lite)
    #
    # pcsc-driver ${pcsclite.out}/lib/libpcsclite.so
    # card-timeout 5
    # disable-ccid
    # pcsc-shared
  '';

  defaultGpgKey = "0AE060E71E81FA38";
in {
  environment.systemPackages = [
    gnupg
    pinentry
    gpg-pin
    gpg-reload
    gpg-ssh
    gpg-stop
    gpg-switch
    gpg-test
    gpg-tty
    gpgme.dev
  ];

  programs.gnupg.agent.enable = true;

  environment.etc."per-user/root/gpg-agent.conf".text = ''
    pinentry-program ${pinentry.tty}/bin/pinentry-tty
    enable-ssh-support
  '';
  environment.etc."per-user/root/gpg.conf".text = "default-key ${defaultGpgKey}";
  environment.etc."per-user/root/scdaemon.conf".text = scdaemonConf;

  environment.etc."per-user/jlotoski/gpg-agent.conf".text = ''
    # pinentry-program ${pinentry}/bin/pinentry
    enable-ssh-support
  '';
  environment.etc."per-user/jlotoski/gpg.conf".text = "default-key ${defaultGpgKey}";
  environment.etc."per-user/jlotoski/scdaemon.conf".text = scdaemonConf;

  system.activationScripts.gnupg.text = let
    gpgmeDir = ".config/google-chrome/NativeMessagingHosts";
    gpgmejsonFile = writeText "gpgmejson.json" ''
      {
        "name": "gpgmejson",
        "description": "gpgme.js application for mailvelope",
        "path": "${gpgme.dev}/bin/gpgme-json",
        "type": "stdio",
        "allowed_origins": ["chrome-extension://kajibbejlbohfaggdiogboambcijhkke/"]
      }
    '';
    homeDir = user: config.users.users.${user}.home;
  in ''
    setupUserConfig () {
      USER="$1"
      GROUP="$2"
      HOME="$3"
      mkdir -p "$HOME/.gnupg"
      ln -svfn "/etc/per-user/$USER/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
      ln -svfn "/etc/per-user/$USER/gpg.conf" "$HOME/.gnupg/gpg.conf"
      ln -svfn "/etc/per-user/$USER/scdaemon.conf" "$HOME/.gnupg/scdaemon.conf"

      mkdir -p "$HOME/${gpgmeDir}"
      ln -svfn ${gpgmejsonFile} "$HOME/${gpgmeDir}/gpgmejson.json"
    }

    setupUserConfig "root" "root" "${homeDir "root"}"
    setupUserConfig "jlotoski" "users" "${homeDir "jlotoski"}"
  '';
}
