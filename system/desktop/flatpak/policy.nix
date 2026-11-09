{ lib }:
let
  themePaths = [
    "xdg-config/gtk-3.0:ro"
    "xdg-config/gtk-4.0:ro"
  ];
  # Explicit exclusions also protect credentials inside broader folder grants.
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
    "!xdg-config/mozilla"
    "!~/.mozilla"
    "!xdg-config/Codex"
    "!xdg-data/keyrings"
    "!xdg-run/keyring"
  ];
  appOverrides =
    app:
    let
      overrides = app.overrides or { };
    in
    lib.recursiveUpdate overrides {
      # Hardware rendering avoids software-only GTK/Qt/Electron drawing.
      Context.devices = lib.unique (
        (lib.optional (app.gpu or true) "dri") ++ (overrides.Context.devices or [ ])
      );
      # Reset manifest filesystem grants; keep only reviewed paths.
      Context.filesystems = [
        "!host:reset"
      ]
      ++ themePaths
      ++ (overrides.Context.filesystems or [ ])
      ++ privatePaths;
    };
in
{
  inherit appOverrides;
  global = {
    "Session Bus Policy" = {
      "org.freedesktop.secrets" = "none";
      "org.kde.kwalletd" = "none";
      "org.kde.kwalletd5" = "none";
      "org.kde.kwalletd6" = "none";
    };
    Environment.XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
    Context = {
      filesystems = [
        "!host"
        "!home"
      ]
      ++ themePaths
      ++ privatePaths;
      sockets = [
        "wayland"
        "!x11"
        "!fallback-x11"
        "!session-bus"
        "!system-bus"
        "!ssh-auth"
        "!gpg-agent"
      ];
      # Rendering is granted per app; input and general device access stay denied.
      devices = [
        "!all"
        "!input"
        "!usb"
        "!kvm"
        "!shm"
      ];
      shared = [ "!ipc" ];
    };
  };
}
