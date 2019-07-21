{ config, pkgs, ... }:

{
  # Monitor for RAID array issues and send email as needed
  # Re-evaluate on NixOS upgrade per
  # https://github.com/NixOS/nixpkgs/pull/38067
  #
  systemd.services.raid-monitor = {
    description = "Mdadm Raid Monitor";
    wantedBy = [ "multi-user.target" ];
    after = [ "postfix.service" ];
    serviceConfig.ExecStart = "${pkgs.mdadm}/bin/mdadm --monitor --scan -m root";
  };
}

