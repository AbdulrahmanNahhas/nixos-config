{
  config,
  inputs,
  ...
}:
{
  programs.firefox.profiles.aqua = {
    # Import the GNOME theme's CSS entry points. Firefox resolves these
    # `@import`s relative to the profile's `chrome/` directory.
    userChrome = ''
      @import "firefox-gnome-theme/userChrome.css";
    '';

    userContent = ''
      @import "firefox-gnome-theme/userContent.css";
    '';
  };

  # ── Symlink the GNOME theme into the profile's chrome directory ──────────
  #
  # IMPORTANT: in this nixpkgs/home-manager version, the firefox module writes
  # profiles under `${xdg.configHome}/mozilla/firefox/` (i.e. `~/.config/...`),
  # NOT `~/.mozilla/firefox/`. The theme assets must therefore live next to
  # the HM-managed `userChrome.css` so the `@import` paths resolve — this was
  # the cause of the previous "theme not loading" bug.
  home.file."${config.xdg.configHome}/mozilla/firefox/${config.programs.firefox.profiles.aqua.path}/chrome/firefox-gnome-theme".source =
    inputs.firefox-gnome-theme;
}
