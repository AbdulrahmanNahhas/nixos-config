# preservation.nix — /saved is the persistent btrfs subvolume
#
# The root filesystem (`/`) is tmpfs, so anything NOT listed here is
# lost on every reboot. Add to these lists whenever you start using a
# new app whose state you want to keep (logins, history, settings, …).
{ ... }:
{
  preservation = {
    enable = true;

    preserveAt."/saved" = {
      files = [
        # Auto-generated machine ID — symlinked to the persistent copy
        # so the same ID survives reboots (required by journald, machinectl,
        # NetworkManager, etc.). `configureParent` ensures /saved/etc exists.
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }

        # SSH host keys — stable across rebuilds so remote clients don’t
        # get “host key changed” warnings.
        { file = "/etc/ssh/ssh_host_ed25519_key";     how = "symlink"; configureParent = true; }
        { file = "/etc/ssh/ssh_host_ed25519_key.pub"; how = "symlink"; configureParent = true; }

        # Preserve the random seed so the entropy pool doesn't stall on boot.
        { file = "/var/lib/systemd/random-seed"; how = "symlink"; inInitrd = true; configureParent = true; }

        # Git global config — user.name, user.email, signing keys.
        # Same idea as other forge CLI tool configs below under users.aqua.
        { file = "/home/aqua/.gitconfig"; how = "symlink"; }

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
        # Hide every per-user bind mount from GNOME Files / gvfs so each ~/dir
        # is shown only once (not also as a separately-mounted volume). This is
        # the upstream-documented option for impermanence-style setups.
        commonMountOptions = [ "x-gvfs-hide" ];

        directories = [
          # ── XDG user dirs (kept in sync with home/aqua/default.nix) ──
          "Desktop"
          "Documents"
          "Music"
          "Pictures"
          "Projects"
          "Public"
          "Templates"
          "Videos"

          # ── Identity / secrets ───────────────────────────────
          { directory = ".ssh";   mode = "0700"; }
          { directory = ".gnupg"; mode = "0700"; }

          # ── Git & forge CLI tools ────────────────────────────
          ".config/gh"
            # GitHub CLI (gh) auth — hosts.yml, config.yml.
            # When you add GitLab: add ".config/glab-cli" here too.
          { directory = ".local/share/keyrings"; mode = "0700"; }
            # GNOME Keyring 'login' store — Zed & other apps keep auth tokens here.

          # ── Web browser ───────────────────────────────────────
          { directory = ".mozilla"; mode = "0700"; }
            # Firefox profile — history, logins, cookies, sessions, add-on state.

          # ── Flatpak application data ─────────────────────────
          ".var"
            # ~/.var/app/<app-id>/ — Flatpak sandboxes store config + data here.
            # Signal, Telegram, Vesktop, Fractal, Tuba, NewsFlash, OnlyOffice,
            # Authenticator, etc. all keep their login/session state under this_dir.

          # ── Editor / IDE state ───────────────────────────────
          ".local/share/zed"          # Zed login token, workspace DB, recent projects
          ".config/nvim"
          ".local/state/nvim"

          # ── Shell history & state ────────────────────────────
          ".config/fish"
          ".config/zed"
          ".local/share/fish"        # fish_history (shell history)
          ".local/state/nix"
          ".config/atuin"
          ".local/share/atuin"       # atuin encrypted shell-history DB

          # ── Audio per-app state ──────────────────────────────
          ".local/state/wireplumber" # per-device/sink volumes, default sinks
          ".local/state/pipewire"   # pipewire persistent state
        ];
      };
    };
  };

  # Ensure the parents used by the persisted entries exist on the tmpfs
  # root with the right ownership *before* any application tries to write
  # to them on first boot. Without this, Zed/atuin/etc. may fail to create
  # their state dirs and silently lose data.
  systemd.tmpfiles.settings.preservation = {
    "/home/aqua/.config".d       = { user = "aqua"; group = "users"; mode = "0755"; };
    "/home/aqua/.local".d        = { user = "aqua"; group = "users"; mode = "0755"; };
    "/home/aqua/.local/share".d  = { user = "aqua"; group = "users"; mode = "0755"; };
    "/home/aqua/.local/state".d  = { user = "aqua"; group = "users"; mode = "0755"; };

    # Persistent, aqua-owned secrets dir on /saved (holds nix.conf with
    # access tokens — see home/aqua/default.nix out-of-store symlink). 0700 so
    # only aqua can read it. Declared here so it exists on first boot.
    "/saved/secrets".d           = { user = "aqua"; group = "users"; mode = "0700"; };
  };

  # Adapt the upstream systemd service so the transient machine-id
  # generated on the tmpfs root is committed to /saved at boot.
  # (Mirrors the official preservation docs pattern with `how = "symlink"`.)
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
