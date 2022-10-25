{pkgs, ...}: {
  # Workaround for nvidia driver instability
  # Ref: https://github.com/NixOS/nixpkgs/issues/163294

  services.dbus.packages = [
    (pkgs.writeTextDir "/etc/dbus-1/system.d/nvidia-fake-powerd.conf" ''
      <!DOCTYPE busconfig PUBLIC
       "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
      <busconfig>
        <policy user="messagebus">
          <allow own="nvidia.powerd.server"/>
        </policy>
        <policy context="default">
          <allow send_destination="nvidia.powerd.server"/>
          <allow receive_sender="nvidia.powerd.server"/>
        </policy>
      </busconfig>
    '')
  ];

  systemd.services.nvidia-fake-powerd = {
    description = "NVIDIA fake powerd service";
    wantedBy = ["default.target"];
    aliases = ["dbus-nvidia.fake-powerd.service"];

    serviceConfig = {
      Type = "dbus";
      BusName = "nvidia.powerd.server";
      ExecStart = "${pkgs.dbus}/bin/dbus-test-tool black-hole --system --name=nvidia.powerd.server";
      User = "messagebus";
      Group = "messagebus";
      LimitNPROC = 2;
      ProtectHome = true;
      ProtectSystem = "full";
    };
  };
}
