{ config, pkgs, secrets, lib, ... }:
let
  hostName = config.networking.hostName;
in {
  networking.wireguard.interfaces = secrets."${hostName}".wireguard.interfaces;
  networking.firewall.allowedUDPPorts = secrets."${hostName}".wireguard.listenPorts;
}
