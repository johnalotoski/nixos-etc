{ config, pkgs, ... }:
let
  unstable = import <nixosunstable> {};
in {
  nixpkgs = {
    config.allowUnfree = true;
  };

  programs.x2goserver.enable = true;
  systemd.coredump.enable = true;
  system.extraSystemBuilderCmds = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';

  environment.etc."system-packages".text =
  let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

  environment.systemPackages = with pkgs; [
    acpi
    ag
    bat
    binutils
    borgbackup
    direnv
    efibootmgr
    fd
    file
    # haskellPackages.niv
    hdparm
    hddtemp
    hping
    (hwloc.override { x11Support = true; })
    iftop
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
    nixos-container
    noip
    nix-diff
    unstable.haskellPackages.niv
    pciutils
    pwgen
    ripgrep
    smartmontools
    sysstat
    tcpdump
    usbutils
    vnstat
    wget
  ];
}
