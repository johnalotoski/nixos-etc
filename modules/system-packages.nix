{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  unstable = import self.inputs.nixos-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  system.extraSystemBuilderCmds = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';

  documentation.man.generateCaches = true;

  environment.etc."system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  # Used by starship for fonts
  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];

  environment.shellAliases = with pkgs; {
    where = "f(){ realpath $(command -v \"$1\"); unset -f f; }; f";
  };

  environment.systemPackages = with pkgs; [
    acpi
    age
    unstable.alejandra
    aria
    bat
    binutils
    borgbackup
    bridge-utils
    cachix
    curlie
    dive
    unstable.crystal
    unstable.crystal2nix
    unstable.cue
    delta
    unstable.difftastic
    direnv
    dnsutils
    docker-compose
    efibootmgr
    fd
    file
    fx
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
    (hwloc.override {x11Support = true;})
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
    mitmproxy
    mkpasswd
    moreutils
    mtr
    unstable.mullvad-vpn
    mutt
    ncdu
    # neovim
    ngrep
    nix-diff
    nix-du
    nix-index
    nix-top
    nixos-container
    nixos-option
    unstable.nix-tree
    nixfmt
    nmap
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
    postgresql
    podman
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
    ruby
    unstable.shards
    shellcheck
    shfmt
    skypeforlinux
    slack
    smartmontools
    smem
    socat
    sops
    sqlite
    sqlite-interactive
    sqlitebrowser
    ssh-to-age
    ssh-to-pgp
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
    treefmt
    tty-share
    unzip
    usbutils
    # Temporary work around for broken Xen package
    # https://github.com/NixOS/nixpkgs/issues/108479
    (unstable.vagrant.override {withLibvirt = false;})
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
    xplr
    xxd
    ydiff
    yq
    zgrviewer
    zip
    zoom-us
    zstd
  ];
}
