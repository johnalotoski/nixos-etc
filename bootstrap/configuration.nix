{
  config,
  pkgs,
  ...
}: let
  hashedPassword = "$6$T3eCnq9giW$vjBlWEh9w/nJ7lV9/6hyYUX1P7YmP70Ajo1w47rsLM0q356FHWDG8c4NDQZMrF06uXDlQ.C/L5zUb9fUvJzNh/";

  mkUser = user: {
    ${user} = {
      inherit hashedPassword;
      isNormalUser = true;
      extraGroups = ["docker" "networkmanager" "wheel" "vboxusers" "libvirtd" "plugdev"];
      shell = pkgs.bash;
    };
  };
in {
  imports = [
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    (import ./disko-config.nix {})
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix = {
    settings = {
      substituters = [
        "https://cache.iog.io"
        "https://cache.nixos.org/"
      ];

      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      trusted-users = ["root" "jlotoski"];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # For ZFS use this is required:
  # head -c 8 /etc/machine-id
  networking.hostId = "CHANGE_ME";

  users.mutableUsers = false;

  users.users = pkgs.lib.pipe {} [
    (pkgs.lib.recursiveUpdate (mkUser "jlotoski"))
    (pkgs.lib.recursiveUpdate (mkUser "backup"))
  ];

  security.sudo.wheelNeedsPassword = true;

  # Update the hostname:
  networking.hostName = "CHANGE_ME";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    vim
  ];

  system.stateVersion = "23.05";
}
