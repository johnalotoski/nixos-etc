{
  config,
  lib,
  self,
  ...
}: {
  imports = [
    self.inputs.nix-index-database.nixosModules.nix-index
    {programs.nix-index-database.comma.enable = true;}
  ];

  boot = {
    kernelModules = ["kvm-intel"];
    supportedFilesystems = ["zfs"];
  };

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  programs.xwayland.enable = true;

  services = {
    desktopManager.plasma6.enable = true;
    locate.enable = true;
  };

  system.rebuild.enableNg = true;
}
