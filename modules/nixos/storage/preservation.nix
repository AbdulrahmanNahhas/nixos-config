{
  config,
  lib,
  username,
  ...
}:
let
  flatpakApps = import ../services/flatpak-apps.nix;
in
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
      ]
      ++ lib.optionals config.services.openssh.enable [
        # Preserve a stable host identity whenever the SSH server is enabled.
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
      ]
      ++ [
        # Systemd random seed
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
        # Git global config
        {
          file = "/home/${username}/.gitconfig";
          how = "symlink";
        }

        # GTK application settings
        {
          file = "/home/${username}/.config/dconf/user";
          how = "symlink";
          configureParent = true;
        }
      ];

      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        "/var/lib/flatpak"
        {
          directory = "/var/lib/bluetooth";
          user = "root";
          group = "root";
          mode = "0700";
        }

        {
          # Retain the greeter’s selected user and session.
          directory = "/var/cache/tuigreet";
          user = "greeter";
          group = "greeter";
          mode = "0755";
        }
        "/var/lib/systemd/timers"
        # Retain scrub results and the selected power profile.
        "/var/lib/btrfs"
        "/var/lib/power-profiles-daemon"
        {
          directory = "/var/lib/smartmontools";
          user = "root";
          group = "root";
          mode = "0700";
        }
        {
          directory = "/var/log/journal";
          user = "root";
          group = "systemd-journal";
          mode = "2755";
        }
        "/var/lib/kavita"
        {
          # Persist private state; systemd manages the public link and runtime owner.
          directory = "/var/lib/private/dnscrypt-proxy";
          user = "root";
          group = "root";
          mode = "0755";
        }
        {
          # Stable network identity and internal state, separate from profiles.
          directory = "/var/lib/NetworkManager";
          user = "root";
          group = "root";
          mode = "0755";
        }
        {
          # iwd stores Wi-Fi credentials separately from NetworkManager profiles.
          directory = "/var/lib/iwd";
          user = "root";
          group = "root";
          mode = "0700";
        }
        {
          # Firmware-update history and pending-update bookkeeping.
          directory = "/var/lib/fwupd";
          user = "root";
          group = "root";
          mode = "0755";
        }
        {
          directory = "/etc/NetworkManager/system-connections";
          user = "root";
          group = "root";
          mode = "0700";
        }
      ];

      users.${username} = {
        commonMountOptions = [ "x-gvfs-hide" ];

        directories = [
          # XDG User Directories
          "Desktop"
          "Documents"
          "Music"
          "Pictures"
          "Projects"
          "Public"
          "Templates"
          "Videos"
          "Books"

          # Identity / Secrets
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            # Aqua's private age identity for editing SOPS files.
            directory = ".config/sops";
            mode = "0700";
          }
          {
            # Retain agent login, settings, sessions, plugins and skills.
            directory = ".codex";
            mode = "0700";
          }
          {
            # OpenCode provider credentials (auth.json) and session history.
            directory = ".local/share/opencode";
            mode = "0700";
          }

          # Git & Forge CLI Tools
          {
            directory = ".config/gh";
            mode = "0700";
          }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }

          # Web Browser
          {
            directory = ".config/BraveSoftware/Brave-Origin";
            mode = "0700";
          } # Brave history, bookmarks, extensions, sessions, and cookies

        ]
        # Flatpak Application Data
        # Derive app data from the catalog; theme extensions have no app data.
        ++ map (appId: {
          directory = ".var/app/${appId}";
          mode = "0700";
        }) (builtins.attrNames (lib.filterAttrs (_: app: app.persist or true) flatpakApps))
        ++ [

          {
            directory = ".config/rust-book-brave";
            mode = "0700";
          }

          # Editor / IDE State
          ".local/share/zed"
          ".config/zed"
          ".local/share/delta"
          ".config/delta"

          {
            # Native Nahhasio client state; media files are stored separately.
            directory = ".local/state/nahhasio";
            mode = "0700";
          }

          # Shell History & State
          ".local/state/nix"
          {
            directory = ".config/atuin";
            mode = "0700";
          }
          {
            # Command history, sync identity and encryption key.
            directory = ".local/share/atuin";
            mode = "0700";
          }

          {
            # Avoid losing Nix fetch/evaluation metadata on every reboot.
            directory = ".cache/nix";
            mode = "0700";
          }
          {
            # Retain direnv approvals across reboots.
            directory = ".local/share/direnv";
            user = username;
            group = "users";
            mode = "0700";
          }
          {
            # Devenv trust metadata, cached keys, and explicit GC roots.
            directory = ".local/share/devenv";
            user = username;
            group = "users";
            mode = "0700";
          }

          # GNOME Calendar / Evolution Data Server
          ".local/share/evolution"
          ".config/evolution"

          # Desktop Session State
          {
            # Noctalia runtime state and setup wizard flags
            directory = ".local/state/noctalia";
            user = username;
            group = "users";
            mode = "0755";
          }
          ".local/share/noctalia" # Plugin files and downloads

          # ChatGPT Desktop
          {
            # Retain the desktop profile; session tokens live in the keyring.
            directory = ".config/Codex";
            mode = "0700";
          }
          # Retain downloaded document runtimes across reboots.
          ".cache/codex-runtimes"

          # Vulkan Shader Caches
          # Retain driver shader caches alongside Steam’s per-game cache.
          ".cache/mesa_shader_cache"
          ".cache/radv_builtin_shaders"

          # Audio Per-App State
          ".local/state/wireplumber" # Audio volumes and default device selections
          ".local/state/pipewire"

          # Obsidian
          ".config/obsidian" # App preferences. Note: Vaults live in ~/Documents

          # Anki
          ".local/share/Anki2" # Collection, media, add-ons, and prefs21.db

          # Steam
          ".local/share/Steam"
          ".steam"

          # Other
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
    # DynamicUser backing state must remain inaccessible to other users.
    "/saved/var/lib/private".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
    "/var/lib/private".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };

    "/home/${username}/.config".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.config/dconf".d = lib.mkForce {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.local".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.local/share".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.local/state".d = {
      user = username;
      group = "users";
      mode = "0755";
    };

    # Create missing theme placeholders; keep Noctalia’s generated contents.
    "/home/${username}/.config/niri".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.config/niri/noctalia.kdl".f = {
      user = username;
      group = "users";
      mode = "0644";
    };
    "/home/${username}/.config/ghostty".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.config/ghostty/themes".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.config/ghostty/themes/noctalia".f = {
      user = username;
      group = "users";
      mode = "0644";
    };

    # Create user-owned Flatpak parents before rootless bwrap can own them.
    "/home/${username}/.var".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    "/home/${username}/.var/app".d = {
      user = username;
      group = "users";
      mode = "0755";
    };
    # Repair existing LibreOffice data ownership.
    "/home/${username}/.var/app/org.libreoffice.LibreOffice".Z = {
      user = username;
      group = "users";
      mode = "0700";
    };

    # Isolated secret runtime directory used by explicit out-of-store home configurations.
    "/saved/secrets".d = {
      user = username;
      group = "users";
      mode = "0700";
    };
    "/saved/secrets/nix.conf".z = {
      user = username;
      group = "users";
      mode = "0600";
    };
    "/saved/secrets/Shadow-BG-20-VPN.conf".z = {
      user = username;
      group = "users";
      mode = "0600";
    };
    "/saved/secrets/github-token".z = {
      user = username;
      group = "users";
      mode = "0600";
    };
    "/saved/secrets/Passwords.kdbx".z = {
      user = username;
      group = "users";
      mode = "0600";
    };

    # NetworkManager profiles may contain Wi-Fi PSKs or VPN credentials.
    "/saved/etc/NetworkManager/system-connections".d = {
      user = "root";
      group = "root";
      mode = lib.mkForce "0700";
    };
    # Repair profile ownership; NetworkManager requires root-owned files.
    "/saved/etc/NetworkManager/system-connections".Z = {
      user = "root";
      group = "root";
      mode = "-";
    };

    "/saved/var/lib/sops-nix".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
    "/saved/var/lib/sops-nix/key.txt".z = {
      user = "root";
      group = "root";
      mode = "0400";
    };
    "/saved/var/lib/sops-nix/recipient.txt".z = {
      user = "root";
      group = "root";
      mode = "0444";
    };

    # Protect the persistent host keys when SSH is enabled.
    "/saved/etc/ssh/ssh_host_ed25519_key".z = lib.mkIf config.services.openssh.enable {
      user = "root";
      group = "root";
      mode = "0600";
    };
    "/saved/etc/ssh/ssh_host_ed25519_key.pub".z = lib.mkIf config.services.openssh.enable {
      user = "root";
      group = "root";
      mode = "0644";
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
