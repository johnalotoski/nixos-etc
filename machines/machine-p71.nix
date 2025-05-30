{...}: {
  imports = [
    ../hw/hw-p71.nix
    # ../modules/backup.nix
    # ../modules/cuda.nix
    ../modules/cardano-node.nix
    ../modules/ccache.nix
    ../modules/db.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hidpi.nix
    ../modules/hw.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    # ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/tailscale.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    # ../modules/wireguard.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  # Use build assistance as p71 is getting old
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    # Optionally disable local building
    # settings.max-jobs = 0;

    buildMachines = [
      {
        hostName = "nixos-g76-builder";
        system = "x86_64-linux";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
      {
        hostName = "nixos-serval-builder";
        system = "x86_64-linux";
        maxJobs = 8;
        speedFactor = 10;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
    ];
  };

  programs.ssh.extraConfig = ''
    Host nixos-g76-builder
      Hostname nixos-g76
      User builder
      Port 22
      PubkeyAcceptedKeyTypes ssh-ed25519
      IdentitiesOnly yes
      IdentityFile /home/jlotoski/.ssh/id_homebuilder
      StrictHostKeyChecking accept-new

    Host nixos-serval-builder
      Hostname nixos-serval
      User builder
      Port 22
      PubkeyAcceptedKeyTypes ssh-ed25519
      IdentitiesOnly yes
      IdentityFile /home/jlotoski/.ssh/id_homebuilder
      StrictHostKeyChecking accept-new
  '';

  # networking.extraHosts = ''
  #   127.0.0.1 explorer.cardano.org
  # '';

  networking.hostId = "35c02924";

  system.nixos.tags = ["kde"];
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  networking.hostName = "nixos-p71";
  networking.wireless.interfaces = ["wlp4s0"];

  system.stateVersion = "22.11";
}
