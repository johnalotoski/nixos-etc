{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in {
  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ secrets.wireguard.ip.nixos ];
      listenPort = secrets.wireguard.listenPort;
      privateKeyFile = "/etc/nixos/secrets/jlotoski.wgprivate";
      peers = [
        {
          allowedIPs = [ secrets.wireguard.ip.staging ];
          publicKey = secrets.wireguard.publicKey.staging;
          endpoint = secrets.wireguard.endpoint.staging;
          persistentKeepalive = 30;
        }
        {
          allowedIPs = [ secrets.wireguard.ip.sarov ];
          publicKey = secrets.wireguard.publicKey.sarov;
          endpoint = secrets.wireguard.endpoint.sarov;
          persistentKeepalive = 30;
        }
      ];
    };
  };
  networking.firewall.allowedUDPPorts = [ secrets.wireguard.listenPort ];
}
