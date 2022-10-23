{ ... }:
{
  imports = [ "${(import ../nix/sources.nix).sops-nix}/modules/sops" ];

  sops.defaultSopsFile = ../secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = {
  };
}
