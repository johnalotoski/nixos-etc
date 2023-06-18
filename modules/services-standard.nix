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
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    eternal-terminal = {
      enable = true;
      port = 2022;
    };

    mullvad-vpn.enable = true;

    netdata.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      extraConfig = ''
        AllowUsers *@192.168.* jlotoski@*
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
      desktopManager.plasma5.enable = true;
      displayManager.sddm.enable = true;
      enable = true;
      exportConfiguration = true;
      layout = "us";
      libinput.enable = true;
    };

    ziti-edge-tunnel.enable = true;
  };
}
