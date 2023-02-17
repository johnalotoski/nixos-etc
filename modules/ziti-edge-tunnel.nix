{self, ...}: {
  imports = [self.inputs.openziti.nixosModules.ziti-edge-tunnel];
  services.ziti-edge-tunnel = {
    enable = true;
    dnsUpstream = null;
  };
}
