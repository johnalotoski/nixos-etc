{...}: {
  services.ddclient = {
    enable = true;
    # Following commented lines to generate the initial conf file:
    # domains = secrets.nixos-p71.ddclientDomains;
    # username = secrets.nixos-p71.ddclientUser;
    # password = secrets.nixos-p71.ddclientSecret;
    # server = secrets.nixos-p71.ddclientServer;

    # That conf file then moved outside the nix store:
    configFile = "/etc/nixos/secrets/ddclient.conf";
  };
}
