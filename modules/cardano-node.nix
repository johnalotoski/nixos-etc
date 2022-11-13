{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.services.cardano-node;
in {
  imports = [self.inputs.cardano-node.nixosModules.cardano-node];

  systemd.services.cardano-node.wantedBy = lib.mkForce [];

  services.cardano-node = {
    enable = true;
    environment = "mainnet";
  };
}
