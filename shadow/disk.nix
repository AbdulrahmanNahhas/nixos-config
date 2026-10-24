# tmpfs root + LUKS + btrfs
{
  disko.devices = {

    # tmpfs root
    # Root resets on reboot; /nix, /saved, /swap and the ESP persist.
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"
        "mode=755"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";

      content = {
        type = "gpt";

        partitions = {

          # EFI System Partition
          ESP = {
            priority = 1;
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "umask=0077"
                "x-gvfs-hide"
              ];
            };
          };

          # LUKS2 encrypted container (rest of disk)
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";

              settings = {
                # Allow SSD TRIM through LUKS; leaks allocation patterns, not plaintext.
                allowDiscards = true;
                # TPM unlock needs measured-boot policy and an independent recovery key.
              };

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {

                  # Nix store — large, read-heavy, never wiped
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "x-gvfs-hide"
                    ];
                  };

                  "/saved" = {
                    mountpoint = "/saved";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "x-gvfs-hide"
                    ];
                  };

                  # Encrypted zRAM overflow; hibernation needs separate resume setup.
                  "/swap" = {
                    mountpoint = "/swap";
                    mountOptions = [ "x-gvfs-hide" ];
                    swap.swapfile.size = "16G";
                  };

                };
              };
            };
          };

        };
      };
    };
  };

  # Tell NixOS these must be mounted before pivot_root
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/saved".neededForBoot = true;
}
