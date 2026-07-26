{...}: {
  imports = [
    ../hw/hw-serval.nix
    ../modules/ai-claude.nix
    ../modules/ai-codex.nix
    ../modules/ai-common.nix
    # ../modules/ai-gemini.nix

    # RTX 40-series laptop GPU is Ada, compute capability 8.9.
    # 8 GB of VRAM, same budget as p16.
    (import ../modules/ai-llama-server.nix {
      cudaArchitectures = "89";
      cudaPackages = "cudaPackages_13";
      ctxSize = 32768;
      quantizeKvCache = true;
      heavyModel = true;
    })

    ../modules/blacklist-dvb.nix
    ../modules/cardano-ignite.nix
    ../modules/common.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/yubikey.nix
  ];

  services.xserver.videoDrivers = ["nvidia"];

  networking = {
    hostId = "d8fcf199";
    hostName = "nixos-serval";
  };

  system.stateVersion = "23.05";
}
