{ config, pkgs, secrets, ... }:
{
  programs.mosh.enable = true;
  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;
  services.fstrim.enable = true;
  services.netdata.enable = true;
  services.nixops-dns.enable = true;
  services.nixops-dns.user = "${secrets.priUsr}";
  services.openssh.enable = true;
  services.openssh.extraConfig = ''
    AllowUsers *@192.168.* ${secrets.priUsr}@*
  '';
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";
  services.postfix.enable = true;
  services.postfix.setSendmail = true;
  services.printing.browsing = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.printing.enable = true;
  services.printing.listenAddresses = [ "localhost:631" ];
  services.sysstat.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
}
