let
  remoteName = "artcraft-oci";

  # Shared sandbox defaults; each app below declares only its exceptions.
  mkCraftApp =
    {
      waylandVariable ? null,
      audio ? false,
      filesystems ? [ ],
    }:
    {
      origin = remoteName;
      overrides = {
        Environment = {
          DISPLAY = "";
        }
        // (if waylandVariable == null then { } else { ${waylandVariable} = "1"; });
        Context = {
          shared = [
            "!network"
            "!ipc"
          ];
          sockets = [
            "wayland"
            "!x11"
            "!fallback-x11"
            "!cups"
            (if audio then "pulseaudio" else "!pulseaudio")
          ];
          inherit filesystems;
        };
        # Upstream's updater uses this service to execute commands outside the sandbox.
        "Session Bus Policy"."org.freedesktop.Flatpak" = "none";
        "System Bus Policy"."org.freedesktop.Avahi" = "none";
      };
    };
in
{
  remote =
    { pkgs }:
    {
      name = remoteName;
      # Pin the repository descriptor and trust key; app versions follow stable.
      location = "${pkgs.fetchurl {
        url = "https://getartcraft.com/artcraft-oci.flatpakrepo";
        sha256 = "dfb24158a32a4fd435eb482aff5a394efb77f006aa42a1cc9f535f380bddbbc0";
      }}";
    };

  apps = {
    "ai.storyteller.wordcraft" = mkCraftApp { waylandVariable = "WORDCRAFT_WAYLAND"; };
    "ai.storyteller.photocraft" = mkCraftApp { };
    "ai.storyteller.filmcraft" = mkCraftApp {
      waylandVariable = "FILMCRAFT_WAYLAND";
      audio = true;
      # Projects resolve referenced media by path, including on subsequent launches.
      filesystems = [ "xdg-videos" ];
    };
    "ai.storyteller.pdfcraft" = mkCraftApp { };
    "ai.storyteller.deckcraft" = mkCraftApp {
      waylandVariable = "DECKCRAFT_WAYLAND";
      audio = true;
    };
    "ai.storyteller.cadcraft" = mkCraftApp { waylandVariable = "CADCRAFT_WAYLAND"; };
    "ai.storyteller.gridcraft" = mkCraftApp { waylandVariable = "GRIDCRAFT_WAYLAND"; };
  };
}
