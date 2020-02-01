{ config, pkgs, lib, ... }:

with lib; {
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = __foldl' (x: y: x + y) "" (take 8 (stringToCharacters (fileContents "/etc/machine-id")));
}
