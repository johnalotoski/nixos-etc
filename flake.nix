{
  description = "Workstation flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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

      # Machine vms for testing: `nixos-rebuild build-vm --flake .#$MACHINE`
      nixos-g76-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self;};
        modules = [
          ./machines/machine-g76.nix
          ./modules/build-vm.nix
        ];
      };
    };
  };
}
