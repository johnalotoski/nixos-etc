{ config, pkgs, lib, ... }:
let
  unstable = import <nixosunstable> {
    config.allowUnfree = true;
  };
  nixpkgsUnstable = import <nixpkgsunstable> {
    config.allowUnfree = true;
  };
  sources = import ../nix/sources.nix;
  neovim = (import sources.neovim-flake).packages.${builtins.currentSystem}.neovim;
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

  # Used by starship for fonts
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  environment.systemPackages = with pkgs; [
    acpi
    aria
    bat
    binutils
    borgbackup
    bridge-utils
    cachix
    curlie
    unstable.crystal
    unstable.crystal2nix
    delta
    nixpkgsUnstable.difftastic
    direnv
    dnsutils
    docker-compose
    efibootmgr
    fd
    file
    fzf
    gcc
    git-filter-repo
    gitAndTools.gitFull
    gitAndTools.hub
    glances
    glxinfo
    gnumake
    # Golang tools are included in the vim module along with vim-go plugin and related bins
    gopass
    graphviz
    haskellPackages.aeson-diff
    haskellPackages.niv
    hdparm
    hddtemp
    hping
    unstable.htop
    httpie
    (hwloc.override { x11Support = true; })
    icdiff
    iftop
    ijq
    iotop
    jid
    jiq
    jq
    libsForQt5.kate
    libsForQt5.kolourpaint
    libsForQt5.ksystemlog
    libsForQt5.spectacle
    konversation
    lm_sensors
    ledger-live-desktop
    unstable.logseq
    lsof
    unstable.lutris
    unstable.manix
    mkpasswd
    mtr
    unstable.mullvad-vpn
    mutt
    ncat
    ncdu
    neovim
    ngrep
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
    pciutils
    postgresql_13
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
    smem
    socat
    sqlite
    sqlite-interactive
    sqlitebrowser
    unstable.starship
    sublime3
    summon
    syncthing
    sysstat
    tcpdump
    tcpflow
    tdesktop
    tig
    tmate
    tmux
    tree
    tty-share
    unzip
    usbutils
    # Temporary work around for broken Xen package
    # https://github.com/NixOS/nixpkgs/issues/108479
    (unstable.vagrant.override { withLibvirt = false; })
    virtmanager
    vlc
    vnstat
    wine
    wireshark
    wpa_supplicant
    wpa_supplicant_gui
    wget
    xdotool
    xkcdpass
    xxd
    ydiff
    yq
    zgrviewer
    zip
    zoom-us
    zstd
  ];
}
