{
"title": "Add & manage a Flatpak",
"group": "DAILY WORK",
"weight": 7,
"sources": [
[
"nix-flatpak",
"https://github.com/gmodena/nix-flatpak"
],
[
"Flatpak basic commands",
"https://docs.flatpak.org/en/latest/using-flatpak.html"
]
],
"build": {
"render": "link",
"list": "always"
}
}

The catalog’s keys are application IDs. An empty entry uses the default verified Flathub remote and retains its data under `~/.var/app/<id>`. `origin` chooses a different remote. `overrides` declares permissions and environment changes. `persist = false;` is used for theme extensions with no application state.

```
"org.example.App" = {
  origin = "flathub";
  overrides.Context.filesystems = [ "xdg-download:ro" ];
};
```

This is a shape example, not an installable app recommendation. Look up the actual ID, publisher, supported branch, and required permissions before adding it. Verified publishing identifies the publisher; it does not guarantee harmless code or a narrow sandbox.

## After editing

1.  Review the app’s upstream permissions and expected workflows.
2.  Format and evaluate the repository.
3.  Build, then activate when ready.
4.  Confirm installation and launch it.
5.  Check file selection, downloads, audio, camera, screen sharing, and persistence after reboot where relevant.

```
flatpak list --app --columns=application,origin
flatpak info --show-permissions org.example.App
flatpak override --system --show org.example.App
flatpak override --user --show org.example.App
```

System and user installations are distinct. This repository owns the system installation, including managed override files. Manual system installs can be removed by reconciliation; manual user installs do not automatically gain declared persistence. A user override may take precedence over system policy and must be inspected when behavior differs.

`strictFilesystems = true;` opts into resetting inherited filesystem grants before applying read-only GTK theme access and this entry’s explicit paths. It is enabled for EarTag, Upscaler, Cine, and Nocturne. Other apps retain their existing narrower manifest permissions until their workflows are reviewed.

PrismLauncher and Subtitle Composer have been removed from the managed catalog. With `uninstallUnmanaged = true`, the next successful system reconciliation can uninstall those system apps and prune PrismLauncher's managed override. Their old backing data under `/saved` remains until explicitly reviewed and removed; their per-app preservation mounts are no longer declared. There is no longer a PrismLauncher X11 exception in this catalog.

The daily Flatpak timer updates apps independently of `flake.lock`. NixOS generation rollback does not restore a frozen Flatpak application/data snapshot. Removing the catalog entry stops managing its persistence, but old backing data under `/saved` should be removed only after a deliberate data review.
