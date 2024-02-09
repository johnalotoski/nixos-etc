{lib, ...}: {
  # For cardano-ops libvirtd virtualisation
  systemd.services.libvirtd.restartIfChanged = lib.mkForce true;
  networking.firewall.checkReversePath = lib.mkForce false;

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv7l-linux"];

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';
}
