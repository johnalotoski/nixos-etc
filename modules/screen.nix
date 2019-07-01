{ config, pkgs, ... }:

{
  programs.screen.screenrc = ''
    hardstatus alwayslastline "%{b}[ %{B}%H %{b}][ %{w}%?%-Lw%?%{b}(%{W}%n*%f %t%?(%u)%?%{b})%{w}%?%+Lw%?%?%= %{b}][%{B} %Y-%m-%d %{W}%c %{b}]"
    shelltitle              "Shell"
    escape                  ^aa             # default
      autodetach            on              # default: on
      crlf                  off             # default: off
      hardcopy_append       on              # default: off
      startup_message       off             # default: on
      vbell                 off             # default: ???
      defmonitor            on
      defscrollback         1000            # default: 100
      silencewait           15              # default: 30

    sorendition             gk              # red on white
      bell                  "%C -> %n%f %t Bell!~"

    pow_detach_msg          "BYE"
      vbell_msg             " *beep* "
      bind .
      bind ^\
      bind \\

    bindkey -k F1 select 0                  # F11 = screen 0; avoid this screen
    bindkey -k k1 select 1                  # F1 = screen 1
    bindkey -k k2 select 2                  # F2 = screen 2
    bindkey -k k3 select 3                  # F3 = screen 3
    bindkey -k k4 select 4                  # F4 = screen 4
    bindkey -k k5 select 5                  # F5 = screen 5
    bindkey -k k6 select 6                  # F6 = screen 6
    bindkey -k k7 select 7                  # F7 = screen 7
    bindkey -k k8 select 8                  # F8 = screen 8
    bindkey -k k9 select 9                  # F9 = screen 9
    bindkey -k k0 select 10                 # F10 = screen 10

    bindkey -k F12 command                  # F12 = Execute a command
      msgwait 2
  '';
}
