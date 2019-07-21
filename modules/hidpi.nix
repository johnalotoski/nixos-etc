{ config, pkgs, ... }:

{
  i18n.consoleFont = pkgs.lib.mkForce "latarcyrheb-sun32";
}
