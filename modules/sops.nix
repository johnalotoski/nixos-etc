{self, ...}: {
  imports = [self.inputs.sops-nix.nixosModules.sops];

  sops.defaultSopsFile = ../secrets.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets = {
  };
}
