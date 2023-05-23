{ disks ? [ "/dev/nvme0n1" "/dev/nvme1n1" "/dev/sda" ], ... }: {
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "0%";
              end = "512MiB";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "zfs";
              start = "512MiB";
              end = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            }
          ];
        };
      };
      y = {
        type = "disk";
        device = builtins.elemAt disks 1;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "RECOVERY";
              start = "0%";
              end = "512MiB";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/recovery";
              };
            }
            {
              name = "zfs";
              start = "512MiB";
              end = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            }
          ];
        };
      };
      z = {
        type = "disk";
        device = builtins.elemAt disks 2;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "btrfs";
              start = "0%";
              end = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/storage" = {};
                };
              };
            }
          ];
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
          acltype = "posixacl";
          xattr = "sa";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
        };
        options = {
          ashift = "13";
          autotrim = "on";
        };
        mountpoint = "/";
        postCreateHook = ''
          zfs set keylocation="prompt" "zroot"
          zfs snapshot zroot@blank
        '';
        datasets = {
          znix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
            };
          };
        };
      };
    };
  };
}

