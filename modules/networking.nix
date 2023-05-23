{config, ...}:
let
  wirelessInterface = builtins.head config.networking.wireless.interfaces;
in {
  services.nscd.enableNsncd = true;
  services.resolved.enable = true;

  networking = {
    useDHCP = false;
    # useNetworkd = true;
    networkmanager.enable = true;
    networkmanager.dns = "systemd-resolved";
    # wireless.enable = true;
  };

  # systemd.network.wait-online.anyInterface = true;

  # systemd.network.networks."00-wifi" = {
  #   name = wirelessInterface;
  #   DHCP = "yes";
  #   domains = ["~."];
  #   dns = ["8.8.8.8"];
  # };

  # systemd.network.networks.tun0 = {
  #   name = "tun0";
  #   domains = ["~ziti"];
  # };
}
