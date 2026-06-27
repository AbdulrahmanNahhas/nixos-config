# Fastfetch – Software Version Tracker
# Usage: fastfetch -c packages
{
  pkgs,
  lib,
  ...
}:

let
  # Extract version from a Nix package (or "—" if unavailable)
  ver = pkg: if (pkg ? version) && builtins.isString pkg.version then pkg.version else "—";

  # Flatpak installation check (runtime)
  fpInstalled = id: "flatpak info " + id + " 2>/dev/null >/dev/null && echo 'flatpak' || echo '—'";
in
{
  # ── ASCII logo ──────────────────────────────────────────────────
  xdg.configFile."fastfetch/fastfetch-packages.txt".source = ./fastfetch-packages.txt;

  # ── JSON config (loaded via `fastfetch -c packages`) ────────────
  xdg.configFile."fastfetch/packages.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "~/.config/fastfetch/fastfetch-packages.txt",
        "type": "file",
        "padding": {
          "top": 0,
          "left": 2
        },
        "color": {
          "1": "bright_blue",
          "2": "bright_magenta",
          "3": "bright_cyan",
          "4": "bright_green"
        }
      },
      "display": {
        "separator": " · ",
        "color": "white"
      },
      "modules": [

        /* ═══════════════════════════════════════════════════════
           ❄️  FOUNDATION
           ═══════════════════════════════════════════════════════ */
        {
          "type": "custom",
          "key": "{#34}❄️  FOUNDATION{##}",
          "keyColor": "bright_blue"
        },
        {
          "type": "os",
          "key": "  ◆ OS     ",
          "keyColor": "bright_blue"
        },
        {
          "type": "kernel",
          "key": "  ◆ Kernel ",
          "keyColor": "bright_blue"
        },
        {
          "type": "de",
          "key": "  ◆ Desktop",
          "keyColor": "bright_blue"
        },
        {
          "type": "wm",
          "key": "  ◆ WM     ",
          "keyColor": "bright_blue"
        },
        {
          "type": "custom",
          "key": "  ◆ Shell  ",
          "command": "echo 'fish '${ver pkgs.fish}'",
          "keyColor": "bright_blue"
        },
        "break",

        /* ═══════════════════════════════════════════════════════
           💻  TERMINAL & DEV
           ═══════════════════════════════════════════════════════ */
        {
          "type": "custom",
          "key": "{#36}💻  TERMINAL & DEV{##}",
          "keyColor": "bright_cyan"
        },
        {
          "type": "custom",
          "key": "  ◆ Terminal",
          "command": "echo 'Ghostty '${ver pkgs.ghostty}'",
          "keyColor": "bright_cyan"
        },
        {
          "type": "terminalfont",
          "key": "  ◆ Font    ",
          "keyColor": "bright_cyan"
        },
        {
          "type": "custom",
          "key": "  ◆ Prompt  ",
          "command": "echo 'starship '${ver pkgs.starship}'",
          "keyColor": "bright_cyan"
        },
        {
          "type": "custom",
          "key": "  ◆ Editor  ",
          "command": "echo 'micro '${ver pkgs.micro}'",
          "keyColor": "bright_cyan"
        },
        {
          "type": "custom",
          "key": "  ◆ Git     ",
          "command": "echo '${ver pkgs.git}'",
          "keyColor": "bright_cyan"
        },
        {
          "type": "custom",
          "key": "  ◆ GitHub  ",
          "command": "echo 'gh '${ver pkgs.gh}'",
          "keyColor": "bright_cyan"
        },
        {
          "type": "custom",
          "key": "  ◆ Git TUI ",
          "command": "echo 'lazygit '${ver pkgs.lazygit}'",
          "keyColor": "bright_cyan"
        },
        {
          "type": "custom",
          "key": "  ◆ Nix     ",
          "command": "nix --version 2>/dev/null | awk '{print $3}' || echo '—'",
          "keyColor": "bright_cyan"
        },
        "break",

        /* ═══════════════════════════════════════════════════════
           📦  CLI TOOLKIT
           ═══════════════════════════════════════════════════════ */
        {
          "type": "custom",
          "key": "{#35}📦  CLI TOOLKIT{##}",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ eza     ",
          "command": "echo '${ver pkgs.eza}'",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ bat     ",
          "command": "echo '${ver pkgs.bat}'",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ ripgrep ",
          "command": "echo '${ver pkgs.ripgrep}'",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ fd      ",
          "command": "echo '${ver pkgs.fd}'",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ fzf     ",
          "command": "echo '${ver pkgs.fzf}'",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ yazi    ",
          "command": "echo '${ver pkgs.yazi}'",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ btop    ",
          "command": "echo '${ver pkgs.btop}'",
          "keyColor": "bright_magenta"
        },
        {
          "type": "custom",
          "key": "  ◆ atuin   ",
          "command": "echo '${ver pkgs.atuin}'",
          "keyColor": "bright_magenta"
        },
        "break",

        /* ═══════════════════════════════════════════════════════
           🌐  APPS & MEDIA
           ═══════════════════════════════════════════════════════ */
        {
          "type": "custom",
          "key": "{#32}🌐  APPS & MEDIA{##}",
          "keyColor": "bright_green"
        },
        {
          "type": "custom",
          "key": "  ◆ Firefox ",
          "command": "echo '${ver pkgs.firefox}'",
          "keyColor": "bright_green"
        },
        {
          "type": "custom",
          "key": "  ◆ Brave   ",
          "command": "${fpInstalled "com.brave.Browser"}",
          "keyColor": "bright_green"
        },
        {
          "type": "custom",
          "key": "  ◆ Zed     ",
          "command": "zeditor --version 2>/dev/null | head -1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' || echo '—'",
          "keyColor": "bright_green"
        },
        {
          "type": "custom",
          "key": "  ◆ Obsidian",
          "command": "echo '${ver pkgs.obsidian}'",
          "keyColor": "bright_green"
        },
        {
          "type": "custom",
          "key": "  ◆ OpenCode",
          "command": "echo '${ver pkgs.opencode}'",
          "keyColor": "bright_green"
        },
        {
          "type": "custom",
          "key": "  ◆ ffmpeg  ",
          "command": "echo '${ver pkgs.ffmpeg}'",
          "keyColor": "bright_green"
        },
        "break",

        /* ═══════════════════════════════════════════════════════
           💬  COMMUNICATION
           ═══════════════════════════════════════════════════════ */
        {
          "type": "custom",
          "key": "{#33}💬  COMMUNICATION{##}",
          "keyColor": "bright_yellow"
        },
        {
          "type": "custom",
          "key": "  ◆ Signal  ",
          "command": "${fpInstalled "org.signal.Signal"}",
          "keyColor": "bright_yellow"
        },
        {
          "type": "custom",
          "key": "  ◆ Telegram",
          "command": "${fpInstalled "org.telegram.desktop"}",
          "keyColor": "bright_yellow"
        },
        {
          "type": "custom",
          "key": "  ◆ Discord ",
          "command": "${fpInstalled "dev.vencord.Vesktop"}",
          "keyColor": "bright_yellow"
        },
        {
          "type": "custom",
          "key": "  ◆ SimpleX ",
          "command": "${fpInstalled "chat.simplex.simplex"}",
          "keyColor": "bright_yellow"
        },
        "break",

        /* ═══════════════════════════════════════════════════════
           🔐  SECURITY
           ═══════════════════════════════════════════════════════ */
        {
          "type": "custom",
          "key": "{#31}🔐  SECURITY{##}",
          "keyColor": "bright_red"
        },
        {
          "type": "custom",
          "key": "  ◆ age     ",
          "command": "echo '${ver pkgs.age}'",
          "keyColor": "bright_red"
        },
        {
          "type": "custom",
          "key": "  ◆ sops    ",
          "command": "echo '${ver pkgs.sops}'",
          "keyColor": "bright_red"
        },
        {
          "type": "custom",
          "key": "  ◆ GPG     ",
          "command": "echo '${ver pkgs.gnupg}'",
          "keyColor": "bright_red"
        },
        {
          "type": "custom",
          "key": "  ◆ KeePass ",
          "command": "${fpInstalled "org.keepassxc.KeePassXC"}",
          "keyColor": "bright_red"
        }
      ]
    }
  '';
}
