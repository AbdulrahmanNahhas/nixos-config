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

        # Preserve the random seed so the entropy pool doesn’t stall on boot.
        { file = "/var/lib/systemd/random-seed"; how = "symlink"; inInitrd = true; configureParent = true; }
      ];

      directories = [
        { directory = "/var/lib/nixos"; inInitrd = true; }
        "/var/log"
	"var/lib/flatpak"
        "/var/lib/bluetooth"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/etc/NetworkManager/system-connections"
      ];

      users.aqua = {
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

          # ── Web browser / sessions ───────────────────────────
          ".mozilla"                  # Firefox profile, cookies, saved logins, addons
          { directory = ".local/share/keyrings"; mode = "0700"; }
            # GNOME Keyring 'login' store — Zed & many apps keep their auth token here.
            # Without this, Zed logs you out on every reboot.

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
	  ".local/share/zed"
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
