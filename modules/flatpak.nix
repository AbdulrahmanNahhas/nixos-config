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
      "com.github.tchx84.Flatseal"
      "com.brave.Browser"
      "chat.simplex.simplex"
      "org.signal.Signal"
      "org.telegram.desktop"
      "dev.vencord.Vesktop"
      "org.gnome.Fractal"
      "dev.geopjr.Tuba"
      "io.gitlab.news_flash.NewsFlash"
      "org.onlyoffice.desktopeditors"
      "com.github.ADBeveridge.Raider"
      "de.wwwtech.gitte"
      "io.github.sniper1720.khushu"
      "org.keepassxc.KeePassXC"
      "com.belmoussaoui.Authenticator"
      "org.gnome.World.Secrets"
      "io.bassi.Amberol"
    ];
  };
}
