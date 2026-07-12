{...}: {
  imports = [
    ../hw/hw-m4800.nix
    ../modules/common.nix
    ../modules/distributed-builds.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/nix.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/yubikey.nix
  ];

  networking = {
    hostName = "nixos-m4800";
  };
}
