{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gnupg pinentry ];
  programs.gnupg.agent.enable = true;

  environment.etc."per-user/jlotoski/gpg-agent".text = "pinentry-program /run/current-system/sw/bin/pinentry-curses";
  environment.etc."per-user/jlotoski/gpg-agent-pe".text = "pinentry-mode loopback";

  system.activationScripts.gnupg = {
    text = ''
      if ! grep -q "$(cat /etc/per-user/jlotoski/gpg-agent)" /home/jlotoski/.gnupg/gpg-agent.conf; then
        cat /etc/per-user/jlotoski/gpg-agent >> /home/jlotoski/.gnupg/gpg-agent.conf
      fi
      if ! grep -q "$(cat /etc/per-user/jlotoski/gpg-agent-pe)" /root/.gnupg/gpg.conf; then
        cat /etc/per-user/jlotoski/gpg-agent-pe >> /root/.gnupg/gpg.conf
      fi
    '';
    deps = [];
  };
}
