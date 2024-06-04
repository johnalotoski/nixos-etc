{
  self,
  config,
  lib,
  ...
}: let
  cardanoPkgs = {
    cardano-node = self.inputs.capkgs.packages.x86_64-linux.cardano-node-input-output-hk-cardano-node-8-9-3-e7f5f3a;
    cardano-cli = self.inputs.capkgs.packages.x86_64-linux.cardano-cli-input-output-hk-cardano-node-8-9-3-e7f5f3a;
    db-analyser = self.inputs.capkgs.packages.x86_64-linux.db-analyser-input-output-hk-cardano-node-8-9-3-e7f5f3a;
    db-synthesizer = self.inputs.capkgs.packages.x86_64-linux.db-synthesizer-input-output-hk-cardano-node-8-9-3-e7f5f3a;
    db-truncater = self.inputs.capkgs.packages.x86_64-linux.db-truncater-input-output-hk-cardano-node-8-9-3-e7f5f3a;
  };
in {
  imports = ["${self.inputs.cardano-node}/nix/nixos"];

  systemd.services.cardano-node.wantedBy = lib.mkForce [];

  environment.variables = {
    CARDANO_NODE_SOCKET_PATH = "/run/cardano-node/node.socket";
    CARDANO_NODE_NETWORK_ID = "764824073";
    TESTNET_MAGIC = "764824073";
  };

  environment.systemPackages = with cardanoPkgs; [
    cardano-cli
    cardano-node
    db-analyser
    db-synthesizer
    db-truncater
  ];

  services.cardano-node = {
    enable = true;
    environment = "mainnet";
    useNewTopology = true;
    hostAddr = "0.0.0.0";
  };

  systemd.services.cardano-node = {
    postStart = ''
      while true; do
        if [ -S /run/cardano-node/node.socket ]; then
          chmod go+w /run/cardano-node/node.socket
          exit 0
        fi
        sleep 5
      done
    '';

    serviceConfig.TimeoutStartSec = "infinity";
  };
}
