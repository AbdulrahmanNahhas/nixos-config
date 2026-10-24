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

    # Limit the menu to real users; nixbld UIDs start at 30001.
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

  # Unlock the login keyring for apps launched in the greetd session.
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Bypass the nested PAM call that causes 90-second login stalls on Shadow.
  # Keep greetd PAM; supply the runtime directory normally added by pam_systemd.
  systemd.services."user@" = {
    environment.XDG_RUNTIME_DIR = "/run/user/%i";
    serviceConfig.PAMName = lib.mkForce "";
  };
}
