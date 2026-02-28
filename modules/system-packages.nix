{
  self,
  config,
  pkgs,
  lib,
  system,
  myPkgs,
  ...
}: let
  cardano-scope = self.inputs.cardano-scope.packages.${system}.default;
  my-neovim = self.inputs.neovim-flake.neovimBuilder.${system} {inherit pkgs;};
  nix-nvchad = self.inputs.nix-nvchad.lib.mkNixNvchad {
    inherit pkgs;
    modules = [
      {
        # Options here:
        # grammars = [...];
      }
    ];
  };
in {
  nixpkgs.config.allowUnfree = true;

  system.systemBuilderCommands = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';

  documentation.man.generateCaches = true;

  environment.etc."system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  environment.shellAliases = {
    whereis = "f(){ realpath $(command -v \"$1\"); unset -f f; }; f";
  };

  environment.systemPackages = with pkgs; [
    acpi
    age
    alejandra
    aria2
    binutils
    (pkgs.callPackage ../pkgs/bluemail.nix {})
    borgbackup
    brave
    bridge-utils
    btop
    bwm_ng
    cachix
    cardano-scope
    ccache
    cfssl
    crane
    crystal
    crystal2nix
    cue
    curlie
    delta
    difftastic
    dive
    dog
    (pkgs.writeShellApplication {
      name = "dog-dns";
      text = ''${lib.getExe pkgs.dogdns} "''$@"'';
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
    gh
    git-filter-repo
    gitFull
    gitui
    glances
    gnumake
    gnupg
    gopass
    gpgme.dev
    gptfdisk
    graphviz
    haskellPackages.aeson-diff
    hexchat
    hping
    htop
    httpie
    hub
    (hwloc.override {x11Support = true;})
    iat
    icdiff
    iftop
    ijq
    inotify-tools
    iotop
    iw
    jc
    jid
    jiq
    jq
    (pkgs.callPackage ../pkgs/jumpcloud.nix {})
    kdePackages.kate
    kdePackages.kolourpaint
    kdePackages.ksystemlog
    kdePackages.spectacle
    ledger-live-desktop
    ledger-udev-rules
    lm_sensors
    lsof
    lsd
    manix
    mesa-demos
    mitmproxy
    mkpasswd
    moreutils
    (pkgs.writeShellApplication {
      name = "mount-nas";
      text = ''sudo mount.nfs "$(dig +short @192.168.86.1 homenas.)":/data/Backup /mnt/nas'';
    })
    mtr
    mullvad-vpn
    mutt
    nap
    my-neovim
    nethogs
    ncdu
    nfs-utils
    nftables
    ngrep
    nix-btm
    nix-diff
    nix-du
    nix-eval-jobs
    nix-fast-build
    nix-nvchad
    nix-output-monitor
    nix-top
    nixos-container
    nixos-option
    nixos-rebuild-ng
    nix-tree
    nixfmt-rfc-style
    nmap
    nnn
    nvd
    nvtopPackages.full
    nushell
    obs-studio
    openssl
    pkg-config
    paperkey
    patchelf
    pavucontrol
    pciutils
    pdfarranger
    pdftk
    pdfchain
    pinentry-all
    postgresql
    podman
    ps_mem
    pv
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
    sane-airscan
    sd
    shards
    shellcheck
    shfmt
    simple-scan
    skopeo
    slack
    smartmontools
    smem
    socat
    sops
    speed-cloudflare-cli
    sqlite
    sqlite-interactive
    sqlitebrowser
    ssh-to-age
    ssh-to-pgp
    self.inputs.sshm.packages.${pkgs.stdenv.hostPlatform.system}.sshm
    step-cli
    sublime3
    summon
    sysstat
    tcpdump
    tcpflow
    telegram-desktop
    tig
    tldr
    tmate
    tmux
    tree
    treefmt
    tty-share
    unixtools.net-tools
    unzip
    usbutils
    vagrant

    # Until the upstream blob issue is resolved:
    # https://github.com/NixOS/nixpkgs/issues/404663
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
    wush
    xclip
    xdotool
    xkcdpass
    xplr
    xsane
    xxd
    yazi
    ydiff
    yq
    yubico-piv-tool
    yubikey-manager
    yubioath-flutter
    zgrviewer
    zip
    zoom-us
    zstd

    # User packages which require an independent pin bump from system
    myPkgs.pkgs-user.bluemail
    myPkgs.pkgs-user.cointop
    myPkgs.pkgs-user.firefox
    myPkgs.pkgs-user.google-chrome
    myPkgs.pkgs-user.gimp
    myPkgs.pkgs-user.inkscape
    myPkgs.pkgs-user.libreoffice-fresh
    myPkgs.pkgs-user.signal-desktop
  ];
}
