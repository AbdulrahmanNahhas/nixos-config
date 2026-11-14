# GUI applications by technology

Declared applications, not a live installation or display-backend audit. CLI/TUI
and background services are excluded. Trials and defaults are marked below.

[Project guide](README.md) · [References](REFERENCES.md) · [Defaults](home/desktop/xdg.nix)

## GPUI

| Application                                          | Category                      | Technology                                     | Configuration / status                                                        |
| ---------------------------------------------------- | ----------------------------- | ---------------------------------------------- | ----------------------------------------------------------------------------- |
| [Zed](https://github.com/zed-industries/zed)         | Code editor                   | Rust; GPUI                                     | [Home Manager](home/apps/zed/default.nix)                                     |
| [Delta](https://github.com/zed-industries/delta-nix) | Development                   | GPUI                                           | [Home Manager](home/apps/delta.nix)                                           |
| [Herdr](https://github.com/herdrdev/herdr-app)       | Terminal / coding agents      | Rust; GPUI / GPUI Kit; Ghostty integration     | [Home Manager](home/apps/herdr.nix)                                           |
| [Sonora](https://github.com/sonorahq/sonora)         | Music streaming / local music | Rust; GPUI; WebKitGTK for embedded web content | [Nix package](home/apps/sonora.nix); stable-channel trial, defaults unchanged |

## COSMIC — Rust / libcosmic / Iced

| Application                                                                      | Category              | Technology                  | Configuration / status                                                    |
| -------------------------------------------------------------------------------- | --------------------- | --------------------------- | ------------------------------------------------------------------------- |
| [COSMIC Files](https://github.com/pop-os/cosmic-files)                           | File manager          | Rust; libcosmic/Iced        | [Nix packages](home/packages.nix); directory default                      |
| [COSMIC Edit](https://github.com/pop-os/cosmic-edit)                             | Text editor           | Rust; libcosmic/Iced        | [Nix packages](home/packages.nix); text/Markdown default                  |
| [COSMIC Monitor](https://github.com/pop-os/cosmic-monitor)                       | System monitor        | Rust; libcosmic/Iced        | [Nix packages](home/packages.nix)                                         |
| [COSMIC Viewer](https://github.com/pop-os/cosmic-viewer)                         | Image viewer / editor | Rust; libcosmic/Iced        | [Nix packages](home/packages.nix); trial, Loupe remains default           |
| [COSMIC file-picker portal](https://github.com/pop-os/xdg-desktop-portal-cosmic) | Desktop integration   | Rust; libcosmic; XDG portal | [System integration](system/desktop/integration.nix); FileChooser backend |

## Zig

| Application                     | Category | Technology                                     | Configuration / status                                              |
| ------------------------------- | -------- | ---------------------------------------------- | ------------------------------------------------------------------- |
| [Ghostty](https://ghostty.org/) | Terminal | Zig core; GTK4 Linux integration; GPU renderer | [Home Manager](home/terminal/ghostty/default.nix); terminal default |

## GTK4 / libadwaita — Rust

| Application                                           | Category              | Technology              | Configuration / status                                         |
| ----------------------------------------------------- | --------------------- | ----------------------- | -------------------------------------------------------------- |
| [Impression](https://apps.gnome.org/Impression/)      | Disk-image writer     | Rust; GTK4/libadwaita   | [Flatpak](system/desktop/flatpak/apps.nix)                     |
| [Reflection](https://github.com/p2panda/reflection)   | Collaborative notes   | Rust; GTK4/libadwaita   | [Flatpak](system/desktop/flatpak/apps.nix); testing, beta      |
| [Papers](https://apps.gnome.org/Papers/)              | PDF / document reader | Rust/C; GTK4/libadwaita | [Nix packages](home/packages.nix); document default            |
| [NewsFlash](https://apps.gnome.org/NewsFlash/)        | RSS reader            | Rust; GTK4/libadwaita   | [Flatpak](system/desktop/flatpak/apps.nix)                     |
| [Fractal](https://apps.gnome.org/Fractal/)            | Matrix messaging      | Rust; GTK4/libadwaita   | [Flatpak](system/desktop/flatpak/apps.nix)                     |
| [Loupe](https://apps.gnome.org/Loupe/)                | Image viewer          | Rust; GTK4/libadwaita   | [Nix packages](home/packages.nix); image default, under review |
| [Video Trimmer](https://apps.gnome.org/VideoTrimmer/) | Video editing         | Rust; GTK4/libadwaita   | [Flatpak](system/desktop/flatpak/apps.nix)                     |

## GTK4 / libadwaita — Python / Vala

| Application                                         | Category              | Technology                   | Configuration / status                                    |
| --------------------------------------------------- | --------------------- | ---------------------------- | --------------------------------------------------------- |
| [Secrets](https://apps.gnome.org/Secrets/)          | Password manager      | Python; GTK4/libadwaita      | [Flatpak](system/desktop/flatpak/apps.nix)                |
| [Ear Tag](https://apps.gnome.org/EarTag/)           | Audio metadata editor | Python; GTK4/libadwaita      | [Flatpak](system/desktop/flatpak/apps.nix)                |
| [Tuba](https://apps.gnome.org/Tuba/)                | Fediverse client      | Vala; GTK4/libadwaita        | [Flatpak](system/desktop/flatpak/apps.nix)                |
| [Cine](https://github.com/diegopvlk/Cine)           | Media player          | Python; GTK4/libadwaita; MPV | [Flatpak](system/desktop/flatpak/apps.nix); media default |
| [Upscaler](https://gitlab.gnome.org/World/Upscaler) | Image upscaling       | Python; GTK4/libadwaita      | [Flatpak](system/desktop/flatpak/apps.nix)                |

## GTK4 / libadwaita — C

| Application                                     | Category       | Technology         | Configuration / status                     |
| ----------------------------------------------- | -------------- | ------------------ | ------------------------------------------ |
| [Raider](https://github.com/ADBeveridge/raider) | File shredding | C; GTK4/libadwaita | [Flatpak](system/desktop/flatpak/apps.nix) |

## GTK / WebKitGTK hybrids

| Application                                               | Category                      | Technology                                             | Configuration / status                                                                    |
| --------------------------------------------------------- | ----------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| [Foliate](https://github.com/johnfactotum/foliate)        | Ebook reader                  | JavaScript; GTK4/libadwaita; WebKitGTK                 | [Flatpak](system/desktop/flatpak/apps.nix); EPUB and CBZ default; CBR remains with Papers |
| [Nahhasio](https://github.com/AbdulrahmanNahhas/nahhasio) | Family media catalog / player | Rust GTK4/libadwaita shell; React in WebKitGTK; libmpv | [Flatpak](system/desktop/flatpak/apps.nix); alpha                                         |

## GTK3

| Application                                                | Category        | Technology            | Configuration / status                                           |
| ---------------------------------------------------------- | --------------- | --------------------- | ---------------------------------------------------------------- |
| [GNOME Disks](https://apps.gnome.org/DiskUtility/)         | Disk management | C; GTK3               | [Nix packages](home/packages.nix)                                |
| [PDF Arranger](https://github.com/pdfarranger/pdfarranger) | PDF utilities   | Python; GTK3; pikepdf | [Flatpak](system/desktop/flatpak/apps.nix); selected PDF utility |

## Electron

| Application                                                      | Category                     | Technology | Configuration / status                                                 |
| ---------------------------------------------------------------- | ---------------------------- | ---------- | ---------------------------------------------------------------------- |
| [Codex Desktop](https://github.com/ilysenko/codex-desktop-linux) | AI coding client             | Electron   | [Home Manager](home/apps/codex-desktop.nix); community Linux packaging |
| [Obsidian](https://obsidian.md/)                                 | Notes / knowledge management | Electron   | [Nix packages](home/packages.nix)                                      |
| [Signal](https://signal.org/)                                    | Messaging / calls            | Electron   | [Flatpak](system/desktop/flatpak/apps.nix)                             |
| [Heroic Games Launcher](https://heroicgameslauncher.com/)        | Game launcher                | Electron   | [Flatpak](gaming/flatpak-apps.nix)                                     |

## Qt

| Application                                                     | Category             | Technology                      | Configuration / status                                                                                  |
| --------------------------------------------------------------- | -------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------- |
| [Telegram Desktop](https://desktop.telegram.org/)               | Messaging / calls    | C++; Qt                         | [Flatpak](system/desktop/flatpak/apps.nix)                                                              |
| [Polychromatic](https://github.com/polychromatic/polychromatic) | Razer device control | Python; Qt6/PyQt6; Qt WebEngine | [Nix packages](home/packages.nix); kept for Razer Blade, autostart disabled; OpenRazer service disabled |

## Gecko

| Application                                    | Category        | Technology          | Configuration / status                                         |
| ---------------------------------------------- | --------------- | ------------------- | -------------------------------------------------------------- |
| [Firefox](https://www.mozilla.org/firefox/)    | Web browser     | Gecko; C++ and Rust | [Home Manager](home/apps/firefox/default.nix); browser default |
| [Mullvad Browser](https://mullvad.net/browser) | Privacy browser | Firefox/Gecko-based | [Nix packages](home/packages.nix)                              |

## CEF — Chromium Embedded Framework

| Application                                    | Category      | Technology                                              | Configuration / status                               |
| ---------------------------------------------- | ------------- | ------------------------------------------------------- | ---------------------------------------------------- |
| [Steam](https://store.steampowered.com/about/) | Game launcher | Proprietary client; CEF web UI components, not Electron | [NixOS](gaming/system.nix); expected XWayland client |
