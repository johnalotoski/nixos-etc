{ config, pkgs, secrets, ... }:

{
  programs.bash.enableCompletion = true;
  programs.bash.interactiveShellInit = ''
    if command -v fzf-share >/dev/null; then
      source "$(fzf-share)/key-bindings.bash"
      source "$(fzf-share)/completion.bash"
    fi
    eval "$(starship init bash)"
  '';
  system.activationScripts.starship = let
    starshipConfig = pkgs.writeText "starship.toml" ''
      [username]
      show_always = true

      [hostname]
      ssh_only = false

      [git_commit]
      tag_disabled = false
      only_detached = false

      [memory_usage]
      format = "via $symbol [''${ram_pct}( | ''${swap_pct})]($style) "
      disabled = false
      threshold = -1

      [shlvl]
      disabled = false
      threshold = -1
      symbol = "↕️"

      [time]
      format = '[\[ $time \]]($style) '
      disabled = false
    '';
  in {
    text = ''
      mkdir -p /etc/per-user/shared
      cp ${starshipConfig} /etc/per-user/shared/starship.toml
      mkdir -p /home/${secrets.priUsr}/.config
      mkdir -p /home/${secrets.secUsr}/.config
      mkdir -p /root/.config
      chown ${secrets.priUsr}:users /home/${secrets.priUsr}/.config
      chown ${secrets.secUsr}:users /home/${secrets.secUsr}/.config

      [ -f /home/${secrets.priUsr}/.config/starship.toml ] || cp ${starshipConfig} /home/${secrets.priUsr}/.config/starship.toml
      [ -f /home/${secrets.secUsr}/.config/starship.toml ] || cp ${starshipConfig} /home/${secrets.secUsr}/.config/starship.toml
      [ -f /root/.config/starship.toml ] || cp ${starshipConfig} /root/.config/starship.toml
      chown -R ${secrets.priUsr}:users /home/${secrets.priUsr}/.config/starship.toml
      chown -R ${secrets.secUsr}:users /home/${secrets.secUsr}/.config/starship.toml
    '';
    deps = [];
  };
  environment.shellAliases = {
    manfzf = ''
      manix "" | grep "^# " | sed "s/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //" | fzf --preview="manix {}" | xargs manix
    '';
  };
}
