{ config, pkgs, ... }:

{
  time.timeZone = "America/New_York";
  i18n = {
    consoleFont = "Lat2-Terminus16";

    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
}
