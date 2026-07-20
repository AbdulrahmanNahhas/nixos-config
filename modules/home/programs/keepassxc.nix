{
  config,
  lib,
  pkgs,
  ...
}:
let
  ini = pkgs.formats.ini { };
  settingsFile = ini.generate "keepassxc.ini" {
    Browser = {
      Enabled = true;
      UpdateBinaryPath = false;
    };
    GUI = {
      AdvancedSettings = true;
      ApplicationTheme = "dark";
      HidePasswords = true;
    };
  };
in
{
  home.packages = [ pkgs.keepassxc ];

  # Firefox-family browsers still discover per-user native hosts here even
  # when their profiles use the new XDG layout. Declare the bridge explicitly.
  mozilla.firefoxNativeMessagingHosts = [ pkgs.keepassxc ];

  # Home Manager's programs.keepassxc.settings creates a read-only store
  # symlink, which KeePassXC rejects. Seed a real mode-0600 file, then leave it
  # writable so KeePassXC can safely store runtime preferences and association
  # state. Replace the old managed symlink during the first activation.
  home.activation.keepassxcWritableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file=${lib.escapeShellArg "${config.xdg.configHome}/keepassxc/keepassxc.ini"}

    if [ -L "$config_file" ]; then
      $DRY_RUN_CMD rm -f "$config_file"
    fi

    if [ ! -e "$config_file" ]; then
      $DRY_RUN_CMD install -Dm600 ${settingsFile} "$config_file"
    fi
  '';
}
