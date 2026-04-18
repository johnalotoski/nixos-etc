{pkgs, ...}: {
  boot.kernelModules = ["dummy"];
  environment.variables.HOST_INTERFACE = "dummy0";
  networking.dhcpcd.denyInterfaces = ["dummy0"];
  system.activationScripts.binbash = "ln -sf ${pkgs.bashInteractive}/bin/bash /bin/bash";

  systemd.services = {
    docker-loki-plugin = {
      description = "Install Grafana Loki Docker logging driver plugin";
      after = ["docker.service"];
      requires = ["docker.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "install-loki-plugin" ''
          if ! ${pkgs.docker}/bin/docker plugin ls --format '{{.Name}}' \
              | grep -q '^loki:'; then
            ${pkgs.docker}/bin/docker plugin install \
              grafana/loki-docker-driver \
              --alias loki \
              --grant-all-permissions
          fi
        '';
      };
    };

    dummy-interface = {
      description = "Create dummy0 network interface";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "dummy-interface-up" ''
          ${pkgs.iproute2}/bin/ip link add dummy0 type dummy 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip link set dummy0 up
        '';
      };
    };
  };
}
