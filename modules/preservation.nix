# preservation.nix — /saved is the persistent btrfs subvolume
#
# The root filesystem (`/`) is tmpfs; anything NOT listed here is lost on reboot.
# Add folders/files here when introducing new software requiring persistent state.
{ ... }:
{
  preservation = {
    enable = true;

    preserveAt."/saved" = {
      files = [
        # System machine-id — survives reboots for journald, machinectl, NetworkManager.
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }

        # SSH host keys — prevents remote clients getting "host key changed" warnings.
        { file = "/etc/ssh/ssh_host_ed25519_key";     how = "symlink"; configureParent = true; }
        { file = "/etc/ssh/ssh_host_ed25519_key.pub"; how = "symlink"; configureParent = true; }

        # Systemd random seed — prevents entropy pool stalling on system boot.
        { file = "/var/lib/systemd/random-seed"; how = "symlink"; inInitrd = true; configureParent = true; }

        # Git global config — user details and global settings.
        { file = "/home/aqua/.gitconfig"; how = "symlink"; }

        # ── GNOME desktop state ──────────────────────────────
        # dconf uses a single binary database file to store all runtime state.
        # Persisting via symlink avoids bind-mount locks when Home Manager writes to it.
        { file = "/home/aqua/.config/dconf/user"; how = "symlink"; configureParent = true; }
      ];

      directories = [
        { directory = "/var/lib/nixos"; inInitrd = true; }
        "/var/log"
        "/var/lib/flatpak"
        "/var/lib/bluetooth"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/etc/NetworkManager/system-connections"
      ];

      users.aqua = {
        # Hides per-user bind mounts from gvfs/GNOME Files to prevent duplicate sidebar items.
        commonMountOptions = [ "x-gvfs-hide" ];

        directories = [
          # ── XDG User Directories ─────────────────────────────
          "Desktop"
          "Documents"
          "Music"
          "Pictures"
          "Projects"
          "Public"
          "Templates"
          "Videos"

          # ── Identity / Secrets ───────────────────────────────
          { directory = ".ssh";   mode = "0700"; }
          { directory = ".gnupg"; mode = "0700"; }

          # ── Git & Forge CLI Tools ────────────────────────────
          ".config/gh" # GitHub CLI auth state
          { directory = ".local/share/keyrings"; mode = "0700"; } # GNOME Keyring credentials

          # ── Web Browser ──────────────────────────────────────
          { directory = ".mozilla"; mode = "0700"; } # Firefox history, profile, and cookies

          # ── Flatpak Application Data ─────────────────────────
          ".var" # Flatpak app state (Signal, Telegram, Vesktop, Fractal, Tuba, etc.)

          # ── Editor / IDE State ───────────────────────────────
          ".local/share/zed" # Zed login tokens, workspace database, and histories
          ".config/zed"
          ".config/nvim"
          ".local/state/nvim"

          # ── Shell History & State ────────────────────────────
          ".config/fish"
          ".local/share/fish" # Shell interactive history
          ".local/state/nix"
          ".config/atuin"
          ".local/share/atuin" # Atuin history database

          # ── Audio Per-App State ──────────────────────────────
          ".local/state/wireplumber" # Audio volumes and default device selections
          ".local/state/pipewire"

          # ── Obsidian ─────────────────────────────────────────
          ".config/obsidian" # App preferences. Note: Vaults live in ~/Documents

          # ── OpenCode Workspace ───────────────────────────────
          ".config/opencode"
          ".local/share/opencode"
          ".config/ai.opencode.desktop"
        ];
      };
    };
  };

  # Set up base directories with appropriate user ownership before app creation loops.
  systemd.tmpfiles.settings.preservation = {
    "/home/aqua/.config".d       = { user = "aqua"; group = "users"; mode = "0755"; };
    "/home/aqua/.local".d        = { user = "aqua"; group = "users"; mode = "0755"; };
    "/home/aqua/.local/share".d  = { user = "aqua"; group = "users"; mode = "0755"; };
    "/home/aqua/.local/state".d  = { user = "aqua"; group = "users"; mode = "0755"; };

    # Isolated secret runtime directory used by explicit out-of-store home configurations.
    "/saved/secrets".d           = { user = "aqua"; group = "users"; mode = "0700"; };
  };

  # Commits the transient tmpfs machine-id down to the persistent /saved partition.
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/saved/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /saved"
    ];
  };
}
