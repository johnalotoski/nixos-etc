{ config, pkgs, secrets, lib, ... }:
let
  hostName = config.networking.hostName;
in {
  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
  networking.wireguard.interfaces = secrets."${hostName}".wireguard.interfaces;
  networking.firewall.allowedUDPPorts = secrets."${hostName}".wireguard.listenPorts;
}
