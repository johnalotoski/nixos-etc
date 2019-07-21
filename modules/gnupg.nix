{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gnupg pinentry ];
  programs.gnupg.agent.enable = true;

  environment.etc."per-user/jlotoski/gpg-agent.conf".text = "pinentry-program /run/current-system/sw/bin/pinentry-curses";
  environment.etc."per-user/root/gpg-agent.conf".text = "allow-loopback-pinentry";
  environment.etc."per-user/root/gpg.conf".text = "pinentry-mode loopback";

  system.activationScripts.gnupg = {
    text = ''
      if ! grep -q "$(cat /etc/per-user/jlotoski/gpg-agent.conf)" /home/jlotoski/.gnupg/gpg-agent.conf; then
        cat /etc/per-user/jlotoski/gpg-agent.conf >> /home/jlotoski/.gnupg/gpg-agent.conf
      fi
      if ! grep -q "$(cat /etc/per-user/root/gpg-agent.conf)" /root/.gnupg/gpg-agent.conf; then
        cat /etc/per-user/root/gpg-agent.conf >> /root/.gnupg/gpg-agent.conf
      fi
      if ! grep -q "$(cat /etc/per-user/root/gpg.conf)" /root/.gnupg/gpg.conf; then
        cat /etc/per-user/root/gpg.conf >> /root/.gnupg/gpg.conf
      fi
    '';
    deps = [];
  };
}
