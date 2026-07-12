{
  pkgs,
  lib,
  ...
}:
with builtins;
with lib; {
  # Hint Electron/Chromium apps (Slack, Zoom, Brave, jumpcloud, ...) to run
  # natively on Wayland instead of XWayland. Note: native-Wayland windows are
  # not reachable by xdotool/XTEST, so use the ydotool typing backend for tools
  # that inject keystrokes (e.g. Handy dictation).
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs = {
    bat.enable = true;

    ccache = {
      enable = true;
      cacheDir = "/var/cache/ccache";
    };

    direnv.enable = true;

    git-worktree-switcher.enable = true;

    mosh = {
      enable = true;

      # Handle the firewall in the common firewall rules and exclude ipv6
      openFirewall = false;
    };

    ssh.extraConfig = ''
      Host *
        ServerAliveInterval 300
        ServerAliveCountMax 2
    '';

    wavemon.enable = true;

    xwayland.enable = true;

    ydotool.enable = true;

    zoxide.enable = true;
  };

  services = {
    angrr = {
      enable = true;
      timer.enable = true;
    };

    atd.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;

      # Handle the firewall in the common firewall rules and exclude ipv6
      ipv6 = false;
      openFirewall = false;
    };

    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    desktopManager.plasma6.enable = true;

    displayManager.sddm.enable = true;

    eternal-terminal = {
      enable = true;
      port = 2022;
    };

    libinput.enable = true;

    locate.enable = true;

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    netdata.enable = true;

    nscd.enableNsncd = true;

    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };

      extraConfig = ''
        AllowUsers *@192.168.* jlotoski@* backup@* builder@*
      '';
    };

    postfix = {
      enable = true;
      setSendmail = true;
    };

    # postgresql = {
    #   enable = true;

    #   identMap = ''
    #     admin-user jlotoski postgres
    #     admin-user backup postgres
    #     admin-user postgres postgres
    #     admin-user root postgres
    #   '';

    #   authentication = ''
    #     local all all ident map=admin-user
    #   '';

    #   settings = {
    #     max_connections = 200;
    #     log_statement = "all";
    #     logging_collector = "on";
    #   };
    # };

    printing = {
      browsing = true;
      drivers = [(pkgs.callPackage ../pkgs/mfcl3780cdw.nix {}).cupswrapper];
      enable = true;
      listenAddresses = ["localhost:631"];
    };

    resolved.enable = true;

    sysstat.enable = true;

    tailscale.enable = true;

    udev.extraRules = ''
      # TP-Link USB WiFi Adapter, model: TL-WN725N
      SUBSYSTEM=="net", ACTION=="add", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8179", NAME="wifi-tplink"

      # HW.1, Nano
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c|2b7c|3b7c|4b7c", TAG+="uaccess", TAG+="udev-acl"

      # Blue, NanoS, Aramis, HW.2, Nano X, NanoSP, Stax, Ledger Test,
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", TAG+="uaccess", TAG+="udev-acl"

      # Same, but with hidraw-based library (instead of libusb)
      KERNEL=="hidraw*", ATTRS{idVendor}=="2c97", MODE="0666"
    '';

    vnstat.enable = true;
  };
}
