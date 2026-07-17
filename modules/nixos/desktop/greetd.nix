{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  services.greetd = {
    enable = true;
    restart = true;

    # ReGreet needs a small Wayland compositor. Keep Cage isolated from the
    # desktop session, use one deterministic output, and avoid portal delays.
    settings.default_session = {
      user = "greeter";
      command = lib.concatStringsSep " " [
        "${lib.getExe' pkgs.coreutils "env"}"
        "GTK_USE_PORTAL=0"
        "GDK_DEBUG=no-portals"
        "${pkgs.dbus}/bin/dbus-run-session"
        "${lib.getExe pkgs.cage}"
        "-s"
        "-d"
        "-m"
        "last"
        "--"
        "${lib.getExe config.programs.regreet.package}"
      ];
    };
  };

  # The upstream unit only restarts after a clean exit. Recover from a crashed
  # greetd too, while rate-limiting a genuinely broken greeter configuration.
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

  programs.regreet = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
    font = {
      name = "Inter";
      size = 15;
      package = pkgs.inter;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
        cursor_blink = true;
      };
      appearance.greeting_msg = "WELCOME TO SHADOW";
      widget.clock = {
        format = "%H:%M  ·  %A";
        resolution = "1s";
        label_width = 320;
      };
      commands = {
        reboot = [
          "${pkgs.systemd}/bin/systemctl"
          "reboot"
        ];
        poweroff = [
          "${pkgs.systemd}/bin/systemctl"
          "poweroff"
        ];
      };
    };
    extraCss = ''
      /* Canvas */
      window,
      window > overlay {
        background: #050505;
        color: #f7f7f7;
      }

      /* ReGreet applies this class to the login and clock frames. */
      frame.background {
        background: #0b0b0b;
        color: #f7f7f7;
        border: 1px solid #292929;
        border-radius: 18px;
        box-shadow: 0 18px 56px rgba(0, 0, 0, 0.72);
      }

      frame.background > border {
        border: none;
      }

      frame.background > grid {
        min-width: 560px;
        margin: 26px;
      }

      label {
        color: #f7f7f7;
        font-weight: 500;
      }

      /* Labels to the left of the fields. */
      grid > label {
        color: #8f8f8f;
        font-size: 0.82em;
        font-weight: 600;
      }

      /* The greeting occupies the first row of the login grid. */
      grid > label:first-child {
        color: #ffffff;
        font-size: 1.14em;
        font-weight: 700;
        letter-spacing: 0.12em;
      }

      /* Text and password fields */
      entry,
      passwordentry {
        min-height: 48px;
        padding: 0 14px;
        background: #111111;
        color: #ffffff;
        caret-color: #ffffff;
        border: 1px solid #343434;
        border-radius: 10px;
        box-shadow: none;
      }

      passwordentry > text {
        background: transparent;
        color: #ffffff;
      }

      entry:hover,
      passwordentry:hover {
        background: #151515;
        border-color: #525252;
      }

      entry:focus,
      passwordentry:focus,
      passwordentry:focus-within {
        background: #111111;
        border-color: #ffffff;
        box-shadow: 0 0 0 1px #ffffff;
      }

      entry selection,
      passwordentry selection {
        background: #ffffff;
        color: #000000;
      }

      passwordentry image {
        color: #9a9a9a;
        margin: 0 4px;
      }

      /* User and session selectors. GtkComboBoxText is a linked box. */
      combobox > box.linked {
        min-height: 48px;
        background: #111111;
        border: 1px solid #343434;
        border-radius: 10px;
        box-shadow: none;
      }

      combobox > box.linked:hover {
        background: #151515;
        border-color: #525252;
      }

      combobox > box.linked:focus-within {
        border-color: #ffffff;
        box-shadow: 0 0 0 1px #ffffff;
      }

      combobox > box.linked > button.combo {
        min-width: 300px;
        min-height: 48px;
        padding: 0 14px;
        background: transparent;
        color: #ffffff;
        border: none;
        border-radius: 9px;
        box-shadow: none;
      }

      combobox arrow {
        min-width: 16px;
        min-height: 16px;
        color: #a3a3a3;
      }

      /* GtkComboBoxText can expose either a popup window or a popover. */
      window.popup {
        padding: 6px;
        background: #0d0d0d;
        color: #ffffff;
        border: 1px solid #343434;
        border-radius: 12px;
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.82);
      }

      window.popup treeview,
      window.popup list,
      window.popup viewport {
        background: transparent;
        color: #ffffff;
      }

      window.popup cellview {
        color: #ffffff;
      }

      window.popup row {
        min-height: 42px;
        padding: 0 12px;
        color: #d9d9d9;
        border-radius: 7px;
      }

      window.popup row:hover {
        background: #1b1b1b;
        color: #ffffff;
      }

      window.popup row:selected {
        background: #ffffff;
        color: #000000;
      }

      popover > contents {
        margin: 8px;
        padding: 6px;
        background: #0d0d0d;
        color: #ffffff;
        border: 1px solid #343434;
        border-radius: 12px;
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.82);
      }

      popover listview,
      popover viewport {
        background: transparent;
        color: #ffffff;
      }

      popover row {
        min-height: 42px;
        padding: 0 12px;
        color: #d9d9d9;
        border-radius: 7px;
      }

      popover row:hover {
        background: #1b1b1b;
        color: #ffffff;
      }

      popover row:selected {
        background: #ffffff;
        color: #000000;
      }

      popover row:selected label {
        color: #000000;
      }

      /* Buttons */
      button {
        min-height: 44px;
        padding: 0 18px;
        background: #121212;
        color: #d7d7d7;
        border: 1px solid #343434;
        border-radius: 10px;
        box-shadow: none;
        font-weight: 600;
      }

      button:hover {
        background: #1b1b1b;
        color: #ffffff;
        border-color: #595959;
      }

      button:focus-visible {
        border-color: #ffffff;
        box-shadow: 0 0 0 1px #ffffff;
      }

      button:active,
      button:checked {
        background: #e8e8e8;
        color: #050505;
        border-color: #e8e8e8;
      }

      /* Small square edit buttons beside the selectors. */
      grid > button.toggle {
        min-width: 48px;
        padding: 0;
      }

      button.suggested-action {
        min-width: 112px;
        background: #ffffff;
        color: #050505;
        border-color: #ffffff;
      }

      button.suggested-action:hover,
      button.suggested-action:focus-visible {
        background: #d9d9d9;
        color: #050505;
        border-color: #d9d9d9;
      }

      button:disabled {
        background: #0d0d0d;
        color: #5f5f5f;
        border-color: #242424;
      }

      /* Reboot and power-off remain quiet until hovered. */
      button.destructive-action {
        min-height: 38px;
        padding: 0 16px;
        background: transparent;
        color: #8f8f8f;
        border-color: #242424;
        border-radius: 9px;
        font-size: 0.82em;
      }

      button.destructive-action:hover,
      button.destructive-action:focus-visible {
        background: #ffffff;
        color: #050505;
        border-color: #ffffff;
      }

      infobar {
        background: #111111;
        color: #ffffff;
        border: 1px solid #383838;
        border-radius: 10px;
      }

      infobar label {
        color: #ffffff;
      }

      tooltip {
        padding: 8px 10px;
        background: #ffffff;
        color: #050505;
        border-radius: 7px;
      }

      tooltip label {
        color: #050505;
      }
    '';
  };

  # ReGreet does not consume services.displayManager.defaultSession. Seed its
  # own volatile state before the first launch; afterward it may remember an
  # explicit session selection for the rest of the boot.
  systemd.tmpfiles.settings."11-regreet-default"."/var/lib/regreet/state.toml".f = {
    user = "greeter";
    group = "greeter";
    mode = "0644";
    argument = ''
      last_user = "${username}"

      [user_to_last_sess]
      ${username} = "Niri"
    '';
  };
}
