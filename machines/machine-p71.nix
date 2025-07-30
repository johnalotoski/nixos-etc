{...}: {
  imports = [
    ../hw/hw-p71.nix
    ../modules/common.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hidpi.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/yubikey.nix
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

  networking = {
    hostId = "35c02924";
    hostName = "nixos-p71";
    nat.externalInterface = "wlp0s20f3";
    wireless.interfaces = ["wlp4s0" "wifi-tplink"];
  };

  system.stateVersion = "22.11";
}
