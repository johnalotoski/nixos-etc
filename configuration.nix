{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Label about the current config state -- overrides tags if enabled
  #system.nixos.label = "kdeEnable";

  # Tags to incorporate into the NixOS boot entry labels
  system.nixos.tags = [ "kde" "woLuksDiscards" "nvme-cli" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Block device structure as seen with `lsblk -f`
  # 
  # SSD > mdadm RAID1 > LUKS > LVM
  # HDD > LUKS
  #
  # NAME            FSTYPE            LABEL   UUID                                   MOUNTPOINT
  # sda             crypto_LUKS               ab7e3713-9c6b-4a64-acfb-02c360711c87   
  # └─cr1           ext4              data    f58a6eed-1211-4fbe-8cd9-241ed6d755a9   /data
  # sr0                                                                              
  # nvme0n1                                                                          
  # ├─nvme0n1p1     vfat              boot1   8674-A421                              /boot
  # └─nvme0n1p2     linux_raid_member nixos:0 e9922866-e9b5-b0ba-ba7e-fc6bbd706cad   
  #   └─md0         crypto_LUKS               7217a816-928c-4674-8bdf-d6ee5edde406   
  #     └─cr0       LVM2_member               ba248h-fRch-fkRi-zyPF-7PX9-8M3d-UdEq2t 
  #       ├─vg0-lv0 swap              swap    440b0e6a-aafc-46ee-ba45-4ddec2ec983e   [SWAP]
  #       └─vg0-lv1 ext4              nixos   802202a4-5520-4273-9b70-3690b2376da5   /
  # nvme0n2                                                                          
  # ├─nvme0n2p1     vfat              boot2   86BC-C593                              
  # └─nvme0n2p2     linux_raid_member nixos:0 e9922866-e9b5-b0ba-ba7e-fc6bbd706cad   
  #   └─md0         crypto_LUKS               7217a816-928c-4674-8bdf-d6ee5edde406   
  #     └─cr0       LVM2_member               ba248h-fRch-fkRi-zyPF-7PX9-8M3d-UdEq2t 
  #       ├─vg0-lv0 swap              swap    440b0e6a-aafc-46ee-ba45-4ddec2ec983e   [SWAP]
  #       └─vg0-lv1 ext4              nixos   802202a4-5520-4273-9b70-3690b2376da5   /

  # Required for the LUKS key volume to mount to the loopback device during boot
  boot.initrd.kernelModules = [ "loop" ];

  # RAID1 array configuration.  Generated after RAID creation with `mdadm --detail --scan`
  boot.initrd.mdadmConf = "ARRAY /dev/md/0 metadata=1.2 name=nixos:0 UUID=e9922866:e9b5b0ba:ba7efc6b:bd706cad";
  
  # Append the LUKS key image to initrd
  #
  # To create the LUKS image, the following setup was used:
  #
  # `dd if=/dev/zero of=/boot/luks-key.img bs=1024 count=0 seek=4096`
  # `cryptsetup <desired_options> luksFormat /etc/nixos/lk0.img`
  # `cryptsetup luksOpen /etc/nixos/lk0.img 0lk`
  # `dd if=/dev/urandom of=/dev/mapper/0lk`
  # `cryptsetup luksAddKey /dev/md0 /dev/mapper/0lk`
  # `cryptsetup luksAddKey /dev/sda /dev/mapper/0lk`
  # `cryptsetup luksClose lk0`
  # `cpio --create --format=newc <<< "/etc/nixos/lk0.img" | gzip > /etc/nixos/lk0.img.cpio.gz`
  #
  # Inspiration for this was from:
  #   https://gist.github.com/CMCDragonkai/6456d974982e09d4fe71f339f9029bd3
  #   https://github.com/NixOS/nixpkgs/issues/24386
  #
  boot.initrd.prepend = ["${./lk0.img.cpio.gz}"];

  # Unlock the main LUKS image key on boot to enable a single password prompt boot up
  #
  # Even though the image name is 'lk0.img', the LUKS image is mapped as '0lk' to ensure
  # it is opened as the first LUKS device to then be used as the key for other LUKS devices
  #
  boot.initrd.luks.devices."0lk" = { device = "/lk0.img"; };

  # Discards appear to be unsupported in my current environment with NixOS as a VBox guest.
  # `lsblk -D`, `hdparm -I <dev>`, etc, give no indication of discard support on the underlying vdevs
  # When building in an env which supports discards, 'issue_discards=1' in lvm.conf is also
  # a possibility although this is caveated by https://wiki.gentoo.org/wiki/SSD#LVM
  #
  boot.initrd.luks.devices.cr0 = {
    device = "/dev/disk/by-uuid/7217a816-928c-4674-8bdf-d6ee5edde406";
    # allowDiscards = true;
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

  # Internationalization
  time.timeZone = "America/New_York";
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Declarative system package management
  environment.systemPackages = with pkgs; [
    hdparm
    mkpasswd
    nvme-cli
    vim
    wget
  ];

  # Program declarations
  programs.bash.enableCompletion = true;

  # Services:
  services.fstrim.enable = true;
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Close the 0lk LUKS volume key post boot so the unencrypted 
  # key data cannot be accessed without unlocking again
  #
  systemd.services.closeLuksKeyVol = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.cryptsetup}/bin/cryptsetup luksClose 0lk";
  };

  # Declarative user management
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

  # Networking
  networking.hostName = "nixos";

  # Misc
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # NixOS Versioning
  system.stateVersion = "18.03";
}
