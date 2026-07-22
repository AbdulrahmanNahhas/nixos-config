{
  config,
  lib,
  pkgs,
  ...
}:
let
  tuigreet = pkgs.writeShellScript "tuigreet-start" ''
    # Plymouth can leave tty1 with terminal attributes that make a TUI's
    # default colors invisible.  Start every greeter session from a known,
    # readable Linux-console state.
    export TERM=linux
    ${lib.getExe' pkgs.util-linux "setterm"} --reset
    ${lib.getExe' pkgs.util-linux "setterm"} \
      --foreground white \
      --background black \
      --cursor on \
      --clear=all

    exec ${lib.getExe pkgs.tuigreet} \
      --greeting ${lib.escapeShellArg "SHADOW // SECURE SESSION"} \
      --time \
      --time-format ${lib.escapeShellArg "%A, %d %B  ·  %H:%M"} \
      --remember \
      --remember-session \
      --user-menu \
      --asterisks \
      --width 68 \
      --window-padding 1 \
      --container-padding 2 \
      --prompt-padding 1 \
      --greet-align center \
      --theme ${lib.escapeShellArg "border=cyan;text=white;time=cyan;container=black;prompt=cyan;input=white;action=cyan;button=cyan"} \
      --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions \
      --cmd ${lib.escapeShellArg "niri-session"} \
      --power-shutdown ${lib.escapeShellArg "systemctl poweroff"} \
      --power-reboot ${lib.escapeShellArg "systemctl reboot"} \
      2> >(${lib.getExe' pkgs.systemd "systemd-cat"} --identifier=tuigreet --priority=err)
  '';
in
{
  services.greetd = {
    enable = true;
    restart = true;

    # Keep authentication independent of the graphics stack. Both greetd and
    # tuigreet are Rust programs; the authenticated session starts Niri/Wayland.
    settings.default_session = {
      user = "greeter";
      command = "${tuigreet}";
    };
  };

  # Recover from a crashed greeter without creating an unbounded restart loop.
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

  # The systemd-user PAM stack deadlocks on Shadow before the user manager can
  # signal readiness. That blocks greetd (and every real-user login) for the
  # full 90-second user@.service timeout. The login-facing greetd PAM stack is
  # unchanged; only the nested PAM invocation used to launch `systemd --user`
  # is bypassed. Supply the runtime directory that pam_systemd normally adds.
  systemd.services."user@" = {
    environment.XDG_RUNTIME_DIR = "/run/user/%i";
    serviceConfig.PAMName = lib.mkForce "";
  };
}
