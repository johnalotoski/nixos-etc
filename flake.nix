{
  description = "Workstation flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-ai.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-user.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix.url = "github:NixOS/nix/2.34-maintenance";
    nixos-private.url = "git+ssh://git@github.com/johnalotoski/nixos-private";

    llm-agents.url = "github:numtide/llm-agents.nix";

    capkgs.url = "github:input-output-hk/capkgs";

    neovim-flake = {
      url = "github:johnalotoski/neovim-flake/customize";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-nvchad.url = "github:johnalotoski/nix-nvchad";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    sshm = {
      url = "github:johnalotoski/sshm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cardano-scope = {
      url = "git+ssh://git@github.com/johnalotoski/cardano-scope";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    inherit (builtins) foldl';
    inherit (nixpkgs.lib) optional recursiveUpdate removePrefix removeSuffix;

    system = "x86_64-linux";
    localOverlay = import ./nix/overlay.nix self;
    overlays = [localOverlay];
    baseModules = [(_: {nixpkgs.overlays = overlays;})];

    mkPkgs = input:
      import self.inputs.${input} {
        inherit system;
        config.allowUnfree = true;
      };

    myPkgs = {
      pkgs-ai = mkPkgs "nixpkgs-ai";
      pkgs-user = mkPkgs "nixpkgs-user";
      pkgs-llm = self.inputs.llm-agents.packages.${system};
    };

    mkMachine = {
      name,
      buildVM ? false,
      isBootstrap ? false,
      ...
    }: let
      n = removePrefix "nixos-" (removeSuffix "-vm" name);
    in {
      ${name} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self name system myPkgs;
        };
        modules =
          if isBootstrap
          then baseModules ++ [./iso/bootstrap.nix]
          else
            baseModules
            ++ [./machines/machine-${n}.nix]
            ++ optional buildVM ./modules/build-vm.nix;
      };
    };
  in {
    nixosConfigurations = foldl' recursiveUpdate {} [
      # Machines: `nixos-rebuild [switch|boot|...] [-L] [-v] [--flake .#$MACHINE]`
      (mkMachine {name = "nixos-g76";})
      (mkMachine {name = "nixos-p71";})
      (mkMachine {name = "nixos-serval";})

      # Machine VMs for testing: `nixos-rebuild build-vm [-L] [-v] [--flake .#$MACHINE]`
      (mkMachine {
        name = "nixos-g76-vm";
        buildVM = true;
      })

      (mkMachine {
        name = "nixos-p71-vm";
        buildVM = true;
      })

      (mkMachine {
        name = "nixos-serval-vm";
        buildVM = true;
      })

      # Machine ISOs for bootstrap `nix build [-L] [-v] .#nixosConfigurations.$ISO.config.system.build.isoImage`
      # Copy to USB: `dd if=$(fd -e iso . result/iso) of=/dev/$TARGET bs=1M status=progress`
      (mkMachine {
        name = "bootstrap";
        isBootstrap = true;
      })
    ];
  };
}
