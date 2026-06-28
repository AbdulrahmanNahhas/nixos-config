# Flatpak declarative management via nix-flatpak
#
# Search for app IDs at https://flathub.org
# Add entries to the packages list below.
{ ... }:

{
  services.flatpak = {
    enable = true;

    # ── Remotes ────────────────────────────────────────────
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # ── Packages ───────────────────────────────────────────
    packages = [
      # System
      "com.github.tchx84.Flatseal"
      "com.brave.Browser"

      # Social Media Communication
      "chat.simplex.simplex"
      "org.signal.Signal"
      "org.telegram.desktop"
      "dev.vencord.Vesktop"
      "org.gnome.Fractal"

      # Social & Web Content
      "dev.geopjr.Tuba"
      "io.gitlab.news_flash.NewsFlash"

      # Other
      "org.onlyoffice.desktopeditors"
      "com.github.ADBeveridge.Raider"
      "de.wwwtech.gitte"
      "io.github.sniper1720.khushu" # Prayer Times
      "org.keepassxc.KeePassXC"
      "com.belmoussaoui.Authenticator"
      "org.gnome.World.Secrets"
    ];
  };
}
