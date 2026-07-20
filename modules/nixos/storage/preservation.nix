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

        # ── GNOME desktop state ──────────────────────────────
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
        "/var/lib/decky-loader"
        "/var/lib/systemd/timers"
        "/var/lib/kavita"
        "/etc/NetworkManager/system-connections"
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
            # Codex credentials, conversations, settings, skills, and local state.
            directory = ".codex";
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
            directory = ".librewolf";
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
              "chat.simplex.simplex"
              "com.belmoussaoui.Authenticator"
              "com.brave.Browser"
              "com.github.ADBeveridge.Raider"
              "dev.geopjr.Tuba"
              "io.github.sniper1720.khushu"
              "io.gitlab.news_flash.NewsFlash"
              "io.gitlab.theevilskeleton.Upscaler"
              "org.gnome.Fractal"
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
