# References and notes

[Project guide](README.md) · [Technology roadmap](ROADMAP.md)

Decisions, release watches and useful sources—not a package inventory or a second
checklist. The roadmap owns technologies and adoption status; configuration owns
exact packages and settings. Notes here do not establish live verification.

## OS and configuration

| Tool                               | Purpose                                            | Technology / interface | Management / status                           | Notes                                                                                                                                                                                                                                                                                                       |
| ---------------------------------- | -------------------------------------------------- | ---------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [ClamAV](https://docs.clamav.net/) | Manual malware scans of USB drives and other files | C/C++; CLI             | [NixOS](system/security/clamav.nix); declared | Automatic signature updates; scanner daemon, scheduled scans and on-access scanning disabled. Signatures persist across reboots. Run `sudo systemctl start clamav-freshclam.service` before the first scan, then `clamscan --recursive --infected /path/to/usb`. Reports detections without deleting files. |

### Desktop appearance

| Tool                                                                    | Purpose              | Technology / interface | Management / status                                      | Notes                                                                                                                                                                                                                          |
| ----------------------------------------------------------------------- | -------------------- | ---------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) | GTK and COSMIC icons | SVG icon theme         | [Home Manager](home/desktop/gtk.nix); replaces MoreWaita | Static Papirus-Dark for GTK and COSMIC. Automatic folder recoloring is intentionally disabled. The user reports matching folder icons in COSMIC Files and the picker; custom Books/Projects icon assignment is not configured. |

## Applications and tools

