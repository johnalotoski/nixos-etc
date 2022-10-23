{ ... }:
{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
  boot.extraModprobeConfig = "options kvm_intel nested=1";
}
