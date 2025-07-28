{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  mkPkgs = input:
    import self.inputs.${input} {
      system = pkgs.system;
      config.allowUnfree = true;
    };

  # System nixpkgs pins
  # stable pin is pkgs as nixpkgs input
  # unstable = mkPkgs "nixos-unstable";
  # unstable-nixpkgs = mkPkgs "nixpkgs-unstable";

  # User nixpkgs pins
  nixpkgs-user = mkPkgs "nixpkgs-user";
in {
  nixpkgs.config.allowUnfree = true;

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

  # Used by starship for fonts and nvim
  # fonts.packages = with pkgs; [
  #   fira-code-symbols
  #   nerd-fonts.symbols-only
  # ];

  environment.shellAliases = {
    whereis = "f(){ realpath $(command -v \"$1\"); unset -f f; }; f";
  };

  environment.systemPackages = with pkgs; [
    acpi
    age
    alejandra
    aria
    binutils
    (pkgs.callPackage ../pkgs/bluemail.nix {})
    borgbackup
    brave
    bridge-utils
    btop
    cachix
    cfssl
    comma
    crane
    crystal
    crystal2nix
    cue
    curlie
    delta
    difftastic
    direnv
    dive
    dog
    (pkgs.writeShellApplication {
      name = "dog-dns";
      text = ''${lib.getExe pkgs.dogdns} "''$@" '';
    })
    dnsutils
    docker-compose
    duf
    dust
    efibootmgr
    entr
    eternal-terminal
    eza
    fd
    file
    fx
    fzf
    gcc
    glances
    glxinfo
    gnumake
    gopass
    graphviz
    haskellPackages.aeson-diff
    haskellPackages.niv
    hdparm
    hddtemp
    hping
    htop
    httpie
    (hwloc.override {x11Support = true;})
    iat
    icdiff
    iftop
    ijq
    inotify-tools
    iotop
    jc
    jid
    jiq
    jq
    kdePackages.konversation
    ledger-live-desktop
    ledger-udev-rules
    libsForQt5.kate
    libsForQt5.kolourpaint
    libsForQt5.ksystemlog
    libsForQt5.spectacle
    lm_sensors
    lsof
    lsd
    lutris
    manix
    mitmproxy
    mkpasswd
    moreutils
    mtr
    mullvad-vpn
    mutt
    nap
    ncdu
    nfs-utils
    nftables
    ngrep
    nix-diff
    nix-du
    nix-eval-jobs
    nix-fast-build
    nix-index
    nix-output-monitor
    nix-top
    nixos-container
    nixos-option
    nixos-rebuild-ng
    nix-tree
    nixfmt-rfc-style
    nmap
    nnn
    nox
    nushell
    obs-studio
    openssl
    pkg-config
    patchelf
    pavucontrol
    pciutils
    pdftk
    pdfchain
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
    (lib.lowPrio remarshal)
    remmina
    ranger
    ripgrep
    ruby
    sd
    shards
    shellcheck
    shfmt
    skopeo
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

    # Package this -- looks handy:
    # sshm

    step-cli
    sublime3
    summon
    syncthing
    sysstat
    tcpdump
    tcpflow
    tdesktop
    tldr
    tmate
    tmux
    tree
    treefmt
    tty-share
    unzip
    usbutils
    vagrant
    # ventoy-full
    virt-manager
    vlc
    vnstat
    vopono
    wayland-utils
    wine
    wireshark
    wpa_supplicant
    wpa_supplicant_gui
    wget
    wireguard-tools
    xclip
    xdotool
    xkcdpass
    xplr
    xxd
    ydiff
    yq
    yubico-piv-tool
    yubikey-manager
    zgrviewer
    zip
    zoom-us
    zstd

    # User packages which require an independent pin bump from system
    nixpkgs-user.bluemail
    nixpkgs-user.cointop
    nixpkgs-user.firefox
    nixpkgs-user.google-chrome
    nixpkgs-user.gimp
    nixpkgs-user.inkscape
    nixpkgs-user.libreoffice-fresh
    nixpkgs-user.signal-desktop
  ];
}
