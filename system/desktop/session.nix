{ config, username, ... }:
let
  cursor = config.home-manager.users.${username}.home.pointerCursor;
in
{
  services.displayManager.defaultSession = "niri";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  services.displayManager.noctalia-greeter = {
    enable = true;
    cursorTheme = { inherit (cursor) package name; };

    settings = {
      appearance.scheme = "Ayu";
      cursor.size = cursor.size;
      session.default = "niri";
      user.default = username;
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  programs.niri.enable = true;
}
