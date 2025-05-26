{
  pkgs,
  lib,
  ...
}: {
  programs = {
    bash = {
      completion.enable = true;
      interactiveShellInit = ''
        if [ "$USER" != "builder" ]; then
          if command -v fzf-share >/dev/null; then
            source "$(fzf-share)/key-bindings.bash"
            source "$(fzf-share)/completion.bash"
          fi
          eval "$(starship init bash)"
        fi
      '';
    };

    starship = {
      enable = true;
      presets = ["nerd-font-symbols"];
      settings = {
        username.show_always = true;
        hostname.ssh_only = false;

        git_commit = {
          tag_disabled = false;
          only_detached = false;
        };

        git_metrics.disabled = false;

        localip = {
          format = "@[$localipv4](bold red) ";
          disabled = false;
        };

        memory_usage = {
          format = "via $symbol[\${ram_pct}]($style) ";
          disabled = false;
          threshold = -1;
        };

        shlvl = {
          disabled = false;
          threshold = -1;
          symbol = "↕️";
        };

        time = {
          disabled = true;
        };

        battery = {
          full_symbol = "󰁹 ";
          charging_symbol = "󰂄 ";
          discharging_symbol = "󰂃 ";
          unknown_symbol = "󰁽 ";
          empty_symbol = "󰂎 ";
          display = [
            {
              threshold = 100;
              style = "bold green";
            }
            {
              threshold = 50;
              style = "bold orange";
            }
            {
              threshold = 20;
              style = "bold red";
            }
          ];
        };

        status = {
          map_symbol = true;
          pipestatus = true;
          disabled = false;
        };

        custom = {
          open_bracket = {
            command = "echo '['";
            format = "[$output](bold green) ";
            when = "true";
          };

          close_bracket = {
            command = "echo ']'";
            format = "[$output](bold green) ";
            when = "true";
          };

          time_local = {
            command = "date +'%H:%M %Z'";
            when = "true";
            format = "[$output](bold blue) ";
          };

          time_utc = {
            command = "TZ=UTC date +'%H:%M UTC'";
            when = "true";
            format = "[$output](bold yellow) ";
          };
        };

        format = lib.foldl' (a: s: a + s) "" [
          "$username"
          "$hostname"
          "$localip"
          "$shlvl"
          "$singularity"
          "$kubernetes"
          "$directory"
          "$vcsh"
          "$fossil_branch"
          "$fossil_metrics"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status"
          "$hg_branch"
          "$pijul_channel"
          "$docker_context"
          "$package"
          "$c"
          "$cmake"
          "$cobol"
          "$daml"
          "$dart"
          "$deno"
          "$dotnet"
          "$elixir"
          "$elm"
          "$erlang"
          "$fennel"
          "$gleam"
          "$golang"
          "$guix_shell"
          "$haskell"
          "$haxe"
          "$helm"
          "$java"
          "$julia"
          "$kotlin"
          "$gradle"
          "$lua"
          "$nim"
          "$nodejs"
          "$ocaml"
          "$opa"
          "$perl"
          "$php"
          "$pulumi"
          "$purescript"
          "$python"
          "$quarto"
          "$raku"
          "$rlang"
          "$red"
          "$ruby"
          "$rust"
          "$scala"
          "$solidity"
          "$swift"
          "$terraform"
          "$typst"
          "$vlang"
          "$vagrant"
          "$zig"
          "$buf"
          "$nix_shell"
          "$conda"
          "$meson"
          "$spack"
          "$memory_usage"
          "$aws"
          "$gcloud"
          "$openstack"
          "$azure"
          "$nats"
          "$direnv"
          "$env_var"
          "$mise"
          "$crystal"
          "$sudo"
          "$cmd_duration"
          "$line_break"
          "$jobs"
          "$battery"
          "$time"
          "\${custom.open_bracket}"
          "\${custom.time_local}"
          "\${custom.time_utc}"
          "\${custom.close_bracket}"
          "$status"
          "$os"
          "$container"
          "$netns"
          "$shell"
          "$character"
        ];
      };
    };

    zsh.enable = true;
  };

  environment = {
    shellAliases = {
      manfzf = ''
        manix "" | grep "^# " | sed "s/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //" | fzf --preview="manix {}" | xargs manix
      '';
    };

    systemPackages = with pkgs; [
      starship
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
