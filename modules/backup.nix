{
  config,
  pkgs,
  secrets,
  lib,
  ...
}: let
  hostName = config.networking.hostName;
  defaultBorgSpec = {
    compression = "auto,lzma";
    startAt = "daily";
    prune = {
      keep = {
        within = "1w";
        daily = 7;
        weekly = 4;
        monthly = 60;
      };
    };
    environment = {
      BORG_REMOTE_PATH = "/usr/local/bin/borg1/borg1";
    };
    # Also `--debug`, ...
    extraArgs = "--info --progress";
  };
  extraBorgPaths = with pkgs; [
    nix
  ];
in
  with builtins;
  with lib; {
    services.borgbackup.jobs = mapAttrs (n: v:
      recursiveUpdate defaultBorgSpec (removeAttrs v ["borgSecret"]))
    secrets."${hostName}".borgBackupJobs;
    systemd.services = mapAttrs' (n: v:
      nameValuePair
      "borgbackup-job-${n}" {path = extraBorgPaths;})
    secrets."${hostName}".borgBackupJobs;
  }
