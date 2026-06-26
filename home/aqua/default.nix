# Home-manager config for aqua
{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./apps/zed.nix
    ./apps/firefox.nix
    ./apps/ghostty.nix
    ./cli/packages.nix
    ./cli/fish.nix
    ./cli/fastfetch.nix
    ./gnome-extensions.nix
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
      GNOME   = [ "com.mitchellh.ghostty.desktop" ];
    };
  };

  # ── GTK  ────────────────────────────────────
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3-dark";
      color-scheme = "prefer-dark";

      font-name = "Cantarell 11";
      document-font-name = "Cantarell 11";
      monospace-font-name = "GeistMono Nerd Font Mono 11";
    };
  };

  # ── XDG user directories ────────────────────────────────
  # All user data lives on /saved (persistent across wipes)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop     = "/saved/home/${config.home.username}/Desktop";
    documents   = "/saved/home/${config.home.username}/Documents";
    download    = "${config.home.homeDirectory}/Downloads"; # tmpfs — intentionally wiped on reboot
    music       = "/saved/home/${config.home.username}/Music";
    pictures    = "/saved/home/${config.home.username}/Pictures";
    publicShare = "/saved/home/${config.home.username}/Public";
    templates   = "/saved/home/${config.home.username}/Templates";
    videos      = "/saved/home/${config.home.username}/Videos";
    projects      = "/saved/home/${config.home.username}/Projects";
  };

  # Let home-manager manage these
  programs.home-manager.enable = true;
}
