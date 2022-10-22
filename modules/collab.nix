{ config, pkgs, secrets, ... }:
{
  services.keybase.enable = true;
  services.kbfs.enable = true;
  services.teamviewer.enable = true;
  environment.systemPackages = with pkgs; [
    keybase-gui
  ];
}
