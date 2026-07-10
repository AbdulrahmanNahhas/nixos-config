{ lib, ... }:
{
  preservation = {
    enable = true;

    preserveAt."/saved" = {
      files = [
        # System machine-id
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }
        # SSH host keys
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          how = "symlink";
          configureParent = true;
        }
        # Systemd random seed
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
        # Git global config
        {
          file = "/home/aqua/.gitconfig";
          how = "symlink";
        }

        # ── GNOME desktop state ──────────────────────────────
        {
          file = "/home/aqua/.config/dconf/user";
          how = "symlink";
          configureParent = true;
        }
      ];

      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        "/var/log"
        "/var/lib/flatpak"
        "/var/lib/bluetooth"
        "/var/lib/decky-loader"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/var/lib/kavita"
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
      ];

      users.aqua = {
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
          "Books"

          # ── Identity / Secrets ───────────────────────────────
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".gnupg";
            mode = "0700";
          }

          # ── Git & Forge CLI Tools ────────────────────────────
          ".config/gh"
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }

          # ── Web Browser ──────────────────────────────────────
          {
            directory = ".config/zen";
            mode = "0700";
          } # Zen history, profile, workspace setups, and cookies
          {
            directory = ".cache/zen";
            mode = "0700";
          } # Zen web cache (stops sites from lagging on a fresh reboot)

          # ── Flatpak Application Data ─────────────────────────
          ".var"

          # ── Editor / IDE State ───────────────────────────────
          ".local/share/zed"
          ".config/zed"
          ".config/nvim"
          ".local/state/nvim"

          # ── Shell History & State ────────────────────────────
          ".config/fish"
          ".local/share/fish"
          ".local/state/nix"
          ".config/atuin"
          ".local/share/atuin" # Atuin history database

          # ── Niri & Noctalia State ────────
          ".config/niri"
          ".config/noctalia"
          ".local/share/noctalia"
          ".cache/noctalia"

          # ── Audio Per-App State ──────────────────────────────
          ".local/state/wireplumber" # Audio volumes and default device selections
          ".local/state/pipewire"

          # ── Obsidian ─────────────────────────────────────────
          ".config/obsidian" # App preferences. Note: Vaults live in ~/Documents

          # ── OpenCode Workspace ───────────────────────────────
          ".config/opencode"
          ".local/share/opencode"
          ".config/ai.opencode.desktop"
          ".local/share/Steam"
          ".steam"
          ".config/openrazer"
          ".local/share/openrazer"
          ".config/polychromatic"
          ".local/share/polychromatic"
        ];
      };
    };
  };

  # Set up base directories with appropriate user ownership before app creation loops.
  systemd.tmpfiles.settings.preservation = {
    "/home/aqua/.config".d = {
      user = "aqua";
      group = "users";
      mode = "0755";
    };
    "/home/aqua/.config/dconf".d = lib.mkForce {
      user = "aqua";
      group = "users";
      mode = "0755";
    };
    "/home/aqua/.local".d = {
      user = "aqua";
      group = "users";
      mode = "0755";
    };
    "/home/aqua/.local/share".d = {
      user = "aqua";
      group = "users";
      mode = "0755";
    };
    "/home/aqua/.local/state".d = {
      user = "aqua";
      group = "users";
      mode = "0755";
    };

    # Isolated secret runtime directory used by explicit out-of-store home configurations.
    "/saved/secrets".d = {
      user = "aqua";
      group = "users";
      mode = "0700";
    };
  };

  # Commits the transient tmpfs machine-id down to the persistent /saved partition.
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      "/saved/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      "systemd-machine-id-setup --commit --root /saved"
    ];
  };
}
