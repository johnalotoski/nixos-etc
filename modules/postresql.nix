{ config, pkgs, ... }:
let
  secrets = import ../secrets/secrets.nix;
in {
  disabledModules = [ "services/databases/postgresql.nix" ];
  imports = [ ../imports/postgresql.nix ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "explorer_python_api" ];
    ensureUsers = [
      {
        name = "${secrets.priUsr}";
        ensurePermissions = {
          "DATABASE explorer_python_api" = "ALL PRIVILEGES";
        };
      }
    ];
    extraConfig = ''
      # Optimized for:
      # DB Version: 9.6
      # OS Type: linux
      # DB Type: web
      # Total Memory (RAM): 8 GB
      # Data Storage: ssd

      max_connections = 200
      shared_buffers = 2GB
      effective_cache_size = 6GB
      maintenance_work_mem = 512MB
      checkpoint_completion_target = 0.7
      wal_buffers = 16MB
      default_statistics_target = 100
      random_page_cost = 1.1
      effective_io_concurrency = 200
      work_mem = 10485kB
      min_wal_size = 1GB
      max_wal_size = 2GB
    '';
    identMap = ''
      explorer-users ${secrets.priUsr} explorer_python_api
      explorer-users postgres postgres
    '';
    authentication = ''
      # Docker pgadmin:
      # docker run -d -v /tmp:/tmp/postgres -p 5050:5050 --name pgadmin4 thajeztah/pgadmin
      local all all ident map=explorer-users
    '';
  };
}
