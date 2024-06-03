{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    pdfarranger
    sane-airscan
    simple-scan
    xsane
  ];

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [hplipWithPlugin sane-airscan];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
