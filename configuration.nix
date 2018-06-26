{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Label to reflect information about the current config state
  system.nixos.label = "GitRepod";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.mdadmConf = "ARRAY /dev/md/0 metadata=1.2 name=nixos:0 UUID=e9922866:e9b5b0ba:ba7efc6b:bd706cad";

#NAME            FSTYPE            LABEL   UUID                                   MOUNTPOINT
#sda             crypto_LUKS               ab7e3713-9c6b-4a64-acfb-02c360711c87   
#└─cr1           ext4              data    f58a6eed-1211-4fbe-8cd9-241ed6d755a9   /data
#sr0                                                                              
#nvme0n1                                                                          
#├─nvme0n1p1     vfat              boot1   8674-A421                              /boot
#└─nvme0n1p2     linux_raid_member nixos:0 e9922866-e9b5-b0ba-ba7e-fc6bbd706cad   
#  └─md0         crypto_LUKS               7217a816-928c-4674-8bdf-d6ee5edde406   
#    └─cr0       LVM2_member               ba248h-fRch-fkRi-zyPF-7PX9-8M3d-UdEq2t 
#      ├─vg0-lv0 swap              swap    440b0e6a-aafc-46ee-ba45-4ddec2ec983e   [SWAP]
#      └─vg0-lv1 ext4              nixos   802202a4-5520-4273-9b70-3690b2376da5   /
#nvme0n2                                                                          
#├─nvme0n2p1     vfat              boot2   86BC-C593                              
#└─nvme0n2p2     linux_raid_member nixos:0 e9922866-e9b5-b0ba-ba7e-fc6bbd706cad   
#  └─md0         crypto_LUKS               7217a816-928c-4674-8bdf-d6ee5edde406   
#    └─cr0       LVM2_member               ba248h-fRch-fkRi-zyPF-7PX9-8M3d-UdEq2t 
#      ├─vg0-lv0 swap              swap    440b0e6a-aafc-46ee-ba45-4ddec2ec983e   [SWAP]
#      └─vg0-lv1 ext4              nixos   802202a4-5520-4273-9b70-3690b2376da5   /

  boot.initrd.prepend = ["${./lk0.img.cpio.gz}"];

  boot.initrd.luks.devices."0lk" = { device = "/lk0.img"; };

  boot.initrd.luks.devices.cr0 = {
    device = "/dev/disk/by-uuid/7217a816-928c-4674-8bdf-d6ee5edde406";
    allowDiscards = true;
    keyFile = "/dev/mapper/0lk";
  };

  boot.initrd.luks.devices.cr1 = {
    device = "/dev/disk/by-uuid/ab7e3713-9c6b-4a64-acfb-02c360711c87";
    keyFile = "/dev/mapper/0lk";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    hdparm
    mkpasswd
    vim
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  services.fstrim.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  users.mutableUsers = false;

  users.users.jlotoski = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = secrets.hashedPassword;
  };

  users.users.backup = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = secrets.hashedPassword;
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "18.03";

  # Close the 0lk Luks volume key so the unencrypted key data cannot
  # be accessed without unlocking again
  systemd.services.closeLuksKeyVol = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.cryptsetup}/bin/cryptsetup luksClose 0lk";
  };
}
