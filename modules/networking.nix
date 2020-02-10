{ config, pkgs, ... }:

{
  #networking.nameservers = [ "192.168.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.nameservers = [ "193.138.218.74" ];
  networking.networkmanager.appendNameservers = [ "192.168.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager.enable = true;
}
