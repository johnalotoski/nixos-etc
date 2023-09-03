{
  self,
  config,
  lib,
  ...
}: let
  cardanoPkgs = self.inputs.cardano-node.packages.x86_64-linux;
in {
  imports = [self.inputs.cardano-node.nixosModules.cardano-node];

  systemd.services.cardano-node.wantedBy = lib.mkForce [];

  environment.variables = {
    CARDANO_NODE_SOCKET_PATH = "/run/cardano-node/node.socket";
  };

  environment.systemPackages = with cardanoPkgs; [
    cardano-cli
    cardano-node
    db-analyser
    db-synthesizer
    # Not until 8.2.1
    # db-truncater
  ];

  services.cardano-node = {
    enable = true;
    environment = "mainnet";
    useNewTopology = true;
    hostAddr = "0.0.0.0";
  };
}
