{ config, pkgs, ... }:

{
  services.toxvpn = {
    enable = true;
    localip = "10.40.14.1";
  };
}
