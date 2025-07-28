{disks ? ["/dev/nvme0n1" "/dev/nvme1n1"], ...}: {
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = [
            {
              name = "ESP";
              type = "EF00";
              start = "0%";
              end = "1GiB";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            }
            {
              name = "zfs";
              type = "BF01";
              start = "1GiB";
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
          type = "gpt";
          partitions = [
            {
              name = "RECOVERY";
              type = "EF00";
              start = "0%";
              end = "1GiB";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/recovery";
                mountOptions = ["umask=0077"];
              };
            }
            {
              name = "zfs";
              type = "BF01";
              start = "1GiB";
              end = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            }
          ];
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          acltype = "posixacl";
          xattr = "sa";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };

          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
            };
          };

          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };

          var = {
            type = "zfs_fs";
            mountpoint = "/var";
          };

          "var/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
          };
        };
      };

      storage = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "/storage";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          acltype = "posixacl";
          xattr = "sa";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
      };
    };
  };
}
