{
  description = "Workstation flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-user.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix.url = "github:NixOS/nix/2.29-maintenance";

    capkgs.url = "github:input-output-hk/capkgs";
    neovim-flake.url = "github:johnalotoski/neovim-flake";

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
          inherit self name;
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
        buildVm = true;
      })

      (mkMachine {
        name = "nixos-p71-vm";
        buildVm = true;
      })

      (mkMachine {
        name = "nixos-serval-vm";
        buildVm = true;
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
