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
        # Claude Code's top-level config: MCP servers, project trust, and
        # onboarding state. Rewritten atomically (write + rename), so a
        # bindmount would be severed on the first save -- symlink is the
        # only "how" that survives that pattern.
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
          # {
          #   # Codex credentials, conversations, settings, skills, and local state.
          #   directory = ".codex";
          #   mode = "0700";
          # }
          {
            # T3 Code credentials, conversations, settings, skills, and local state.
            directory = ".t3";
            mode = "0700";
          }
          {
            # Claude Code OAuth credentials, session transcripts, per-project
            # history, plugins, skills, and settings. Pairs with the
            # ~/.claude.json symlink above.
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
            # LibreWolf 152+ follows the XDG profile layout.
            directory = ".config/librewolf";
            mode = "0700";
          } # LibreWolf history, bookmarks, extensions, sessions, and cookies

          # ── Flatpak Application Data ─────────────────────────
        ]
        ++
          map
            (appId: {
              directory = ".var/app/${appId}";
              mode = "0700";
            })
            [
              "app.drey.EarTag"
              "chat.simplex.simplex"

              "com.brave.Browser"
              "com.github.ADBeveridge.Raider"
              "dev.geopjr.Tuba"
              "io.github.diegopvlk.Cine"
              "io.github.sniper1720.khushu"
              "io.bassi.Amberol"
              "io.gitlab.adhami3310.Impression"
              "io.gitlab.news_flash.NewsFlash"
              "io.gitlab.theevilskeleton.Upscaler"
              "org.gnome.Fractal"
              "org.gnome.Loupe"
              "org.gnome.Papers"
              "org.libreoffice.LibreOffice"
              "org.onlyoffice.desktopeditors"
              "org.signal.Signal"
              "org.telegram.desktop"
            ]
        ++ [

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

          # ── Niri & Noctalia State ────────
          {
            directory = ".local/state/noctalia";
            user = username;
            group = "users";
            mode = "0755";
          }
          ".config/niri"
          ".config/noctalia"
          ".local/share/noctalia"

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
    # Flatpak's own per-app data lives here (.var/app/<id>, mapped below).
    # Without pre-creating .var and .var/app themselves, a *brand-new*
    # app's first-ever "directory" entry has no existing parent to inherit
    # ownership from, and flatpak's own sandboxed mkdir ends up creating it
    # instead -- confirmed live: org.libreoffice.LibreOffice's first launch
    # after being added to the preserveAt list below created
    # ~/.var/app/org.libreoffice.LibreOffice owned by nobody:nogroup
    # (a user-namespace mapping artifact of flatpak's rootless bwrap),
    # which then made the app fail to start at all ("mkdirat(data):
    # Permission denied").
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
    # Retroactively repairs the already-broken directory from the incident
    # above; the .d rules above only prevent this for apps added from now on.
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
