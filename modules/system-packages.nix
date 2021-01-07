{ config, pkgs, lib, ... }:
let
  unstable = import <nixosunstable> {
    config.allowUnfree = true;
  };
in {
  nixpkgs = {
    config.allowUnfree = true;
  };

  system.extraSystemBuilderCmds = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';

  documentation.man.generateCaches = true;

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
    bridge-utils
    cachix
    unstable.crystal
    unstable.crystal2nix
    direnv
    dnsutils
    docker-compose
    efibootmgr
    fd
    file
    fzf
    gcc
    gitAndTools.gitFull
    glances
    glxinfo
    gnumake
    graphviz
    haskellPackages.aeson-diff
    haskellPackages.niv
    (haskell.lib.disableCabalFlag haskellPackages.yaml "no-exe")
    hdparm
    hddtemp
    hping
    unstable.htop
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
    unstable.lutris
    unstable.manix
    mkpasswd
    mtr
    mullvad-vpn
    mutt
    ncat
    ncdu
    nixos-container
    nix-diff
    nix-du
    nix-index
    nix-top
    unstable.nix-tree
    nixfmt
    noip
    notepadqq
    nox
    obs-studio
    unstable.openssl
    unstable.pkg-config
    packet
    patchelf
    pavucontrol
    postgresql
    pciutils
    postgresql
    ps_mem
    pwgen
    python3
    python3Packages.black
    python3Packages.flake8
    python3Packages.ipython
    python3Packages.magic-wormhole
    qalculate-gtk
    quiterss
    (lib.lowPrio remarshal)
    remmina
    ripgrep
    unstable.shards
    shellcheck
    skypeforlinux
    slack
    smartmontools
    sqlite
    sqlite-interactive
    sqlitebrowser
    unstable.starship
    sublime3
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
    unstable.vagrant
    virtmanager
    vlc
    vnstat
    wine
    wireshark
    wget
    ydiff
    yq
    zgrviewer
    zip
    zoom-us
    zstd
  ];
}
