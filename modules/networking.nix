{...}: {
  services.nscd.enableNsncd = true;
  services.resolved = {
    enable = true;
    extraConfig = "Domains=~.";
  };
}
