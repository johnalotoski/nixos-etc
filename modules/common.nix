{
  pkgs,
  config,
  lib,
  self,
  ...
}:
with builtins;
with lib;
with pkgs; {
  imports = [
    self.inputs.nix-index-database.nixosModules.nix-index
    {programs.nix-index-database.comma.enable = true;}
    ./command-not-found.nix
  ];

  options = {
    services.tunnelbroker.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Eanble tunnel broken ipv6 over ipv4 service.";
    };
  };

  config = let
    prgCfg = config.programs;
    svcCfg = config.services;

    avahiPort = "5353";
    cupsPort = head (reverseList (split ":" (head svcCfg.printing.listenAddresses)));
    eternalPort = toString svcCfg.eternal-terminal.port;
    moshPort = "6000-61000";
    sshPort = toString (head svcCfg.openssh.ports);

    hasAvahi = svcCfg.avahi.enable;
    hasCups = svcCfg.printing.enable;
    hasEternal = svcCfg.eternal-terminal.enable;
    hasMosh = prgCfg.mosh.enable;
    hasSsh = svcCfg.openssh.enable;
    hasTunnelBroker = svcCfg.tunnelbroker.enable;
  in {
    boot = {
      binfmt.emulatedSystems = ["aarch64-linux" "armv7l-linux"];

      extraModprobeConfig = ''
        options kvm_intel nested=1
        options kvm_intel emulate_invalid_guest_state=0
        options kvm ignore_msrs=1
      '';

      # Dummy is for a dummy nic
      kernelModules = ["dummy" "kvm-intel"];

      kernelParams = [
        "zfs.zfs_arc_max=${toString (1024 * 1024 * 1024 * 10)}"
      ];

      loader = {
        grub = {
          enable = true;
          efiSupport = true;
          efiInstallAsRemovable = true;
          devices = ["nodev"];
          gfxmodeEfi = "1280x1024";
          memtest86.enable = true;
        };

        systemd-boot.enable = false;
      };

      supportedFilesystems = ["zfs"];
      zfs.forceImportRoot = false;
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    # For virtualisation when a fake interface is required for safety
    environment.variables.HOST_INTERFACE = "dummy0";

    hardware = {
      bluetooth.enable = true;
      cpu.intel.updateMicrocode = true;
      enableRedistributableFirmware = true;

      sane = {
        enable = true;
        dsseries.enable = true;
        extraBackends = [sane-airscan];
      };

      uinput.enable = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";

    networking = let
      inherit (self.inputs.nixos-private.data) tunnelbroker;
    in {
      enableIPv6 = true;
      nftables.enable = true;

      firewall = {
        enable = true;

        # Only allow ping on ipv4 with the rules below
        allowPing = false;

        extraInputRules = ''
          # Avoid opening ipv6 ports as these are not behind a router with tunnel broker
          ${optionalString hasAvahi "ip saddr 192.168.0.0/16 udp dport ${avahiPort} accept"}
          ${optionalString hasCups "ip saddr 192.168.0.0/16 tcp dport ${cupsPort} accept"}
          ${optionalString hasEternal "ip protocol tcp tcp dport ${eternalPort} accept"}
          ${optionalString hasMosh "ip protocol udp udp dport ${moshPort} accept"}
          ${optionalString hasSsh "ip protocol tcp tcp dport ${sshPort} accept"}
          ip protocol icmp icmp type echo-request accept

          ${optionalString hasTunnelBroker "ip protocol 41 accept"}
          ${optionalString hasTunnelBroker "iifname \"tunnelbroker\" drop"}
        '';
      };

      nat = {
        enable = true;
        internalInterfaces = ["ve-+"];
      };

      networkmanager.dns = "systemd-resolved";
      networkmanager.enable = true;

      # The router doesn't accept protocol 41 via regular fw rules, so using
      # this will require temporary dmz status.
      sits.tunnelbroker = mkIf hasTunnelBroker {
        remote = tunnelbroker.serverIpv4;
        ttl = 255;
      };

      interfaces.tunnelbroker = mkIf hasTunnelBroker {
        ipv6.addresses = [
          {
            address = tunnelbroker.clientIpv6;
            prefixLength = 64;
          }
        ];
      };

      defaultGateway6 = mkIf hasTunnelBroker {
        address = tunnelbroker.serverIpv6;
        interface = "tunnelbroker";
      };

      useDHCP = false;
    };

    nix = {
      package = self.inputs.nix.packages.${pkgs.stdenv.hostPlatform.system}.nix;

      # Point `nixpkgs` at this system's own pin. Without these, NIX_PATH
      # defaults to `nixpkgs=flake:nixpkgs`, which resolves through the global
      # registry to nixpkgs-unstable -- so every suggestion command-not-found
      # prints, and every `,` invocation, fetches an unrelated nixpkgs over the
      # network instead of using the already-substituted 26.05 closure.
      registry.nixpkgs.flake = self.inputs.nixpkgs;
      nixPath = ["nixpkgs=${self.inputs.nixpkgs}"];

      settings = {
        builders-use-substitutes = true;

        extra-sandbox-paths = [
          config.programs.ccache.cacheDir
          "/etc/skopeo/auth.json=/etc/nix/skopeo/auth.json"
        ];

        # Fallback to source builds for failing cache paths
        fallback = true;
        max-jobs = 12;

        substituters = [
          "https://cache.iog.io"
          "https://cache.nixos.org/"
          "https://cache.numtide.com"
        ];

        trusted-public-keys = [
          "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];

        trusted-users = ["builder" "jlotoski" "root"];
      };

      extraOptions = ''
        netrc-file = /etc/nix/netrc
        experimental-features = nix-command flakes fetch-closure ca-derivations
      '';
    };

    system = {
      activationScripts.binbash = "ln -sf ${pkgs.bashInteractive}/bin/bash /bin/bash";
      nixos.tags = ["kde"];
    };

    systemd.services.dummy-interface = {
      description = "Create dummy0 network interface";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "dummy-interface-up" ''
          ${pkgs.iproute2}/bin/ip link add dummy0 type dummy 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip link set dummy0 up
        '';
      };
    };

    time.timeZone = "America/Chicago";

    virtualisation = {
      docker.enable = true;
      libvirtd.enable = true;

      virtualbox.host = {
        enable = true;
        enableExtensionPack = true;
      };
    };
  };
}
