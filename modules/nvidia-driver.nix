# Production R620 for Serval's Ada GPU, matching the P16 driver pin.
# Hashes from the nixpkgs nvidia-x11 production driver, as pinned in hw/hw-p16.nix.
{config, ...}: {
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "620.73.04";
    sha256_64bit = "sha256-tfLi1dqENbMlOTBAFbib9+si/grsjNaQW3puip+bjxs=";
    sha256_aarch64 = "sha256-45QZFS3Hs9hN4tKRrfmripADVpZQqksB7pAEZaS+XkA=";
    openSha256 = "sha256-+GPU2bXC/QWZTt0eH3dTvI0bMAta1GCdU2WFI4E4LWE=";
    settingsSha256 = "sha256-Wrv0F7Eo9X/0Xv5DclI9aIe3FcRtbu9okQJuWBjL8es=";
    persistencedSha256 = "sha256-QOndl1q7veD5aB6AfEe0/K2QHR8+ftLsei/aQrUCN3Q=";
  };
}
