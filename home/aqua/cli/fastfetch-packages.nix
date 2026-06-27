# Fastfetch – Software Version Tracker
# Usage: fastfetch -c packages
{
  ...
}:

let
  # Section header module
  section = { color, label }: {
    type = "custom";
    key = label;
    keyColor = color;
    format = "{1}";
  };

  # Build an array of modules
  modules = [
    # ═══ FOUNDATION ═══
    (section { color = "bright_blue"; label = "❄️  FOUNDATION"; })
    { type = "os";       key = "  ◆ OS     "; keyColor = "bright_blue"; }
    { type = "kernel";   key = "  ◆ Kernel "; keyColor = "bright_blue"; }
    { type = "de";       key = "  ◆ Desktop"; keyColor = "bright_blue"; }
    { type = "wm";       key = "  ◆ WM     "; keyColor = "bright_blue"; }
    { type = "custom";   key = "  ◆ Shell  "; keyColor = "bright_blue";
      command = "fish --version 2>/dev/null | awk '{print $NF}' || echo '—'"; }
    "break"

    # ═══ TERMINAL & DEV ═══
    (section { color = "bright_cyan"; label = "💻  TERMINAL & DEV"; })
    { type = "custom";   key = "  ◆ Terminal"; keyColor = "bright_cyan";
      command = "ghostty --version 2>/dev/null | head -1 | awk '{print $2}' || echo '—'"; }
    { type = "terminalfont"; key = "  ◆ Font    "; keyColor = "bright_cyan"; }
    { type = "custom";   key = "  ◆ Prompt  "; keyColor = "bright_cyan";
      command = "starship --version 2>/dev/null | awk '{print $2}' || echo '—'"; }
    { type = "custom";   key = "  ◆ Editor  "; keyColor = "bright_cyan";
      command = "micro --version 2>/dev/null | head -1 | awk '{print $2}' || echo '—'"; }
    { type = "custom";   key = "  ◆ Git     "; keyColor = "bright_cyan";
      command = "git --version 2>/dev/null | awk '{print $3}' || echo '—'"; }
    { type = "custom";   key = "  ◆ GitHub  "; keyColor = "bright_cyan";
      command = "gh --version 2>/dev/null | head -1 | awk '{print $3}' || echo '—'"; }
    { type = "custom";   key = "  ◆ Git TUI "; keyColor = "bright_cyan";
      command = "lazygit --version 2>/dev/null | head -1 | grep -o 'version=[0-9.]*' | cut -d= -f2 || echo '—'"; }
    { type = "custom";   key = "  ◆ Nix     "; keyColor = "bright_cyan";
      command = "nix --version 2>/dev/null | awk '{print $3}' || echo '—'"; }
    "break"

    # ═══ CLI TOOLKIT ═══
    (section { color = "bright_magenta"; label = "📦  CLI TOOLKIT"; })
    { type = "custom";   key = "  ◆ eza     "; keyColor = "bright_magenta";
      command = "eza --version 2>/dev/null | head -1 | grep -oE '[0-9]+[.][0-9]+([.][0-9]+)?' || echo '—'"; }
    { type = "custom";   key = "  ◆ bat     "; keyColor = "bright_magenta";
      command = "bat --version 2>/dev/null | head -1 | awk '{print $2}' || echo '—'"; }
    { type = "custom";   key = "  ◆ ripgrep "; keyColor = "bright_magenta";
      command = "rg --version 2>/dev/null | head -1 | awk '{print $2}' || echo '—'"; }
    { type = "custom";   key = "  ◆ fd      "; keyColor = "bright_magenta";
      command = "fd --version 2>/dev/null | awk '{print $2}' || echo '—'"; }
    { type = "custom";   key = "  ◆ fzf     "; keyColor = "bright_magenta";
      command = "fzf --version 2>/dev/null | awk '{print $1}' || echo '—'"; }
    { type = "custom";   key = "  ◆ yazi    "; keyColor = "bright_magenta";
      command = "yazi --version 2>/dev/null | head -1 | awk '{print $2}' || echo '—'"; }
    { type = "custom";   key = "  ◆ btop    "; keyColor = "bright_magenta";
      command = "btop --version 2>/dev/null | head -1 | awk '{print $2}' || echo '—'"; }
    { type = "custom";   key = "  ◆ atuin   "; keyColor = "bright_magenta";
      command = "atuin --version 2>/dev/null | head -1 | awk '{print $2}' || echo '—'"; }
    "break"

    # ═══ APPS & MEDIA ═══
    (section { color = "bright_green"; label = "🌐  APPS & MEDIA"; })
    { type = "custom";   key = "  ◆ Firefox "; keyColor = "bright_green";
      command = "firefox --version 2>/dev/null | awk '{print $3}' || echo '—'"; }
    { type = "custom";   key = "  ◆ Brave   "; keyColor = "bright_green";
      command = "flatpak info com.brave.Browser >/dev/null 2>/dev/null && echo flatpak || echo —"; }
    { type = "custom";   key = "  ◆ Zed     "; keyColor = "bright_green";
      command = "zeditor --version 2>/dev/null | head -1 | grep -oE '[0-9]+[.][0-9]+[.][0-9]+' || echo '—'"; }
    { type = "custom";   key = "  ◆ Obsidian"; keyColor = "bright_green";
      command = "obsidian --version 2>/dev/null | head -1 | awk '{print $NF}' || echo '—'"; }
    { type = "custom";   key = "  ◆ OpenCode"; keyColor = "bright_green";
      command = "opencode --version 2>/dev/null | head -1 | awk '{print $NF}' || echo '—'"; }
    { type = "custom";   key = "  ◆ ffmpeg  "; keyColor = "bright_green";
      command = "ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}' || echo '—'"; }
    "break"

    # ═══ COMMUNICATION ═══
    (section { color = "bright_yellow"; label = "💬  COMMUNICATION"; })
    { type = "custom";   key = "  ◆ Signal  "; keyColor = "bright_yellow";
      command = "flatpak info org.signal.Signal >/dev/null 2>/dev/null && echo flatpak || echo —"; }
    { type = "custom";   key = "  ◆ Telegram"; keyColor = "bright_yellow";
      command = "flatpak info org.telegram.desktop >/dev/null 2>/dev/null && echo flatpak || echo —"; }
    { type = "custom";   key = "  ◆ Discord "; keyColor = "bright_yellow";
      command = "flatpak info dev.vencord.Vesktop >/dev/null 2>/dev/null && echo flatpak || echo —"; }
    { type = "custom";   key = "  ◆ SimpleX "; keyColor = "bright_yellow";
      command = "flatpak info chat.simplex.simplex >/dev/null 2>/dev/null && echo flatpak || echo —"; }
    "break"

    # ═══ SECURITY ═══
    (section { color = "bright_red"; label = "🔐  SECURITY"; })
    { type = "custom";   key = "  ◆ age     "; keyColor = "bright_red";
      command = "age --version 2>/dev/null | head -1 | awk '{print $NF}' || echo '—'"; }
    { type = "custom";   key = "  ◆ sops    "; keyColor = "bright_red";
      command = "sops --version 2>/dev/null | head -1 | awk '{print $NF}' || echo '—'"; }
    { type = "custom";   key = "  ◆ GPG     "; keyColor = "bright_red";
      command = "gpg --version 2>/dev/null | head -1 | awk '{print $NF}' || echo '—'"; }
    { type = "custom";   key = "  ◆ KeePass "; keyColor = "bright_red";
      command = "flatpak info org.keepassxc.KeePassXC >/dev/null 2>/dev/null && echo flatpak || echo —"; }
  ];
in
{
  # ── ASCII logo ──────────────────────────────────────────────────
  xdg.configFile."fastfetch/fastfetch-packages.txt".source = ./fastfetch-packages.txt;

  # ── JSON config (loaded via `fastfetch -c packages`) ────────────
  xdg.configFile."fastfetch/packages.jsonc".text =
    builtins.toJSON {
      logo = {
        source = "~/.config/fastfetch/fastfetch-packages.txt";
        type = "file";
        padding = { top = 0; left = 2; };
        color = {
          "1" = "bright_blue";
          "2" = "bright_magenta";
          "3" = "bright_cyan";
          "4" = "bright_green";
        };
      };
      display = {
        separator = " · ";
        color = "white";
      };
      modules = modules;
    };
}
