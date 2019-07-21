{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
  brotherDSSeries = pkgs.callPackage ../brother-dsseries.nix { };
in with pkgs.lib; with builtins; {
  imports = [
    ../hw/hw-p71.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/iohk-csl-nginx.nix
    ../modules/sarov.nix
    ../modules/vim.nix
  ];

  system.nixos.tags = [ "kde" ];

  networking.firewall.allowedTCPPorts = [
    # Allow for CUPS TCP
    (toInt (last (split ":" (head config.services.printing.listenAddresses))))
    # Allow for jekyll temporary webserver
    4000
    # Allow for temporary python webserver
    8080
  ];
  networking.firewall.allowedUDPPorts = [
    # Allow for CUPS UDP
    (toInt (last (split ":" (head config.services.printing.listenAddresses))))
  ];

  # The following line to be uncommented for debugging
  # purposes as needed and activated with `nixos-rebuild test`
  #
  # networking.firewall.enable = false;

  networking.hostName = "nixos";
  networking.nameservers = [ "192.168.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager.appendNameservers = [ "192.168.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager.enable = true;
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Internationalization
  #
  time.timeZone = "America/New_York";
  i18n = {
    # For high DPI screens, use the following font:
    consoleFont = "latarcyrheb-sun32";

    # For regular DPI screens, use:
    # consoleFont = "Lat2-Terminus16";

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
    iotop

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
    noip
    nvtop
    pciutils
    smartmontools
    tcpdump
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
  services.nixops-dns.enable = true;
  services.nixops-dns.user = "jlotoski";
  services.openssh.enable = true;
  services.openssh.extraConfig = ''
    AllowUsers *@192.168.1.*
    # AllowUsers jlotoski@* backup@*
  '';
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";
  services.postfix.enable = true;
  services.postfix.setSendmail = true;
  services.printing.browsing = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.printing.enable = true;
  services.printing.listenAddresses = [ "localhost:631" ];

  # There is a bug with the NixOS psd version in Bash 4.4
  # See: https://github.com/NixOS/nixpkgs/issues/6576
  #
  # services.psd.enable = true;
  # services.psd.users = [ "jlotoski" "backup" ];

  services.sysstat.enable = true;

  # Teamviewer still needs be added to the users autostart
  # A KDE Windows Rule to minimize "TeamViewer" Window can be added
  # Under advanced TeamViewer options uncheck "Show Computers & Contacts on startup"
  #
  # services.teamviewer.enable = true;

  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";

  # Enable touchpad support
  #
  services.xserver.libinput.enable = true;

  # Enable this mode for Hybrid with no bumblebee or with discrete
  # (not currently needed)
  #
  services.xserver.videoDrivers = [ "intel" "nvidia" ];

  services.toxvpn = {
    enable = true;
    localip = "10.40.14.1";
  };

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
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.docker.enable = true;
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
    openssh.authorizedKeys.keys = [ secrets.sshAuthKey ];
  };

  users.users.backup = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "scanner" "wheel" "vboxusers" ];
    hashedPassword = secrets.hashedPassword;
    openssh.authorizedKeys.keys = [ secrets.sshAuthKey ];
  };

  # Optimization parameters for xmr-stak:
  #
  security.pam.loginLimits = [ { domain = "*"; item = "memlock"; type = "hard"; value = "262144"; }  { domain = "*"; item = "memlock"; type = "soft"; value = "262144"; } ];

  security.sudo.wheelNeedsPassword = true;
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Misc
  #
  hardware.bluetooth.enable = true;
  # hardware.bumblebee.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.sane.enable = true;

  # The sane backend defined at the top and called below is from:
  # https://github.com/pjones/nix-utils/blob/master/pkgs/drivers/brother-dsseries.nix
  # This enables the Brother DS-620 scanner to work.  The deb binary was
  # obtained from the following location after accepting the EULA:
  # http://support.brother.com/g/b/downloadend.aspx?c=us_ot&lang=en&prod=ds620_all&os=128&dlid=dlf100976_000&flang=4&type3=566&dlang=true
  #
  hardware.sane.extraBackends = [ brotherDSSeries ];

  sound.enable = true;
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # Nix Specific Config
  #
  nix.binaryCaches = [ "https://hydra.iohk.io" "https://cache.nixos.org/" ];
  nix.binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  nix.trustedUsers = [ "root" "jlotoski" ];
  #
  # --------------------------------------------------


  # --------------------------------------------------
  # NixOS Versioning
  #
  system.stateVersion = "19.03";
  #
  # --------------------------------------------------
}
