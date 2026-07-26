{...}: {
  imports = [
    ../hw/hw-p71.nix
    ../modules/ai-claude.nix
    ../modules/ai-codex.nix
    ../modules/ai-common.nix
    ../modules/ai-gemini.nix
    ../modules/bitwarden-extension.nix

    # Quadro P3000 is Pascal, compute capability 6.1. Pinned to CUDA 12
    # explicitly: 12.9 is Pascal's last supported release, so this cannot
    # follow the other machines up to 13.
    (import ../modules/ai-llama-server.nix {
      cudaArchitectures = "61";
      cudaPackages = "cudaPackages_12";
    })

    ../modules/cardano-ignite.nix
    ../modules/common.nix
    ../modules/distributed-builds.nix
    ../modules/git.nix
    ../modules/gnupg.nix
    ../modules/hidpi.nix
    ../modules/screen.nix
    ../modules/services-standard.nix
    ../modules/shell.nix
    ../modules/system-packages.nix
    ../modules/users-standard.nix
    ../modules/yubikey.nix
  ];

  services = {
    tunnelbroker.enable = true;
    xserver.videoDrivers = ["nvidia"];
  };

  networking = {
    hostId = "35c02924";
    hostName = "nixos-p71";
  };

  system.stateVersion = "22.11";
}
