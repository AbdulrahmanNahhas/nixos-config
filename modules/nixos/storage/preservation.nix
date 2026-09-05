{
  config,
  lib,
  username,
  ...
}:
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
        # Claude Code config: MCP servers, project trust, onboarding state.
        # Rewritten atomically, which severs a bindmount on first save, so
        # symlink is the only "how" that survives.
        {
          file = "/home/${username}/.claude.json";
          how = "symlink";
        }

        # ── GTK application settings ─────────────────────────
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
          # tuigreet's remembered user and session; without it the greeter
          # forgets both on every boot of the tmpfs root.
          directory = "/var/cache/tuigreet";
          user = "greeter";
          group = "greeter";
          mode = "0755";
        }
        "/var/lib/systemd/timers"
        {
          directory = "/var/log/journal";
          user = "root";
          group = "systemd-journal";
          mode = "2755";
        }
        "/var/lib/kavita"
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
          {
            # Aqua's private age identity for editing SOPS files.
            directory = ".config/sops";
            mode = "0700";
          }
          {
            directory = ".claude";
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
            directory = ".config/BraveSoftware/Brave-Origin";
            mode = "0700";
          } # Brave history, bookmarks, extensions, sessions, and cookies

        ]
        # ── Flatpak Application Data ───────────────────────────
        # Derived from the Flatpak module so the two lists cannot drift. The
        # GTK theme extensions installed there have no per-app data.
        ++
          map
            (appId: {
              directory = ".var/app/${appId}";
              mode = "0700";
            })
            (
              lib.filter (appId: !lib.hasPrefix "org.gtk.Gtk3theme." appId) (
                map (pkg: pkg.appId) config.services.flatpak.packages
              )
            )
        ++ [

          # ── Editor / IDE State ───────────────────────────────
          ".local/share/zed"
          ".config/zed"
          ".local/share/delta"
          ".config/delta"

          # ── Shell History & State ────────────────────────────
          ".local/state/nix"
          ".config/atuin"
          ".local/share/atuin" # Atuin history database
          {
            # Approved .envrc hashes; losing these prompts for direnv allow
            # after every reboot on the tmpfs root.
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

          # ── Shared Espressif Toolchains ──────────────────────
          {
            directory = ".rustup";
            user = username;
            group = "users";
            mode = "0700";
          }
          {
            # Versioned ESP-IDF checkouts, Python envs, archives, and C tools
            # shared by ESP Rust projects using the native global builder.
            directory = ".espressif";
            user = username;
            group = "users";
            mode = "0700";
          }
          {
            directory = ".espup";
            user = username;
            group = "users";
            mode = "0700";
          }

          # ── Desktop Session State ────────────────────────────
          {
            # Noctalia runtime state and setup wizard flags
            directory = ".local/state/noctalia";
            user = username;
            group = "users";
            mode = "0755";
          }
          ".local/share/noctalia" # Plugin files and downloads
          ".config/cosmic" # Panel, theme, and per-application settings
          ".local/state/cosmic" # Window state and first-run flags

          # ── Vulkan Shader Caches ──────────────────────────────────
          # Steam's per-game shadercache is below .local/share/Steam; retain the
          # driver-level compiled caches too so RADV/Mesa can reuse them.
          ".cache/mesa_shader_cache"
          ".cache/radv_builtin_shaders"

          # ── Audio Per-App State ──────────────────────────────
          ".local/state/wireplumber" # Audio volumes and default device selections
          ".local/state/pipewire"

          # ── Obsidian ─────────────────────────────────────────
          ".config/obsidian" # App preferences. Note: Vaults live in ~/Documents

          # ── Steam ───────────────────────────────
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

    # niri and ghostty both read noctalia-generated theme files that only
    # exist after noctalia starts, and both fail hard without them (ghostty
    # aborts home-manager activation). "f" bootstraps empty placeholders and
    # leaves the real content alone once noctalia writes it.
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

    # Parents of the per-app .var/app/<id> mounts above. A brand-new app whose
    # parents do not exist yet gets them created by flatpak.s rootless bwrap
    # instead, owned by nobody:nogroup -- which then breaks the app
    # ("mkdirat(data): Permission denied", hit live with LibreOffice).
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
    # Repairs the directory already broken that way; the rules above only
    # prevent it for apps added since.
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
    # NetworkManager rejects profiles not owned by root. Recursively repair
    # profiles that may have been created with the user's ownership.
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

    # These rules become active together with the conditional Preservation
    # entries above, so a future SSH server has a stable, protected identity.
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
