# disko.nix — tmpfs root + LUKS + btrfs
{
  disko.devices = {

    # ── tmpfs root ──────────────────────────────────────────────────────────
    # The entire / is RAM — wiped clean on every reboot.
    # Only /nix and /saved survive reboots (btrfs subvols below).
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"   # cap tmpfs at 4 GiB; bump higher only if you run memory-hungry daemons in /
        "mode=755"
      ];
    };

    disk.main = {
      type   = "disk";
      device = "/dev/nvme0n1";

      content = {
        type = "gpt";

        partitions = {

          # ── EFI System Partition ─────────────────────────────────────────
          ESP = {
            priority = 1;
            name     = "ESP";
            size     = "1G";
            type     = "EF00";
            content  = {
              type       = "filesystem";
              format     = "vfat";
              mountpoint = "/boot";
              # umask=0077 keeps the ESP readable only by root; x-gvfs-hide
              # stops GNOME Files from listing the ESP as a removable device.
              mountOptions = [ "umask=0077" "x-gvfs-hide" ];
            };
          };

          # ── LUKS2 encrypted container (rest of disk) ─────────────────────
          luks = {
            size    = "100%";
            content = {
              type = "luks";
              name = "crypted";

              settings = {
                allowDiscards = true; # enables SSD TRIM through LUKS
                # For TPM2 auto-unlock later, add:
                # crypttabExtraOpts = [ "tpm2-device=auto" ];
              };

              content = {
                type      = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {

                  # Nix store — large, read-heavy, never wiped
                  "/nix" = {
                    mountpoint   = "/nix";
                    # x-gvfs-hide keeps /nix out of the GNOME Files sidebar.
                    mountOptions = [ "compress=zstd" "noatime" "x-gvfs-hide" ];
                  };

                  # Your persistence layer — everything you explicitly keep.
                  # x-gvfs-hide so /saved never appears as a mounted drive.
                  "/saved" = {
                    mountpoint   = "/saved";
                    mountOptions = [ "compress=zstd" "noatime" "x-gvfs-hide" ];
                  };

                  # Swap as a btrfs swapfile.
                  # Size = full RAM (16G) so suspend-to-disk / hibernate is possible.
                  # Use RAM/2 if you only care about suspend-to-RAM.
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
  fileSystems."/nix".neededForBoot        = true;
  fileSystems."/saved".neededForBoot = true;
}
