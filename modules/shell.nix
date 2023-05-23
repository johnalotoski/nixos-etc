{pkgs, ...}: {
  programs.bash.enableCompletion = true;

  programs.bash.interactiveShellInit = ''
    if command -v fzf-share >/dev/null; then
      source "$(fzf-share)/key-bindings.bash"
      source "$(fzf-share)/completion.bash"
    fi
    eval "$(starship init bash)"
  '';

  system.activationScripts.starship.text = let
    starshipConfig = pkgs.writeText "starship.toml" ''
      [username]
      show_always = true

      [hostname]
      ssh_only = false

      [git_commit]
      tag_disabled = false
      only_detached = false

      [memory_usage]
      format = "via $symbol[''${ram_pct}]($style) "
      disabled = false
      threshold = -1

      [shlvl]
      disabled = false
      threshold = -1
      symbol = "↕️"

      [time]
      format = '[\[ $time \]]($style) '
      disabled = false

      [[battery.display]]
      threshold = 100
      style = "bold green"

      [[battery.display]]
      threshold = 50
      style = "bold orange"

      [[battery.display]]
      threshold = 20
      style = "bold red"

      [status]
      map_symbol = true
      disabled = false
    '';
  in ''
    mkdir -p /etc/per-user/shared
    cp ${starshipConfig} /etc/per-user/shared/starship.toml
    mkdir -p /home/jlotoski/.config
    mkdir -p /home/backup/.config
    mkdir -p /root/.config
    chown jlotoski:users /home/jlotoski/.config
    chown backup:users /home/backup/.config

    [ -f /home/jlotoski/.config/starship.toml ] || cp ${starshipConfig} /home/jlotoski/.config/starship.toml
    [ -f /home/backup/.config/starship.toml ] || cp ${starshipConfig} /home/backup/.config/starship.toml
    [ -f /root/.config/starship.toml ] || cp ${starshipConfig} /root/.config/starship.toml
    chown -R jlotoski:users /home/jlotoski/.config/starship.toml
    chown -R backup:users /home/backup/.config/starship.toml
  '';

  environment.shellAliases = {
    manfzf = ''
      manix "" | grep "^# " | sed "s/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //" | fzf --preview="manix {}" | xargs manix
    '';
  };
}
