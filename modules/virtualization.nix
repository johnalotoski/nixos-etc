{ config, pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    # lxd.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  # Override the default root subuid for LXD containers to include snap_daemon uid mapping
  system.activationScripts.submod = {
    text = ''
      ${pkgs.gnused}/bin/sed -i 's/root:1000000:65536/root:1000000:655360/g' /etc/subuid
      ${pkgs.gnused}/bin/sed -i 's/root:1000000:65536/root:1000000:655360/g' /etc/subgid
    '';
    deps = [];
  };
}
