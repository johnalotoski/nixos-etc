{secrets, ...}: {
  fileSystems."/mnt/nas" = {
    device = "${secrets.nas}:/data/Backup";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };
}
