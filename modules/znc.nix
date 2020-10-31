{ config, pkgs, secrets, ... }:
{
  services.znc = {
    enable = true;
    mutable = false;
    useLegacyConfig = false;
    openFirewall = true;
    config = {
      LoadModule = [ "adminlog" "lastseen" "webadmin" ];
      User.jlotoski-znc = {
        Admin = true;
        Nick = secrets.znc.nick;
        Pass.password = secrets.znc.users.jlotoski-znc;
        Network.freenode = {
          TrustAllCerts = true;
          Server = secrets.znc.priServer;
          Chan = {
            "#crystal-lang" = {};
            "#haskell.nix" = {};
            "#nixos" = {};
            "#nixos-darwin" = {};
            "#nixos-dev" = {};
            "#nixops" = {};
          };
          LoadModule = [ "nickserv" ];
          JoinDelay = 10;
        };
      };
      User.jlotoski-g76 = {
        StatusPrefix = "g76";
        Pass.password = secrets.znc.users.jlotoski-g76;
        Network.znc = {
          TrustedServerFingerprint = secrets.znc.trustedServerFingerprint;
          Server = secrets.znc.secServer;
          JoinDelay = 10;
        };
      };
      User.jlotoski-p71 = {
        StatusPrefix = "p71";
        Pass.password = secrets.znc.users.jlotoski-p71;
        Network.znc = {
          TrustedServerFingerprint = secrets.znc.trustedServerFingerprint;
          Server = secrets.znc.secServer;
          JoinDelay = 10;
        };
      };
      User.jlotoski-lg = {
        StatusPrefix = "lg";
        Pass.password = secrets.znc.users.jlotoski-lg;
        Network.znc = {
          TrustedServerFingerprint = secrets.znc.trustedServerFingerprint;
          Server = secrets.znc.secServer;
          JoinDelay = 10;
        };
      };
    };
  };
}
