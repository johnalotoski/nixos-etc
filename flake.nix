{
  description = "Workstation flake";

  inputs = {
    # Pins for system packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-wordpress.url = "github:NixOS/nixpkgs";
    neovim-flake.url = "github:johnalotoski/neovim-flake/autocmd-highlighting";

    # Pins for user packages
    nixpkgs-user.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-user-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-user-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # System inputs
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Until recursive submodules issue is resolved, affecting some cardano-node builds:
    # https://github.com/NixOS/nix/issues/10022
    nix.url = "github:NixOS/nix/2.19-maintenance";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Misc sw inputs
    capkgs.url = "github:input-output-hk/capkgs";
    cardano-node = {
      url = "github:input-output-hk/cardano-node/8.9.3";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    localOverlay = import ./nix/overlay.nix self;
    overlays = [localOverlay];
    baseModules = [(_: {nixpkgs.overlays = overlays;})];
  in {
    nixosConfigurations = {
      # Machines: `nixos-rebuild [switch|boot|...] [-L] [-v] [--flake .#$MACHINE]`
      # -----

      nixos-serval = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./machines/machine-serval.nix
          ];
      };

      nixos-g76 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./machines/machine-g76.nix
          ];
      };

      nixos-p71 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./machines/machine-p71.nix
          ];
      };

      # Machine vms for testing: `nixos-rebuild build-vm [-L] [-v] [--flake .#$MACHINE]`
      # -----

      nixos-serval-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./machines/machine-serval.nix
            ./modules/build-vm.nix
          ];
      };

      nixos-g76-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./machines/machine-g76.nix
            ./modules/build-vm.nix
          ];
      };

      nixos-p71-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./machines/machine-p71.nix
            ./modules/build-vm.nix
          ];
      };

      # ISOs:
      # Build: `nix build [-L] [-v] .#nixosConfigurations.$ISO.config.system.build.isoImage`
      # Copy to USB: `dd if=$(fd -e iso . result/iso) of=/dev/sda status=progress`
      # -----

      airgapped = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./iso/airgapped.nix
          ];
      };
    };
  };
}
