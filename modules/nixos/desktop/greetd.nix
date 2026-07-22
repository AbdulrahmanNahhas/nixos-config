{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.greetd = {
    enable = true;
    restart = true;

    # Keep authentication independent of the graphics stack. Both greetd and
    # tuigreet are Rust programs; the authenticated session starts Niri/Wayland.
    settings.default_session = {
      user = "greeter";
      command = lib.concatStringsSep " " [
        "${lib.getExe pkgs.tuigreet}"
        "--time"
        "--remember"
        "--remember-session"
        "--asterisks"
        "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        "--cmd ${lib.escapeShellArg "niri-session"}"
        "--power-shutdown ${lib.escapeShellArg "systemctl poweroff"}"
        "--power-reboot ${lib.escapeShellArg "systemctl reboot"}"
      ];
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
