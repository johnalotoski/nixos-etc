{...}: {
  imports = [
    ../hw/hw-p16.nix
    ../modules/ai-claude.nix
    ../modules/ai-codex.nix
    ../modules/ai-common.nix
    ../modules/ai-gemini.nix

    # RTX PRO 1000 Blackwell (GB207GLM) is Blackwell, compute capability 12.0.
    # 8 GB of VRAM: q8_0 KV halves the cache, and 32k fits in roughly 5 GB
    # total. Headroom depends on how much the desktop itself is using -- see
    # the PRIME note in hw-p16.nix; under Plasma Wayland the compositor has
    # been observed on the iGPU, leaving the card nearly free.
    (import ../modules/ai-llama-server.nix {
      cudaArchitectures = "120";
      cudaPackages = "cudaPackages_13";
      ctxSize = 32768;
      quantizeKvCache = true;
      heavyModel = true;
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
    xserver.videoDrivers = ["nvidia"];

    # ZFS maintenance. Both trim paths are deliberate and not redundant:
    # pool-level autotrim (disko-config-p16.nix) batches freed space and
    # defers small ranges, while the weekly zpool trim below is the catch-all
    # for what it skips. trim.enable already defaults to true -- stated
    # explicitly so the behaviour is visible rather than inherited. The scrub
    # matters most once this is a mirror and can self-heal.
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };

  networking = {
    hostId = "3596774c";
    hostName = "nixos-p16";
  };

  system.stateVersion = "26.05";
}
