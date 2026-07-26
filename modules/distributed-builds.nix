{
  lib,
  name,
  self,
  ...
}: let
  inherit (lib) concatStringsSep filterAttrs foldl' mapAttrsToList mkBefore recursiveUpdate;

  buildMachines' = let
    machine = self.nixosConfigurations.${name};

    mkBuilder = name: maxJobs: speedFactor: {
      ${name} = {
        inherit maxJobs speedFactor;

        hostName = "${name}-builder";

        systems =
          [(machine.pkgs.stdenv.hostPlatform.system or machine.nixpkgs.system)]
          ++ machine.config.nix.settings.extra-platforms or [];

        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      };
    };
  in
    foldl' recursiveUpdate {} [
      (mkBuilder "nixos-g76" 4 2)
      (mkBuilder "nixos-p16" 8 12)
      (mkBuilder "nixos-p71" 4 4)
      (mkBuilder "nixos-serval" 8 10)
    ];

  sshCfg = let
    mkSshCfg = name: {
      ${name} = ''
        Host ${name}-builder
          Hostname ${name}
          User builder
          Port 22
          PubkeyAcceptedKeyTypes ssh-ed25519
          IdentitiesOnly yes
          IdentityFile /home/jlotoski/.ssh/id_homebuilder
          StrictHostKeyChecking accept-new

          # Every builder here is a laptop and is usually off. Without these,
          # an absent builder stalls the whole build on the default TCP
          # connect timeout before nix gives up and falls back to local.
          ConnectTimeout 5
          ConnectionAttempts 1

          # Never block on a prompt (passphrase, host key, password): for a
          # builder there is no one to answer it, so fail instead of hanging.
          BatchMode yes

          # Notice a builder that vanishes mid-build -- lid closed, suspend,
          # wifi drop -- in ~45s rather than waiting on TCP.
          ServerAliveInterval 15
          ServerAliveCountMax 3
      '';
    };
  in
    foldl' recursiveUpdate {} [
      (mkSshCfg "nixos-g76")
      (mkSshCfg "nixos-p16")
      (mkSshCfg "nixos-p71")
      (mkSshCfg "nixos-serval")
    ];
in {
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    # Optionally disable local building
    # settings.max-jobs = 0;

    buildMachines =
      mapAttrsToList (_: v: v)
      (filterAttrs (n: _: n != name) buildMachines');
  };

  # mkBefore matters: ssh takes the first value it obtains for each option, and
  # services-standard.nix declares a `Host *` block with much laxer keepalives.
  # These per-builder blocks have to precede it or they are silently ignored.
  programs.ssh.extraConfig =
    mkBefore (
      concatStringsSep "\n"
      (mapAttrsToList (_: v: v)
        (filterAttrs (n: _: n != name) sshCfg))
    );
}
