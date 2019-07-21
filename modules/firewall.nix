{ config, pkgs, lib, ...}:

with lib; with builtins; {
  # The following line to be uncommented for debugging
  # purposes as needed and activated with `nixos-rebuild test`
  #
  # networking.firewall.enable = false;

  networking.firewall.allowedTCPPorts = [
    # Allow for CUPS TCP
    (toInt (last (split ":" (head config.services.printing.listenAddresses))))
    # Allow for jekyll temporary webserver
    4000
    # Allow for temporary python webserver
    8080
  ];
  networking.firewall.allowedUDPPorts = [
    # Allow for CUPS UDP
    (toInt (last (split ":" (head config.services.printing.listenAddresses))))
  ];
}
