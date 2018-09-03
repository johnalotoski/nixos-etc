{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
  brotherDSSeries = pkgs.callPackage ./brother-dsseries.nix { };
in {
  imports = [ ./hardware-configuration.nix ];

  # --------------------------------------------------
  # Current config state labels -- overrides tags if enabled
  #
  # system.nixos.label = "kdeEnable";
  #
  #
  # Tags to incorporate into the NixOS boot entry labels
  #
  system.nixos.tags = [ "kde" ];
  #
  # --------------------------------------------------

  
  # --------------------------------------------------
  # Boot related configs
  #
  # Use the systemd-boot EFI boot loader.
  #
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Optimization parameter for xmr-stak:
  #
  boot.kernel.sysctl = { "vm.nr_hugepages" = 128; };

  # Block device structure as seen with `lsblk -f`
  # 
  # SSD > mdadm RAID1 > LUKS > LVM
  # HDD > LUKS
  #
  # ---------------------------------------------------------------------------------------------
  #
  # NAME              FSTYPE            LABEL   UUID                                   MOUNTPOINT
  # sda                                                                                
  # ├─sda1            vfat              boot1   41B8-8A40                              /boot
  # └─sda2            linux_raid_member nixos:0 c5cb0286-a9a9-2645-2a35-4d88941aa36d   
  #   └─md0           crypto_LUKS               a8b83540-8db1-4612-b75b-901718b34c5e   
  #     └─cr0         LVM2_member               OWGXF9-gE0m-D1qQ-z24K-quWY-KgSH-lfM2fd 
  #       ├─vg0-nixos ext4              nixos   0f234721-a60f-4d05-bed5-3b5c8080cdb6   /
  #       └─vg0-swap  swap              swap    c8041681-4662-47a5-9ef8-0a1bc66a8bba   [SWAP]
  # sdb               crypto_LUKS               5a321a3f-11b9-45b5-90e7-d1ebf12700d4   
  # └─cr1             ext4              data    e73802de-ec82-4c5a-bdba-0df1d41f0fd2   /data
  # sdc                                                                                
  # ├─sdc1            vfat              boot2   44D0-0CCE                              
  # └─sdc2            linux_raid_member nixos:0 c5cb0286-a9a9-2645-2a35-4d88941aa36d   
  #   └─md0           crypto_LUKS               a8b83540-8db1-4612-b75b-901718b34c5e   
  #     └─cr0         LVM2_member               OWGXF9-gE0m-D1qQ-z24K-quWY-KgSH-lfM2fd 
  #       ├─vg0-nixos ext4              nixos   0f234721-a60f-4d05-bed5-3b5c8080cdb6   /
  #       └─vg0-swap  swap              swap    c8041681-4662-47a5-9ef8-0a1bc66a8bba   [SWAP]
  # sr0
  #
  # ---------------------------------------------------------------------------------------------
  #
  #
  # This setup was deployed on an EFI booting Thinkpad P71 using the following NixOS
  # installation method. On this system the identical SSDs are recognized as /dev/sda and
  # /dev/sdc and the HDD as sdb.
  #
  #
  # Setup the SSDs (repeat the same for sdc):
  #
  #   fdisk /dev/sda
  #     n (new partition)
  #     1 (default part number)
  #     2048 (default first sector)
  #     +512M (size)
  #     t (change partition type)
  #     1 (Linux EFI system)
  #     n (new)
  #     2 (default new partition)
  #     <enter> (default new first sector)
  #     <enter> (default last sector)
  #     w (write changes and exit)
  #
  #
  # Create the SSD RAID 1 (Mirrored) Array:
  #
  #   mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sda2 /dev/sdc2
  #
  #
  # Status checks during RAID creation can be done with something similar to the following.
  # On 1 TB, creation took ~1 hr for the initial creation to complete and about 0.3% of the
  # write life warranty.  Here total bytes were 512 bytes/sector * num_logical_sectors.
  #
  #   smartctl -a /dev/sda; smartctl -l devstat,0 /dev/sda
  #   smartctl -a /dev/sdc; smartctl -l devstat,0 /dev/sdc
  #   mdadm --detail /dev/md0
  #
  #
  # Obtain the mdadm config line for use later in this configuration.nix file using:
  #
  #   mdadm --detail --scan
  #
  #
  # Create LUKS encryption with passphrase only (will require 1 passphrase entry for
  # each encrypted device).  Here we are encrypting the RAID array and the data drive.
  # Command options can be modified as desired.
  #
  #   cryptsetup -v --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase /dev/md0
  #   cryptsetup -v --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase /dev/sdb
  #
  #
  # Open the crypted volumes and name them cr0 and cr1 for crypt0 and 1 respectively:
  #
  #   cryptsetup luksOpen /dev/md0 cr0
  #   cryptsetup luksOpen /dev/sdb cr1
  #
  #
  # Create LVM on cr0, sectioning up the volume as desired:
  #
  #   pvcreate /dev/mapper/cr0
  #   vgcreate vg0 /dev/mapper/cr0
  #   lvcreate -L 900G -n nixos vg0
  #   lvcreate -l 100%FREE -n swap vg0
  #
  #
  # Create filesystems on boot, root, swap and data partitions:
  #
  #   mkfs.fat -F 32 -n boot1 /dev/sda1
  #   mkfs.fat -F 32 -n boot2 /dev/sdc1
  #   mkfs.ext4 -L nixos /dev/mapper/vg0-nixos
  #   mkfs.ext4 -L data /dev/mapper/cr1
  #   mkswap -L swap /dev/mapper/vg0-swap
  #
  #
  # Prep the installation:
  #
  #   mount /dev/disk/by-label/nixos /mnt
  #   mkdir -p /mnt/boot
  #   mount /dev/disk/by-label/boot1 /mnt/boot
  #   swapon /dev/disk/by-label/swap
  #   nixos-generate-config --root /mnt
  #
  #
  # Configure the .nix files as needed, using github nix files as a template if desired:
  #
  #   vi /mnt/etc/nixos/configuration.nix
  #   vi /mnt/etc/nixos/hardware-configuration.nix
  #
  #
  # Install NixOS:
  #
  #   nixos-install
  #   reboot
  #
  #
  # Post boot, for high DPI monitors, the following command can enlarge the font:
  #   Ref: https://wiki.archlinux.org/index.php/HiDPI#Linux_console
  #   Ref: https://gist.github.com/domenkozar/b3c945035af53fa816e0ac460f1df853
  #
  #    setfont latarcyrheb-sun32
  #
  #
  # Upon booting into NixOS 18.03, reboot persistent WiFi with Network Manager can be added:
  #
  #   nmcli con add con-name <con-name> ifname <if> type wifi ssid <ssid>
  #   nmcli con modify <con-name> wifi-sec.key-mgmt wpa-psk
  #   nmcli con modify <con-name> wifi-sec.psk <password>
  #   nmcli con modify <con-name> connection.autoconnect-priority <number, ex: 10>
  #   nmcli -f autoconnect-priority,name c
  #
  #
  # A LUKS password will be required on boot for both devices.  One way to enable a single
  # LUKS password to unlock both devices is to use a LUKS image key.  The following is
  # one way to do this and the resulting image key is used in the nix config below.
  #
  # Inspiration for this method was from:
  #   https://gist.github.com/CMCDragonkai/6456d974982e09d4fe71f339f9029bd3
  #   https://github.com/NixOS/nixpkgs/issues/24386
  #
  # To create a LUKS image file of about 4 MB, containing about 2 MB of random key data,
  # the following setup was used:
  #
  #   dd if=/dev/zero of=/boot/lk0.img bs=1024 count=0 seek=4096
  #   cryptsetup -v --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase luksFormat /boot/lk0.img
  #   cryptsetup luksOpen /boot/lk0.img 0lk
  #   dd if=/dev/urandom of=/dev/mapper/0lk
  #   cryptsetup luksAddKey /dev/md0 /dev/mapper/0lk
  #   cryptsetup luksAddKey /dev/sdb /dev/mapper/0lk
  #   cryptsetup luksClose 0lk
  #   pushd /boot
  #   cpio --create --format=newc <<< "lk0.img" | gzip > ./lk0.img.cpio.gz
  #   popd

  # Required for the LUKS key volume to mount to the loopback device during boot.
  # Uncomment the following line if the LUKS image key described above is being used.
  #
  boot.initrd.kernelModules = [ "loop" ];

  # RAID1 array configuration.  Generated after RAID creation with `mdadm --detail --scan`
  #
  boot.initrd.mdadmConf = "ARRAY /dev/md0 metadata=1.2 name=nixos:0 UUID=c5cb0286:a9a92645:2a354d88:941aa36d";
  
  # Hack to allow degraded array to boot per https://github.com/NixOS/nixpkgs/issues/31840
  #
  boot.initrd.preLVMCommands = "mdadm --run /dev/md127";

  # Append the LUKS key image to initrd.  The nix anti-quoting in the statement below
  # of ${ ... } and enclosed in double quotes is important to make this work.
  # Uncomment the following line if the LUKS image key described above is being used.
  #
  boot.initrd.prepend = ["${/boot/lk0.img.cpio.gz}"];

  # Unlock the main LUKS image key on boot to enable a single password prompt boot up.
  # Uncomment the following line if the LUKS image key described above is being used.
  #
  # Even though the image name is 'lk0.img', the LUKS image is mapped as '0lk' to ensure
  # it is opened as the first LUKS device to then be used as the key for other LUKS devices
  # Also, even though this file was created at /boot/lk0.img, the path during boot is
  # relative to only the mounted boot partition at /.
  #
  boot.initrd.luks.devices."0lk" = { device = "/lk0.img"; };

  boot.initrd.luks.devices.cr0 = {
    device = "/dev/disk/by-uuid/a8b83540-8db1-4612-b75b-901718b34c5e";
    allowDiscards = true;
  # Uncomment the following line if the LUKS image key described above is being used
    keyFile = "/dev/mapper/0lk";
    fallbackToPassword = true;
  };

  boot.initrd.luks.devices.cr1 = {
    device = "/dev/disk/by-uuid/5a321a3f-11b9-45b5-90e7-d1ebf12700d4";
  # Uncomment the following line if the LUKS image key described above is being used
    keyFile = "/dev/mapper/0lk";
    fallbackToPassword = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot1";
    fsType = "vfat";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Networking
  #
  networking.firewall.allowedTCPPorts = [ 631 ];
  networking.firewall.allowedUDPPorts = [ 631 ];
  networking.hostName = "nixos";
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager.enable = true;
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Internationalization
  #
  time.timeZone = "America/New_York";
  i18n = {
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Declarative system package management
  #
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    acpi
    binutils
    borgbackup
    cudatoolkit
    file
    hdparm
    hddtemp
    
    # Following line to address: https://github.com/NixOS/nixpkgs/issues/38887
    # This is also needed on this system to prevent KOrganizer crashes.
    # It will add entries of the form 'application/x-vnd.[akonadi.*|kde.*]
    # to the /run/current-system/sw/share/mime/types file.
    #
    kdeApplications.akonadi-mime
    
    lm_sensors
    lsof
    mkpasswd
    mutt
    pciutils
    smartmontools
    usbutils
    vimHugeX
    wget
  ];
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Program declarations
  #
  programs.bash.enableCompletion = true;
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Services
  #
  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;  
  services.fstrim.enable = true;
  services.netdata.enable = true;
  services.postfix.enable = true;
  services.postfix.setSendmail = true;
  services.printing.browsing = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.printing.enable = true;

  # There is a bug with the NixOS psd version in Bash 4.4
  # See: https://github.com/NixOS/nixpkgs/issues/6576
  
  # services.psd.enable = true;
  # services.psd.users = [ "jlotoski" "backup" ];

  services.sysstat.enable = true;

  # Teamviewer still needs be added to the users autostart
  # A KDE Windows Rule to minimize "TeamViewer" Window can be added
  # Under advanced TeamViewer options uncheck "Show Computers & Contacts on startup"

  services.teamviewer.enable = true;

  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";

  # Enable touchpad support

  services.xserver.libinput.enable = true;

  # Enable this mode for Hybrid with no bumblebee or with discrete
  # (not currently needed)
  #
  # services.xserver.videoDrivers = [ "intel" "nvidia" ];

  # Close the 0lk LUKS volume key post boot so the unencrypted 
  # key data cannot be accessed without unlocking again.
  # Uncomment the following systemd services section if the LUKS
  # image key described above is being used.
  #
  systemd.services.closeLuksKeyVol = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.cryptsetup}/bin/cryptsetup luksClose 0lk";
  };

  # Monitor for RAID array issues and send email as needed
  # Re-evaluate on upgrade to NixOS 18.09 per
  # https://github.com/NixOS/nixpkgs/pull/38067
  #
  systemd.services.raid-monitor = {
    description = "Mdadm Raid Monitor";
    wantedBy = [ "multi-user.target" ];
    after = [ "postfix.service" ];
    serviceConfig.ExecStart = "${pkgs.mdadm}/bin/mdadm --monitor --scan -m root";
  };
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Virtualization
  #
  virtualisation.virtualbox.host.enable = true;
  nixpkgs.config.virtualbox.enableExtensionPack = true;
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Declarative user management
  #
  users.mutableUsers = false;

  users.users.jlotoski = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "scanner" "wheel" "vboxusers" ];
    hashedPassword = secrets.hashedPassword;
  };

  users.users.backup = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "scanner" "wheel" "vboxusers" ];
    hashedPassword = secrets.hashedPassword;
  };

  security.sudo.wheelNeedsPassword = false;
  
  # Optimization parameters for xmr-stak:
  #
  security.pam.loginLimits = [ { domain = "*"; item = "memlock"; type = "hard"; value = "262144"; }  { domain = "*"; item = "memlock"; type = "soft"; value = "262144"; } ];
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Misc
  #
  sound.enable = true;
  hardware.bumblebee.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.sane.enable = true;

  # The sane backend defined at the top and called below is from:
  # https://github.com/pjones/nix-utils/blob/master/pkgs/drivers/brother-dsseries.nix
  # This enables the Brother DS-620 scanner to work.  The deb binary was
  # obtained from the following location after accepting the EULA:
  # http://support.brother.com/g/b/downloadend.aspx?c=us_ot&lang=en&prod=ds620_all&os=128&dlid=dlf100976_000&flang=4&type3=566&dlang=true 

  hardware.sane.extraBackends = [ brotherDSSeries ];
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # NixOS Versioning
  #
  system.stateVersion = "18.03";
  #
  # --------------------------------------------------
}
