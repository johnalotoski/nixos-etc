# 610.43.03 nvidia driver from nixpkgs master, newer than the 595 that
# nixos-26.05 ships. That 595 default faults on this fleet's recent GPUs,
# Blackwell on p16 and Ada on serval. Built against the local kernel via
# mkDriver. Imported only by those machines; p71 stays on legacy for Pascal.
# Hashes from nixpkgs master nvidia-x11 default.nix, new_feature block.
{config, ...}: {
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "610.43.03";
    sha256_64bit = "sha256-ReLUwTSiPDXlDyU6SqY+fl6NF+PRhdSgfIpY6WEu05I=";
    sha256_aarch64 = "sha256-jSdlXo60ilXLKWKvZfgbBnVqVYuw6zhnGuiDgwxYz94=";
    openSha256 = "sha256-QCXmqo2xNyIwjGv0da2MUC8ex641Mmc5DUI+uRFVwgE=";
    settingsSha256 = "sha256-z/t+SdEQdVJPwjKIRHO02d264Kt47eWiOwwsaxmh4xQ=";
    persistencedSha256 = "sha256-sOKUsAFHh0/COH+nNgbH9+7hWgivOzq4YmTuk9MOFfI=";
  };
}
