{
  lib,
  name,
  self,
  ...
}: let
  inherit (lib) concatStringsSep filterAttrs foldl' mapAttrsToList recursiveUpdate;

  buildMachines' = let
    machine = self.nixosConfigurations.${name};

    mkBuilder = name: maxJobs: speedFactor: {
      ${name} = {
        inherit maxJobs speedFactor;

        hostName = "${name}-builder";

        systems =
          [(machine.pkgs.system or machine.nixpkgs.system)]
          ++ machine.config.nix.settings.extra-platforms or [];

        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      };
    };
  in
    foldl' recursiveUpdate {} [
      (mkBuilder "nixos-g76" 4 2)
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
      '';
    };
  in
    foldl' recursiveUpdate {} [
      (mkSshCfg "nixos-g76")
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

  programs.ssh.extraConfig =
    concatStringsSep "\n"
    (mapAttrsToList (_: v: v)
      (filterAttrs (n: _: n != name) sshCfg));
}
