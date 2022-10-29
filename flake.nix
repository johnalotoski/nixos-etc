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
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    nixosConfigurations = {
      nixos-g76 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self;};
        modules = [
          ./machines/machine-g76.nix
        ];
      };

      nixos-p71 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self;};
        modules = [
          ./machines/machine-p71.nix
        ];
      };

      # Machine vms for testing: `nixos-rebuild build-vm --flake .#$MACHINE`
      nixos-g76-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self;};
        modules = [
          ./machines/machine-g76.nix
          ./modules/build-vm.nix
        ];
      };

      nixos-p71-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self;};
        modules = [
          ./machines/machine-p71.nix
          ./modules/build-vm.nix
        ];
      };
    };
  };
}
