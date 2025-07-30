{
  pkgs,
  config,
  lib,
  self,
  ...
}:
with builtins;
with lib; {
  imports = [
    self.inputs.nix-index-database.nixosModules.nix-index
    {programs.nix-index-database.comma.enable = true;}
  ];

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux" "armv7l-linux"];

    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';

    kernelModules = ["kvm-intel"];

    kernelParams = [
      "zfs.zfs_arc_max=${toString (1024 * 1024 * 1024 * 10)}"
    ];

    supportedFilesystems = ["zfs"];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    firewall = {
      allowedTCPPorts =
        optional config.services.printing.enable (toInt (last (split ":" (head config.services.printing.listenAddresses))))
        ++ optional config.services.eternal-terminal.enable config.services.eternal-terminal.port;
    };

    networkmanager.dns = "systemd-resolved";
    networkmanager.enable = true;
    useDHCP = false;
  };

  nix = {
    package = self.inputs.nix.packages.${pkgs.system}.nix;

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
      ];

      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      trusted-users = ["builder" "jlotoski" "root"];
    };

    extraOptions = ''
      netrc-file = /etc/nix/netrc
      experimental-features = nix-command flakes fetch-closure auto-allocate-uids ca-derivations
      auto-allocate-uids = false
    '';
  };

  system = {
    nixos.tags = ["kde"];
    rebuild.enableNg = true;
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
}
