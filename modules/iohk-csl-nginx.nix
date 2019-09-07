# This nginx configuration file serves a local Cardano-SL explorer frontend
# See the IOHK production setup at:
# https://github.com/input-output-hk/iohk-ops/blob/master/modules/cardano-explorer.nix
let
  secrets = import ../secrets/secrets.nix;
in {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "localhost" = {
        sslCertificate = "/home/${secrets.priUsr}/dev/www/nixnginx.crt";
        sslCertificateKey = "/home/${secrets.priUsr}/dev/www/nixnginx.key";
        addSSL = true;
        locations = {
          "/" = {
            root = "/home/${secrets.priUsr}/dev/www/cardano-sl-explorer-frontend";
          };
          "/api/".proxyPass = "http://127.0.0.1:8100";
          "/socket.io/".proxyPass = "http://127.0.0.1:8110";
        };
        # Otherwise nginx serves files with timestamps unixtime+1 from /nix/store
        extraConfig = ''
          if_modified_since off;
          add_header Last-Modified "";
          etag off;
        '';
      };
    };
    eventsConfig = ''
      worker_connections 1024;
    '';
    appendConfig = ''
      worker_processes 4;
      worker_rlimit_nofile 2048;
    '';
  };
}
