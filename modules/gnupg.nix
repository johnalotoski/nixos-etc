{ config, pkgs, secrets, ... }:
{
  environment.systemPackages = with pkgs; [ gnupg pinentry gpgme.dev ];
  programs.gnupg.agent.enable = true;

  environment.etc."per-user/root/gpg-agent.conf".text = "allow-loopback-pinentry";
  environment.etc."per-user/root/gpg.conf".text = "pinentry-mode loopback";

  environment.etc."per-user/${secrets.priUsr}/gpg-agent.conf".text = "#pinentry-program /run/current-system/sw/bin/pinentry";
  environment.etc."per-user/${secrets.priUsr}/gpg.conf".text = ''
    default-key ${secrets.gpg.fp.pri}
    #default-key ${secrets.gpg.fp.sec}
  '';

  system.activationScripts.gnupg = let
    gpgmejsonFile = pkgs.writeText "gpgmejson.json" ''
      {
        "name": "gpgmejson",
        "description": "gpgme.js application for mailvelope",
        "path": "${pkgs.gpgme.dev}/bin/gpgme-json",
        "type": "stdio",
        "allowed_origins": ["chrome-extension://kajibbejlbohfaggdiogboambcijhkke/"]
      }
    '';
  in {
    text = ''
      mkdir -p /root/.gnupg
      [ -f /root/.gnupg/gpg-agent.conf ] || cp /etc/per-user/root/gpg-agent.conf /root/.gnupg/gpg-agent.conf
      [ -f /root/.gnupg/gpg.conf ] || cp /etc/per-user/root/gpg.conf /root/.gnupg/gpg.conf
      chmod 644 /root/.gnupg/*.conf
      chmod 0700 /root/.gnupg

      mkdir -p /home/${secrets.priUsr}/.gnupg
      [ -f /home/${secrets.priUsr}/.gnupg/gpg-agent.conf ] || cp /etc/per-user/${secrets.priUsr}/gpg-agent.conf /home/${secrets.priUsr}/.gnupg/gpg-agent.conf
      [ -f /home/${secrets.priUsr}/.gnupg/gpg.conf ] || cp /etc/per-user/${secrets.priUsr}/gpg.conf /home/${secrets.priUsr}/.gnupg/gpg.conf
      chown -R ${secrets.priUsr}:users /home/${secrets.priUsr}/.gnupg
      chmod 644 /home/${secrets.priUsr}/.gnupg/*.conf
      chmod 0700 /home/${secrets.priUsr}/.gnupg

      mkdir -p /home/${secrets.priUsr}/.config/google-chrome/NativeMessagingHosts
      [ -e /home/${secrets.priUsr}/.config/google-chrome/NativeMessagingHosts/gpgmejson.json ] || \
        ln -s ${gpgmejsonFile} /home/${secrets.priUsr}/.config/google-chrome/NativeMessagingHosts/gpgmejson.json
      chown -R ${secrets.priUsr}:users /home/${secrets.priUsr}/.config/google-chrome
    '';
    deps = [];
  };
}
