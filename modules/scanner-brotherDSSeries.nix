{pkgs, ...}: {
  # The sane backend is from:
  # https://github.com/pjones/nix-utils/blob/master/pkgs/drivers/brother-dsseries.nix
  # This enables the Brother DS-620 scanner to work.  The deb binary was
  # obtained from the following location after accepting the EULA:
  # http://support.brother.com/g/b/downloadend.aspx?c=us_ot&lang=en&prod=ds620_all&os=128&dlid=dlf100976_000&flang=4&type3=566&dlang=true
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [(pkgs.callPackage ../pkgs/brother-dsseries.nix {})];
}
