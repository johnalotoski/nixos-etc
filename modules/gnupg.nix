{ config, pkgs, secrets, ... }:
{
  environment.systemPackages = with pkgs; [ gnupg pinentry gpgme.dev ];
  programs.gnupg.agent.enable = true;

  environment.etc."per-user/${secrets.priUsr}/gpg-agent.conf".text = "#pinentry-program /run/current-system/sw/bin/pinentry-curses";
  environment.etc."per-user/${secrets.priUsr}/gpg.conf".text = ''
    default-key ${secrets.gpg.fp.pri}
    #default-key ${secrets.gpg.fp.sec}
  '';
  environment.etc."per-user/root/gpg-agent.conf".text = "allow-loopback-pinentry";
  environment.etc."per-user/root/gpg.conf".text = "pinentry-mode loopback";

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
      mkdir -p {/home/${secrets.priUsr},/root}/.gnupg ${secrets.priUsr}/.config/google-chrome/NativeMessagingHosts
      [ -f /home/${secrets.priUsr}/.gnupg/gpg-agent.conf ] || cp /etc/per-user/${secrets.priUsr}/gpg-agent.conf /home/${secrets.priUsr}/.gnupg/gpg-agent.conf
      [ -f /home/${secrets.priUsr}/.gnupg/gpg.conf ] || cp /etc/per-user/${secrets.priUsr}/gpg.conf /home/${secrets.priUsr}/.gnupg/gpg.conf
      [ -f /root/.gnupg/gpg-agent.conf ] || cp /etc/per-user/root/gpg-agent.conf /root/.gnupg/gpg-agent.conf
      [ -f /root/.gnupg/gpg.conf ] || cp /etc/per-user/root/gpg.conf /root/.gnupg/gpg.conf
      [ -f /home/${secrets.priUsr}/.config/google-chrome/NativeMessagingHosts/gpgmejson.json ] || \
        ln -s ${gpgmejsonFile} /home/${secrets.priUsr}/.config/google-chrome/NativeMessagingHosts/gpgmejson.json
      chown -R ${secrets.priUsr}:users /home/${secrets.priUsr}/{.gnupg,.config/google-chrome/NativeMessagingHosts}
      chmod 644 {/home/${secrets.priUsr},/root}/.gnupg/*.conf
    '';
    deps = [];
  };
}
