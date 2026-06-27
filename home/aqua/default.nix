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

  # ── XDG user directories ────────────────────────────────────────────────
  # persistence.nix bind-mounts the persistent copies that physically live
  # under /saved/home/aqua back onto these standard ~/ paths. So you access
  # data at ~/Documents etc.; the /saved backing store is kept out of GNOME
  # Files via `x-gvfs-hide` (see preservation.nix + disko.nix).
  #
  # Downloads intentionally stays on the tmpfs root → wiped on every reboot.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop     = "${config.home.homeDirectory}/Desktop";
    documents   = "${config.home.homeDirectory}/Documents";
    download    = "${config.home.homeDirectory}/Downloads"; # tmpfs — wiped on reboot
    music       = "${config.home.homeDirectory}/Music";
    pictures    = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates   = "${config.home.homeDirectory}/Templates";
    videos      = "${config.home.homeDirectory}/Videos";
    projects    = "${config.home.homeDirectory}/Projects";
  };

  # Let home-manager manage these
  programs.home-manager.enable = true;

  # ── Nix user config → /saved/secrets/nix.conf ─────────────
  # Points ~/.config/nix/nix.conf to the persistent secrets file
  # (access-tokens for GitHub API, etc.). The file lives in /saved
  # (btrfs subvolume) so it survives tmpfs wipes.
  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/saved/secrets/nix.conf";
}
