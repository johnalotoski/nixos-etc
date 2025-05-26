{
  config,
  pkgs,
  ...
}: {
  nix.settings.extra-sandbox-paths = [config.programs.ccache.cacheDir];

  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  environment.systemPackages = [pkgs.ccache];
}
