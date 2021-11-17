{ secrets, ... }:
{
  services.postgresql = {
    enable = true;
    identMap = ''
      admin-user ${secrets.priUsr} postgres
      admin-user ${secrets.secUsr} postgres
      admin-user postgres postgres
      admin-user root postgres
    '';
    authentication = ''
      local all all ident map=admin-user
    '';
    settings = {
      max_connections = 200;
      log_statement = "all";
      logging_collector = "on";
    };
  };
}
