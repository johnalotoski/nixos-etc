{ config, pkgs, ... }:
let
  secrets = import ../secrets/secrets.nix;
in {
  fileSystems."/mnt/nas" = {
    device = "${secrets.nas}:/data/Backup";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
}
