{
  config,
  lib,
  ...
}:
with builtins;
with lib; {
  # For temp debugging: `nixos-rebuild test`
  # networking.firewall.enable = false;

  networking.firewall.allowedTCPPorts = [
    # Allow for CUPS TCP
    (toInt (last (split ":" (head config.services.printing.listenAddresses))))
  ];
  networking.firewall.allowedUDPPorts = [
    # Allow for CUPS UDP
    (toInt (last (split ":" (head config.services.printing.listenAddresses))))
  ];
}
