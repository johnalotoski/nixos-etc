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

      bootstrap = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          baseModules
          ++ [
            ./iso/bootstrap.nix
          ];
      };
    };
  };
}
