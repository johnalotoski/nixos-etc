{ config, pkgs, ... }:
let
  unstable = import <nixosunstable> {};
in {
  nixpkgs = {
    config.allowUnfree = true;
  };

  system.extraSystemBuilderCmds = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';

  environment.etc."system-packages".text =
  let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

  environment.systemPackages = with pkgs; [
    acpi
    bat
    binutils
    borgbackup
    busybox
    direnv
    efibootmgr
    fd
    file
    gcc
    gitAndTools.gitFull
    glxinfo
    gnumake
    graphviz
    haskellPackages.niv
    hdparm
    hddtemp
    hping
    (hwloc.override { x11Support = true; })
    iftop
    iotop
    jq
    kdeApplications.kate
    kdeApplications.kolourpaint
    kdeApplications.ksystemlog
    kdeApplications.spectacle
    konversation
    lm_sensors
    lsof
    mkpasswd
    mullvad-vpn
    mutt
    ncat
    ncdu
    nixos-container
    nix-diff
    nix-du
    nix-index
    noip
    notepadqq
    nox
    obs-studio
    openssl
    packet
    patchelf
    pciutils
    ps_mem
    pwgen
    python3
    python38Packages.glances
    python38Packages.ipython
    qalculate-gtk
    quiterss
    remmina
    ripgrep
    shellcheck
    skypeforlinux
    slack
    smartmontools
    sqlite
    sqlite-interactive
    sqlitebrowser
    sublime
    syncthing
    sysstat
    tcpdump
    tdesktop
    tig
    tmate
    tmux
    tree
    unzip
    usbutils
    vagrant
    virtmanager
    vlc
    vnstat
    wine
    wireshark
    wget
    zgrviewer
    zip
    zoom-us
  ];
}
