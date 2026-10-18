{ lib, ... }:
let
  apps = import ./flatpak-apps.nix;
  themePaths = [
    "xdg-config/gtk-3.0:ro"
    "xdg-config/gtk-4.0:ro"
  ];
  # These paths have no role in the managed desktop apps. Include the backing
  # store as well as the normal home paths so persistence is not an alternate
  # route to credentials. Named Secret Service access remains app-specific.
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
    ];
    packages = lib.mapAttrsToList (appId: app: {
      inherit appId;
      origin = app.origin or "flathub-verified";
    }) apps;
    update = {
      onActivation = false;
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
          # Access to a credential service can supply secrets even when its
          # backing files are hidden. Element opts into Secret Service below
          # through its catalog entry; other apps need an explicit review.
          "Session Bus Policy" = {
            "org.freedesktop.secrets" = "none";
            "org.kde.kwalletd" = "none";
            "org.kde.kwalletd5" = "none";
            "org.kde.kwalletd6" = "none";
          };
          Environment = {
            # Flatpak already bind-mounts host icon themes read-only at
            # /run/host; this only points the cursor loader at them.
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

            # GTK_THEME is deliberately not global: it is GTK3-only, and a
            # GTK4/libadwaita app that sees it looks for a gtk-4.0 stylesheet
            # adw-gtk3 does not ship and ends up with none at all. GTK4 apps
            # already follow the portal, so it is set per-app below instead.
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

            # Wayland only. Audio stays under each upstream manifest because
            # Flatpak's PulseAudio socket is also the PipeWire compat path.
            sockets = [
              "wayland"
              "!x11"
              "!fallback-x11"
              "!session-bus"
              "!system-bus"
              "!ssh-auth"
              "!gpg-agent"
            ];

            # Apps use GPU access and mediated services, without raw input,
            # USB, KVM or the host shared-memory device grants.
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
