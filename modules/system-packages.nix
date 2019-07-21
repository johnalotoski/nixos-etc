{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.etc."system-packages".text =
  let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

  environment.systemPackages = with pkgs; [
    acpi
    ag
    binutils
    borgbackup
    file
    hdparm
    hddtemp
    hping
    hwloc
    iotop
    gitAndTools.gitFull

    # Following line to address: https://github.com/NixOS/nixpkgs/issues/38887
    # This is also needed on this system to prevent KOrganizer crashes.
    # It will add entries of the form 'application/x-vnd.[akonadi.*|kde.*]'
    # to the /run/current-system/sw/share/mime/types file.
    #
    kdeApplications.akonadi-mime

    lm_sensors
    lsof
    mkpasswd
    mutt
    ncat
    nix-diff
    pciutils
    pwgen
    smartmontools
    sysstat
    tcpdump
    usbutils
    wget
  ];
}
