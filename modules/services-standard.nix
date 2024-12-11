{
  self,
  pkgs,
  ...
}: {
  networking.firewall = {
    allowedTCPPorts = [2022];
  };

  programs = {
    mosh.enable = true;
    ssh.extraConfig = ''
      Host *
        ServerAliveInterval 300
        ServerAliveCountMax 2
    '';
  };

  services = {
    atd.enable = true;

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

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    netdata.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      extraConfig = ''
        AllowUsers *@192.168.* jlotoski@* builder@*
      '';
    };

    postfix = {
      enable = true;
      setSendmail = true;
    };

    printing = {
      browsing = true;
      drivers = [pkgs.hplip];
      enable = true;
      listenAddresses = ["localhost:631"];
    };

    sysstat.enable = true;

    vnstat.enable = true;

    xserver = {
      enable = true;
      exportConfiguration = true;
      xkb.layout = "us";
    };
  };
}
