{ lib, pkgs, ... }:
let
  apps = import ./flatpak-apps.nix;
  themePaths = [
    "xdg-config/gtk-3.0:ro"
    "xdg-config/gtk-4.0:ro"
  ];
  # Deny credential paths in both home and /saved; review service access per app.
  privatePaths = [
    "!/saved"
    "!/run/secrets"
    "!~/.ssh"
    "!~/.gnupg"
    "!~/.aws"
    "!~/.kube"
    "!~/.codex"
    "!xdg-config/sops"
    "!xdg-config/gh"
    "!xdg-config/BraveSoftware"
    "!xdg-data/keyrings"
    "!xdg-data/opencode"
    "!xdg-run/keyring"
  ];
  appOverrides =
    app:
    let
      overrides = app.overrides or { };
    in
    lib.recursiveUpdate overrides {
      # Do not inherit new filesystem access silently when a manifest updates.
      Context.filesystems = [
        "!host:reset"
      ]
      ++ themePaths
      ++ (overrides.Context.filesystems or [ ])
      ++ privatePaths;
    };
in
{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub-verified";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        args = "--subset=verified";
      }
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "flathub-beta";
        location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
      {
        name = "nahhasio-alpha";
        # Pin the repository descriptor and signing key; app updates follow alpha.
        location = "${pkgs.fetchurl {
          url = "https://github.com/AbdulrahmanNahhas/nahhasio/releases/download/nahhasio-v0.1.1/nahhasio.flatpakrepo";
          sha256 = "4bbbc3e053aae2f7eb1bb649ecf5a1ed1b83e04115ff8b18dbb707bc142b50e3";
        }}";
      }
    ];
    packages = lib.mapAttrsToList (
      appId: app:
      {
        inherit appId;
        origin = app.origin or "flathub-verified";
      }
      // lib.optionalAttrs (app ? flatpakref) {
        inherit (app) flatpakref sha256;
      }
    ) apps;
    update = {
      # Reconcile installed versions on rebuild as well as the daily timer.
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
    uninstallUnmanaged = true;
    uninstallUnused = true;
    overrides = {
      # Managed system overrides replace manual edits; user overrides are separate.
      writeMode = "replace";
      pruneUnmanagedOverrides = true;
      settings = lib.mapAttrs (_: appOverrides) apps // {
        global = {
          # Deny credential services globally; Element opts into Secret Service.
          "Session Bus Policy" = {
            "org.freedesktop.secrets" = "none";
            "org.kde.kwalletd" = "none";
            "org.kde.kwalletd5" = "none";
            "org.kde.kwalletd6" = "none";
          };
          Environment = {
            # Use the read-only host icon themes for cursors.
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

            # Set GTK_THEME per GTK3 app; GTK4 uses portals and lacks adw-gtk3 styles.
          };

          Context = {
            # Per-app resets below own the complete filesystem allowlist.
            filesystems = [
              "!host"
              "!home"

              # Read-only access to GTK 3 & 4 user configurations
              "xdg-config/gtk-3.0:ro"
              "xdg-config/gtk-4.0:ro"
            ]
            ++ privatePaths;

            # Use Wayland; retain upstream audio access for PipeWire compatibility.
            sockets = [
              "wayland"
              "!x11"
              "!fallback-x11"
              "!session-bus"
              "!system-bus"
              "!ssh-auth"
              "!gpg-agent"
            ];

            # Allow GPU access without raw input, USB, KVM or host shared memory.
            devices = [
              "!all"
              "!input"
              "!usb"
              "!kvm"
              "!shm"
            ];

            # Wayland apps do not need the shared IPC namespace X11 requires.
            shared = [ "!ipc" ];
          };
        };
      };
    };
  };
}
