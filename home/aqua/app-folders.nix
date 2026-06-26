# App folders for the GNOME "Show Applications" grid
#
# Groups Flatpak apps into folders with numbered prefixes so folders
# sort before individual apps (numbers come before letters).
#
# Folder display names use "N Name" format → "1 Chat", "2 Social", etc.
# The numbers are only for sort ordering — you can rename folders later
# via drag-and-drop without affecting persistence.
#
# References:
#   org.gnome.desktop.app-folders          — parent schema (folder registry)
#   org.gnome.desktop.app-folders.folder  — per-folder settings
{
  lib,
  pkgs,
  ...
}:

let
  # ── Folder definitions ─────────────────────────────────────────
  # id:    short, URL-safe identifier used as the dconf path
  # name:  display name (the "N " prefix forces folders to the top)
  # apps:  list of .desktop file IDs (Flatpak IDs without the .desktop suffix)
  folders = {
    "01-Chat" = {
      name = "1 Chat";
      apps = [
        "org.signal.Signal"
        "org.telegram.desktop"
        "chat.simplex.simplex"
        "dev.vencord.Vesktop"
        "org.gnome.Fractal"
      ];
    };

    "02-Social" = {
      name = "2 Social";
      apps = [
        "dev.geopjr.Tuba"
        "io.gitlab.news_flash.NewsFlash"
      ];
    };

    "03-Office" = {
      name = "3 Office";
      apps = [
        "org.onlyoffice.desktopeditors"
        "org.keepassxc.KeePassXC"
        "org.gnome.World.Secrets"
        "com.belmoussaoui.Authenticator"
      ];
    };

    "04-Tools" = {
      name = "4 Tools";
      apps = [
        "com.github.tchx84.Flatseal"
        "com.github.ADBeveridge.Raider"
        "de.wwwtech.gitte"
        "io.github.sniper1720.khushu"
      ];
    };
  };

  # Build the GVariant for the folder:/ key (type a{sa{sv}}).
  # This tells GNOME Shell which folders to display.
  folderVar =
    "{"
    + (lib.concatStringsSep ", " (lib.mapAttrsToList (id: data:
      "'${id}': <{"
      + "'name': <'${data.name}'>"
      + ", 'apps': <${builtins.toJSON data.apps}>"
      + "}>"
    ) folders))
    + "}";

in
{
  # ── Persist dconf database (GNOME settings, app grid layout, etc.) ─
  # We create both the target dir and the symlink ourselves (not via
  # preservation.nix or home.file) so ownership is always correct.
  home.activation.ensureDconfDir = lib.hm.dag.entryBefore ["writeBoundary"] ''
    DST=/saved/home/aqua/.config/dconf
    LINK="$HOME/.config/dconf"

    # If a previous (failed) preservation attempt left a root-owned directory,
    # the rebuild will fail here. One-time fix:
    #   sudo rm -rf /saved/home/aqua/.config/dconf
    if [ -d "$DST" ] && [ ! -w "$DST" ]; then
      echo >&2 "!!! $DST is root-owned - run: sudo rm -rf $DST && rebuild"
      exit 1
    fi

    mkdir -p "$DST"
    chmod 0700 "$DST"

    # Replace any real directory with a symlink to the persistent copy
    if [ ! -L "$LINK" ] && [ -e "$LINK" ]; then
      mv "$LINK" "$LINK.bak.$(date +%s)"
    fi
    ln -sfn "$DST" "$LINK"
  '';

  # ── App folders ────────────────────────────────────────────
  home.activation.setupAppFolders = lib.hm.dag.entryAfter ["writeBoundary"] ''
    DCONF="${pkgs.dconf}/bin/dconf"

    # ── Write per-folder settings ──────────────────────────────
    ${lib.concatStringsSep "\n    " (lib.mapAttrsToList (id: data: ''
      $DCONF write /org/gnome/desktop/app-folders/folders/${id}/name "'${data.name}'"
      $DCONF write /org/gnome/desktop/app-folders/folders/${id}/apps "${builtins.toJSON data.apps}"
      $DCONF write /org/gnome/desktop/app-folders/folders/${id}/translate "false"
    '') folders)}

    # ── Register folders in the parent key ────────────────────
    # Without this, GNOME Shell won't discover the folders.
    $DCONF write /org/gnome/desktop/app-folders/folder:/ '${folderVar}'
  '';
}
