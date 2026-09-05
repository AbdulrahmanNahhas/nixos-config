{
  lib,
  pkgs,
  username,
  ...
}:
let
  tuigreet = pkgs.writeShellScript "tuigreet-start" ''
    if ${pkgs.plymouth}/bin/plymouth --ping 2>/dev/null; then
      ${pkgs.plymouth}/bin/plymouth quit --wait
    fi

    export TERM=linux
    ${lib.getExe' pkgs.util-linux "setterm"} --reset 2>/dev/null || true
    ${lib.getExe' pkgs.util-linux "setterm"} \
      --foreground white \
      --background black \
      --cursor on \
      --clear=all 2>/dev/null || true

    # The UID window covers real accounts only; nixbld build users start at
    # 30001 and would otherwise fill the user menu.
    exec ${lib.getExe pkgs.tuigreet} \
      --greeting ${lib.escapeShellArg "SYSTEM // SECURE LOGIN"} \
      --time \
      --time-format ${lib.escapeShellArg "%A, %d %B  ·  %H:%M"} \
      --user ${username} \
      --user-menu \
      --user-menu-min-uid 1000 \
      --user-menu-max-uid 29999 \
      --asterisks \
      --asterisks-char "•" \
      --width 56 \
      --window-padding 2 \
      --container-padding 2 \
      --prompt-padding 1 \
      --greet-align center \
      --theme ${lib.escapeShellArg "border=white;text=white;time=gray;title=white;greet=white;prompt=gray;input=bright-white;action=gray;button=white;container=black"} \
      --cmd ${lib.escapeShellArg "${pkgs.niri}/bin/niri-session"} \
      --power-shutdown ${lib.escapeShellArg "systemctl poweroff"} \
      --power-reboot ${lib.escapeShellArg "systemctl reboot"}
  '';
in
{
  services.greetd = {
    enable = true;
    restart = true;

    # Upstream way to run a TUI greeter: wires up the TTY and stdio on tty1.
    useTextGreeter = true;

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

  # The systemd-user PAM stack deadlocks on Shadow, blocking greetd and every
  # login for the full 90-second user@.service timeout. Only the nested PAM
  # call that launches `systemd --user` is bypassed (the greetd login stack is
  # untouched), so the runtime directory pam_systemd adds is supplied here.
  systemd.services."user@" = {
    environment.XDG_RUNTIME_DIR = "/run/user/%i";
    serviceConfig.PAMName = lib.mkForce "";
  };
}
