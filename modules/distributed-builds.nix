{
  lib,
  name,
  self,
  ...
}: let
  inherit (lib) concatStringsSep filterAttrs foldl' mapAttrsToList mkBefore mkIf recursiveUpdate;

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

  # Every builder except this machine itself.
  activeBuilders = filterAttrs (n: _: n != name) buildMachines';

  # One /etc/nix/machines line for a builder, matching NixOS's own format
  # (protocol default `ssh`; sshKey/mandatoryFeatures/publicHostKey are `-`,
  # the ssh key comes from the ~/.ssh/config IdentityFile for the host alias).
  machineLine = m:
    concatStringsSep " " [
      "ssh://${m.hostName}"
      (concatStringsSep "," m.systems)
      "-"
      (toString m.maxJobs)
      (toString m.speedFactor)
      (concatStringsSep "," m.supportedFeatures)
      "-"
      "-"
    ];

  # p16 is the fastest machine and shouldn't hand builds to the slower laptops
  # by default. Nix has no "saturate local first, then overflow" scheduler
  # knob -- it offloads eagerly to any free remote slot -- so instead p16 ships
  # /etc/nix/machines with every builder line COMMENTED. distributedBuilds
  # stays true so `builders = @/etc/nix/machines` remains in nix.conf, meaning
  # uncommenting a line activates that builder on the next build with NO
  # rebuild (may need `sudo systemctl restart nix-daemon` to pick it up).
  isP16 = name == "nixos-p16";

  commentedMachines =
    ''
      # Remote builders are OFF by default on this machine (see
      # modules/distributed-builds.nix). Uncomment a line to offload to that
      # builder; no rebuild needed. Restart nix-daemon if not picked up.
    ''
    + concatStringsSep "\n" (mapAttrsToList (_: m: "# ${machineLine m}") activeBuilders)
    + "\n";
in {
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    # Optionally disable local building
    # settings.max-jobs = 0;

    # p16: empty so NixOS doesn't write an active /etc/nix/machines; the
    # commented reference file below takes its place. Others: the usual list.
    buildMachines =
      if isP16
      then []
      else mapAttrsToList (_: v: v) activeBuilders;
  };

  # Only p16 (buildMachines = []) -- for the others NixOS generates this file
  # itself from buildMachines, so guard to avoid a collision.
  environment.etc."nix/machines" = mkIf isP16 {text = commentedMachines;};

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
