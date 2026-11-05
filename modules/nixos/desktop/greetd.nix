{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  # NixOS-generated desktop sessions.
  # Automatically includes Niri, Budgie, and future DEs.
  sessionsDir = "${config.services.displayManager.sessionData.desktops}/share";

  tuigreet = pkgs.writeShellScript "tuigreet-start" ''
    # Clean Plymouth handoff.
    if ${pkgs.plymouth}/bin/plymouth --ping 2>/dev/null; then
      ${pkgs.plymouth}/bin/plymouth quit --wait
    fi

    # Prepare a clean TTY.
    export TERM=linux

    ${lib.getExe' pkgs.util-linux "setterm"} \
      --reset 2>/dev/null || true

    ${lib.getExe' pkgs.util-linux "setterm"} \
      --foreground white \
      --background black \
      --cursor on \
      --clear=all 2>/dev/null || true

    # Minimal login with Wayland session selection.
    exec ${lib.getExe pkgs.tuigreet} \
      --greeting ${lib.escapeShellArg "N I X O S"} \
      --time \
      --time-format ${lib.escapeShellArg "%A  /  %d %B  /  %H:%M"} \
      --user ${lib.escapeShellArg username} \
      --user-menu \
      --user-menu-min-uid 1000 \
      --user-menu-max-uid 29999 \
      --asterisks \
      --asterisks-char "*" \
      --width 56 \
      --window-padding 3 \
      --container-padding 2 \
      --prompt-padding 2 \
      --greet-align center \
      --theme ${lib.escapeShellArg "border=gray;text=white;time=gray;title=bright-white;greet=bright-white;prompt=gray;input=bright-white;action=gray;button=bright-white;container=black"} \
      --sessions ${lib.escapeShellArg "${sessionsDir}/wayland-sessions"} \
      --cmd ${lib.escapeShellArg "${pkgs.niri}/bin/niri-session"} \
      --power-shutdown ${lib.escapeShellArg "systemctl poweroff"} \
      --power-reboot ${lib.escapeShellArg "systemctl reboot"}
  '';
in
{
  services.greetd = {
    enable = true;
    restart = true;
    useTextGreeter = true;

    settings.default_session = {
      user = "greeter";
      command = "${tuigreet}";
    };
  };

  # Bounded crash recovery.
  systemd.services.greetd = {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = "1s";
    };

    unitConfig = {
      StartLimitBurst = 5;
      StartLimitIntervalSec = 30;
    };
  };

  # GNOME Keyring integration.
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Existing workaround for the 90-second login stall.
  # Temporary compatibility measure; not a recommended
  # permanent configuration because it bypasses PAM
  # for systemd user managers.
  systemd.services."user@" = {
    environment.XDG_RUNTIME_DIR = "/run/user/%i";
    serviceConfig.PAMName = lib.mkForce "";
  };
}
