{ config, pkgs, ... }:
{
  _module.args.secrets = import ../secrets/secrets.nix;
}
