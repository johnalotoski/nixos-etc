{
  description = "Workstation flake";

  inputs = {
    # Pins for system packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Pins for user packages
    nixpkgs-user.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixos-user-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-user-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix.url = "github:NixOS/nix?ref=2.11.1";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Misc packages
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    openziti.url = "github:johnalotoski/openziti-bins";
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
  in rec {
    nixosConfigurations = {
      # Machines: `nixos-rebuild [switch|boot|...] [-L] [-v] [--flake .#$MACHINE]`
      # -----

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
