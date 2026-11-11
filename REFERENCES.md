# References and notes

[Project guide](README.md) · [Technology roadmap](ROADMAP.md)

Decisions, release watches and useful sources—not a package inventory or a second
checklist. The roadmap owns technologies and adoption status; configuration owns
exact packages and settings. Notes here do not establish live verification.

## OS and configuration

| Tool                               | Purpose                                            | Technology / interface | Management / status                           | Notes                                                                                                                                                                                                                                                                                                       |
| ---------------------------------- | -------------------------------------------------- | ---------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [ClamAV](https://docs.clamav.net/) | Manual malware scans of USB drives and other files | C/C++; CLI             | [NixOS](system/security/clamav.nix); declared | Automatic signature updates; scanner daemon, scheduled scans and on-access scanning disabled. Signatures persist across reboots. Run `sudo systemctl start clamav-freshclam.service` before the first scan, then `clamscan --recursive --infected /path/to/usb`. Reports detections without deleting files. |

## Release watches

| Topic                | Preference or decision                                                                                                                          | Source                                                                                                              |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Flatpak v2           | Waiting for v2; follow upstream before deciding whether anything needs changing. No release date or specific benefit assumed.                   | [Releases](https://github.com/flatpak/flatpak/releases) · [Issues](https://github.com/flatpak/flatpak/issues)       |

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
