{ lib, ... }:
let
  apps = import ./flatpak-apps.nix;
  themePaths = [
    "xdg-config/gtk-3.0:ro"
    "xdg-config/gtk-4.0:ro"
  ];
  appOverrides =
    app:
    let
      overrides = app.overrides or { };
    in
    if app.strictFilesystems or false then
      lib.recursiveUpdate overrides {
        Context.filesystems = [ "!host:reset" ] ++ themePaths ++ (overrides.Context.filesystems or [ ]);
      }
    else
      overrides;
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
            # Broad home/host grants are denied; specific manifest paths remain.
            # Per-app exceptions and portals provide the intended file access.
            filesystems = [
              "!host"
              "!home"

              # Read-only access to GTK 3 & 4 user configurations
              "xdg-config/gtk-3.0:ro"
              "xdg-config/gtk-4.0:ro"
            ];

            # Wayland only. Audio stays under each upstream manifest because
            # Flatpak's PulseAudio socket is also the PipeWire compat path.
            sockets = [
              "wayland"
              "!x11"
              "!fallback-x11"
            ];

            # Drop the broad device access most manifests request.
            devices = [ "!all" ];

            # Wayland apps do not need the shared IPC namespace X11 requires.
            shared = [ "!ipc" ];
          };
        };
      };
    };
  };
}
