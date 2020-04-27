{ config, pkgs, lib, ... }:

with lib; {
  boot.kernelParams = [
    "zfs.zfs_arc_max=${toString (1024*1024*1024*10)}"
  ];
}
