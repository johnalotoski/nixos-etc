{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../hw/hw-serval.nix
    # ../modules/backup.nix
    ../modules/cardano-node.nix
    # ../modules/cuda.nix
    ../modules/db.nix
    ../modules/exodus.nix
    # ../modules/fax.nix
    ../modules/firewall.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hp-envy-5000-aio.nix
    ../modules/hw.nix
    ../modules/intl.nix
    ../modules/lorri.nix
    # ../modules/nas.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/nvidia-fix.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/sops.nix
    ../modules/system-packages.nix
    ../modules/tailscale.nix
    ../modules/users-standard.nix
    ../modules/virtualization.nix
    ../modules/vim.nix
    ../modules/yubikey.nix
    ../modules/zfs.nix
  ];

  # services.power-profiles-daemon.enable = false;
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = {
  #     governor = "powersave";
  #     turbo = "never";
  #   };
  #   charger = {
  #     # governor = "performance";
  #     # turbo = "auto";
  #     governor = "powersave";
  #     turbo = "never";
  #   };
  # };

  ### KERNEL
  # boot.kernelParams = [
  #   "ahci.mobile_lpm_policy=3"
  #   "rtc_cmos.use_acpi_alarm=1"
  # ];

  # ### HWP
  # systemd.tmpfiles.rules = [
  #   "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
  # ];

  # ### TLP
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     # CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_AC = "powersave";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

  #     # CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "power";
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

  #     # PLATFORM_PROFILE_ON_AC = "performance";
  #     PLATFORM_PROFILE_ON_AC = "low_power";
  #     PLATFORM_PROFILE_ON_BAT = "low-power";

  #     # CPU_BOOST_ON_AC = 1;
  #     CPU_BOOST_ON_AC = 0;
  #     CPU_BOOST_ON_BAT = 0;

  #     # CPU_HWP_DYN_BOOST_ON_AC = 1;
  #     CPU_HWP_DYN_BOOST_ON_AC = 0;
  #     CPU_HWP_DYN_BOOST_ON_BAT = 0;

  #     #CPU_MIN_PERF_ON_AC = 0;
  #     #CPU_MAX_PERF_ON_AC = 100;
  #     #CPU_MIN_PERF_ON_BAT = 0;
  #     #CPU_MAX_PERF_ON_BAT = 20;

  #     #Optional helps save long term battery health
  #     START_CHARGE_THRESH_BAT0 = 60; # 60 and below it starts to charge
  #     STOP_CHARGE_THRESH_BAT0 = 90; # 90 and above it stops charging
  #   };
  # };

  # ### SYSTEM 76 SCHEDULER
  # services.system76-scheduler.settings.cfsProfiles.enable = true;

  # ### POWERTOP
  # #powerManagement.powertop.enable = true;

  # ### ThermalD
  # services.thermald.enable = true;

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "wlp0s20f3";
    # Backup USB nic, front slot:
    # externalInterface = "wlp0s20f0u2";
  };

  services = {
    pulseaudio = {
      support32Bit = true;
      extraConfig = ''
        load-module module-card-restore restore_bluetooth_profile=true
        load-module module-bluetooth-policy auto_switch=false
        load-module module-bluetooth-discover headset=auto
      '';
    };

    xserver = {
      exportConfiguration = true;
      videoDrivers = ["nvidia"];
    };
  };

  hardware.nvidia = {
    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  hardware.nvidia.open = true;

  networking.hostName = "nixos-serval";
  networking.hostId = "d8fcf199";
  networking.wireless.interfaces = ["wlp0s20f3"];
  # Backup USB nic, front slot:
  # networking.wireless.interfaces = ["wlp0s20f0u2"];

  system.stateVersion = "23.05";
}