| Tool                                                                                             | Purpose                                                     | Technology / interface                 | Management / status                                                                            | Notes                                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Rofi](https://github.com/davatorium/rofi) + [rofi-calc](https://github.com/svenstaro/rofi-calc) | Desktop menu, live calculator, currency and unit conversion | Native C launcher UI; Qalculate engine | [Home Manager](home/desktop/menu/default.nix); declared, calculator awaiting host verification | Tools → Calculator / Currency converter / Unit converter. Enter copies the result to the Wayland clipboard; calculation history is disabled. Currency conversion uses Qalculate rates; rofi-calc requests daily rate updates automatically when needed. “Refresh exchange rates” also allows a manual update. Downloads require internet; offline rates may be stale. |

### COSMIC desktop utilities

These declarations keep the existing compositor and Noctalia; they do not enable
COSMIC Desktop. COSMIC uses its native theme; Noctalia's COSMIC theme integration
is disabled. Activation and host acceptance are still required.

| Tool                                                                 | Purpose                  | Technology / interface       | Management / status                                                     | Notes                                                                                                                             |
| -------------------------------------------------------------------- | ------------------------ | ---------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [COSMIC Files](https://github.com/pop-os/cosmic-files)               | GUI file management      | Rust; libcosmic/Iced         | [Nix packages](home/packages.nix); replaces Nautilus declaration        | Directory default; Yazi remains available.                                                                                        |
| [COSMIC portal](https://github.com/pop-os/xdg-desktop-portal-cosmic) | Open/Save dialogs        | Rust; XDG portal, libcosmic  | [System integration](system/desktop/integration.nix); declared          | FileChooser only, with GTK fallback; existing screen-sharing backends retained. Applications must use portals to get this picker. |
| [COSMIC Edit](https://github.com/pop-os/cosmic-edit)                 | Simple GUI text editing  | Rust; libcosmic/Iced         | [Nix packages](home/packages.nix); [text default](home/desktop/xdg.nix) | Replaces the GNOME Text Editor handler; Zed and Helix remain.                                                                     |
| [COSMIC Monitor](https://github.com/pop-os/cosmic-monitor)           | GUI system monitoring    | Rust; libcosmic/Iced         | [Nix packages](home/packages.nix); replaces Resources declaration       | btop remains available.                                                                                                           |
| [COSMIC Viewer](https://github.com/pop-os/cosmic-viewer)             | Image viewing and markup | Rust; libcosmic/Iced         | [Nix packages](home/packages.nix); trial                                | Loupe remains installed and the image default pending review.                                                                     |
| [Loupe](https://apps.gnome.org/Loupe/)                               | Image viewing            | Rust; GTK4/libadwaita        | [Nix packages](home/packages.nix); retained                             | Compare with COSMIC Viewer before replacing.                                                                                      |
| [Cine](https://github.com/diegopvlk/Cine)                            | Audio/video playback     | GTK4/libadwaita; MPV backend | [Flatpak](system/desktop/flatpak/apps.nix); retained default            | Preferred over COSMIC Player for subtitle and audio features; Player is no longer declared.                                       |

Ghostty, btop and Noctalia are retained. COSMIC Terminal and Store are not selected.
Quick Web Apps and Ethereal Waves trials are deferred; neither is declared here.
GTK fallback bookmarks are managed separately from COSMIC's editable, persisted
favorites. Books, Projects and the repository are already present in the inspected
COSMIC favorites; no automatic GTK/COSMIC synchronization is configured.

Noctalia reads Umbriel's optional theme include without modifying its Nix-owned
configuration. Starship's custom palette uses terminal ANSI colors and follows
Ghostty's Noctalia theme; the community hook that rewrites `starship.toml` is disabled.

### Music

| Tool                                         | Purpose                            | Technology / interface                  | Management / status                                              | Notes                                                                                                                                                                             |
| -------------------------------------------- | ---------------------------------- | --------------------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Sonora](https://github.com/sonorahq/sonora) | Music streaming and local playback | Rust; GPUI; embedded WebKitGTK on Linux | [Official Nix flake](home/apps/sonora.nix); stable-channel trial | Upstream dependency pins retained for its signed Cachix builds; Cine remains the media default. Settings and library state persist; activation and playback are not yet verified. |

### Document tools

| Tool                                                       | Purpose                                     | Technology / interface | Management / status                                              | Notes                                                                            |
| ---------------------------------------------------------- | ------------------------------------------- | ---------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [PDF Arranger](https://github.com/pdfarranger/pdfarranger) | Merge, split, reorder, rotate and crop PDFs | Python; GTK3; pikepdf  | [Flatpak](system/desktop/flatpak/apps.nix); selected PDF utility | Papers remains the PDF viewer and default; no standalone PDF CLI tools selected. |

Foliate is the selected ebook reader and EPUB/CBZ default, managed through the
[Flatpak catalog](system/desktop/flatpak/apps.nix). It uses JavaScript,
GTK4/libadwaita and WebKitGTK. Readest is no longer declared; Papers remains the
PDF and CBR default. Foliate does not advertise CBR support. [Foliate upstream](https://github.com/johnfactotum/foliate).

LibreOffice is no longer declared; choosing another office suite is deferred.

## Release watches

| Topic      | Preference or decision                                                                                                        | Source                                                                                                        |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Flatpak v2 | Waiting for v2; follow upstream before deciding whether anything needs changing. No release date or specific benefit assumed. | [Releases](https://github.com/flatpak/flatpak/releases) · [Issues](https://github.com/flatpak/flatpak/issues) |

## Caveats worth keeping

- **Application state:** changing a persistence mount can hide existing data.
  Follow the [migration guidance](README.md#persistence-and-secrets) before activation.
- **Signal:** key-storage migration remains unverified. Preserve the closed profile
  and keyring before changing its backend; never reset the profile to force success.
- **Reflection:** the beta does not guarantee future data migration. Don't make it
  the only copy of important notes. [Upstream](https://modal.cx/reflection/).
- **Nahhasio:** the signed alpha remote's descriptor is pinned, not each app update.
  Preserve existing profile data when migrating. [Upstream](https://github.com/AbdulrahmanNahhas/nahhasio).
- **OpenRazer:** the service is disabled as a workaround; having a controller UI
  installed does not mean device control works. [Configuration](system/hardware/openrazer.nix).
  Polychromatic is retained for the Razer Blade, with its packaged login autostart
  disabled in [Home Manager](home/packages.nix).
- **Editor toolchains:** selecting a language server or formatter does not install
  every project dependency. [Development environment](home/apps/environment.nix).
- **Sandbox permissions:** packaging alone says nothing about effective isolation;
  inspect the [Flatpak policy](system/desktop/flatpak/policy.nix) and per-app exceptions.
- **File shredding:** don't assume secure erasure on SSDs or copy-on-write filesystems.

## Useful sources

| Need                                 | Start here                                                                                                                                                                                         |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Learn Nix                            | [nix.dev](https://nix.dev/) · [Nix language tutorial](https://nix.dev/tutorials/nix-language) · [Nix Pills](https://nixos.org/guides/nix-pills/)                                                   |
| Understand modules and options       | [Module-system tutorial](https://nix.dev/tutorials/module-system/) · [NixOS manual](https://nixos.org/manual/nixos/stable/) · [Home Manager manual](https://nix-community.github.io/home-manager/) |
| Find packages, options and functions | [NixOS Search](https://search.nixos.org/) · [MyNixOS](https://mynixos.com/) · [Noogle](https://noogle.dev/)                                                                                        |
| Follow upstream changes              | [NixOS release notes](https://nixos.org/manual/nixos/unstable/release-notes.html) · [Nix release notes](https://nix.dev/manual/nix/latest/release-notes.html)                                      |
| Discover projects                    | [Awesome Nix](https://github.com/nix-community/awesome-nix) · [Nix Software](https://nixsoftware.org/en) · [Nixmap](https://vimjoyer.com/nixmap/)                                                  |
| Ask or investigate                   | [NixOS Discourse](https://discourse.nixos.org/) · [NixOS Wiki](https://wiki.nixos.org/) · [Nixpkgs issues](https://github.com/NixOS/nixpkgs/issues)                                                |
| Desktop integration                  | [Noctalia docs](https://docs.noctalia.dev/) · [Niri docs](https://niri-wm.github.io/niri/) · [XDG portal docs](https://flatpak.github.io/xdg-desktop-portal/)                                      |
| Gaming compatibility                 | [ProtonDB](https://www.protondb.com/) · [PCGamingWiki](https://www.pcgamingwiki.com/)                                                                                                              |

Community recipes and search results may describe different versions. Check the
owning configuration and upstream documentation before copying settings.

## Find exact declarations

- [System features](configuration.nix) · [User features](home.nix)
- [User packages](home/packages.nix) · [Flatpak catalog](system/desktop/flatpak/apps.nix)
- [Gaming](gaming/) · [Desktop commands](home/desktop/menu/shadow.nu)
- [Disabled service drafts](configuration.nix) · [AI experiments](home/apps/ai/default.nix)

Update this document only for lasting notes, important release watches or useful
sources—not routine settings, package changes or task progress.
