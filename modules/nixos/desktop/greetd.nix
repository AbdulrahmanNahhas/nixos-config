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
      --greeting SHADOW \
      --time \
      --remember \
      --remember-session \
      --user-menu \
      --asterisks \
      --width 64 \
      --theme ${lib.escapeShellArg "border=white;text=white;time=cyan;container=black;prompt=white;input=white;action=cyan;button=white"} \
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
}
