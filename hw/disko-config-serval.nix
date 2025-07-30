{disks ? ["/dev/nvme0n1" "/dev/nvme1n1"], ...}: {
  disko.devices = {
    disk = {
      zroot1 = {
        type = "disk";
        device = builtins.elemAt disks 0;

        content = {
          type = "gpt";

          partitions = {
            esp = {
              type = "EF00";
              start = "0%";
              end = "512MiB";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            zfs = {
              type = "8300";
              size = "100%";

              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };

      zroot2 = {
        type = "disk";
        device = builtins.elemAt disks 1;
        content = {
          type = "gpt";

          partitions = {
            recovery = {
              type = "EF00";
              start = "0%";
              end = "512MiB";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/recovery";
                mountOptions = ["nofail"];
              };
            };

            zfs = {
              type = "8300";
              size = "100%";

              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
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
          keylocation = "prompt";
        };

        options = {
          ashift = "13";
          autotrim = "on";
        };

        mountpoint = "/";

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
