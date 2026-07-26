{disks ? ["/dev/nvme0n1" "/dev/nvme1n1"], ...}: {
  # Single-disk ZFS root now; designed to be converted to a 2-way mirror later
  # by attaching a second identical NVMe drive with `zpool attach` (no pool
  # recreation required). See the notes at the bottom of this file.
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
              end = "1GiB";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            zfs = {
              type = "8300";

              # Deliberately NOT "100%": leave a small margin at the end of the
              # disk so a later `zpool attach` of a nominally "same size" second
              # drive does not fail if that drive is a few sectors smaller.
              end = "-128MiB";

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

        # Single-disk (stripe) vdev for now. Left unset intentionally; converting
        # to a mirror is done imperatively via `zpool attach` once the second
        # drive is installed (see notes below), not by re-running disko.

        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
        };

        options = {
          # Must match on the second drive at `zpool attach` time.
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
            options.atime = "off";
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

          docker = {
            type = "zfs_fs";
            mountpoint = "/var/lib/docker";
            options = {
              "com.sun:auto-snapshot" = "false";
              recordsize = "64K";
            };
          };

          # Free-space safety valve: a full ZFS pool becomes unwriteable (you
          # cannot even `rm`). This unmounted dataset reserves space that can be
          # released (lower/destroy the refreservation) to recover.
          reserved = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              mountpoint = "none";
              refreservation = "5G";
            };
          };
        };
      };
    };
  };

  # --- Converting to a mirror later (second identical NVMe as nvme1n1) --------
  #
  # 1. Replicate the partition table onto the new disk and give it fresh GUIDs:
  #      sudo sgdisk --backup=/tmp/zroot1.gpt /dev/nvme0n1
  #      sudo sgdisk --load-backup=/tmp/zroot1.gpt /dev/nvme1n1
  #      sudo sgdisk -G /dev/nvme1n1
  #
  #    -G randomizes the disk and partition GUIDs but NOT the partition names,
  #    so at this point both disks carry disk-zroot1-* labels and every
  #    /dev/disk/by-partlabel/disk-zroot1-* path is ambiguous -- including the
  #    one naming the *existing* device in step 2. Rename before proceeding.
  #    Partition 1 becomes the /recovery ESP copy that step 3 wants:
  #      sudo sgdisk -c 1:disk-zroot2-recovery -c 2:disk-zroot2-zfs /dev/nvme1n1
  #      sudo partprobe /dev/nvme1n1
  #      ls /dev/disk/by-partlabel/   # confirm zroot1-* and zroot2-* are distinct
  #
  # 2. Attach the new ZFS partition to the existing single-disk vdev (this makes
  #    it a mirror and resilvers; encryption carries over automatically):
  #      sudo zpool attach zroot \
  #        /dev/disk/by-partlabel/disk-zroot1-zfs \
  #        /dev/disk/by-partlabel/disk-zroot2-zfs
  #      sudo zpool status zroot   # watch resilver complete
  #
  # 3. Make the second ESP a bootable /recovery copy, then in hw-p16.nix add the
  #    second `mirroredBoots` entry (disk-zroot2-recovery -> /recovery), mirror
  #    the partition naming here to the p71 config, and rebuild.
  #
  # Note: after step 2 the running pool is a mirror even though this declarative
  # file still describes a single disk. disko only runs at (re)install, so this
  # file and the live pool diverge until you update it. Keeping ashift=12 and the
  # end margin above is what makes the attach reliable.
}
