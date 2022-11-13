{self, ...}: {
  # For build-vm tests
  imports = [(self.inputs.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")];
  virtualisation = {
    memorySize = 8096;
    cores = 4;
  };
}
