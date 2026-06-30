{ config, pkgs, ... }:
{
  imports = [
    ./apps/zed.nix
    ./apps/firefox.nix
    ./apps/ghostty.nix
    ./cli/packages.nix
    ./cli/fish.nix
    ./cli/fastfetch.nix
    ./gnome-extensions.nix
    ./gnome.nix
  ];

  home = {
    username = "aqua";
    homeDirectory = "/home/aqua";
    stateVersion = "26.05";
    sessionVariables = {
      PATH = "/etc/profiles/per-user/${config.home.username}/bin:$PATH";
      EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  # ── Default Terminal Routing Layer ──────────────────────
  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "com.mitchellh.ghostty.desktop" ];
      GNOME = [ "com.mitchellh.ghostty.desktop" ];
    };
  };

  # ── Default Browser Routing ─────────────────────────────
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
    };
  };

  # ── GTK  ────────────────────────────────────
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 26;
  };

  # ── XDG user directories ────────────────────────────────────────────────
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads"; # tmpfs — wiped on reboot
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
    projects = "${config.home.homeDirectory}/Projects";
  };

  programs.home-manager.enable = true;

  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/saved/secrets/nix.conf";
}
