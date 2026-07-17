# desktop.nix
{ pkgs, ... }:
{
  # ── Niri ─────────────────────────────────────────────────
  programs.niri.enable = true;
  services.greetd.enable = true;
  services.displayManager.defaultSession = "niri";

  # ── Display Manager ──────────────────────────────────────
  programs.regreet = {
    enable = true;

    # Cursor
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };

    # Font
    font = {
      name = "Inter";
      size = 13;
      package = pkgs.inter;
    };

    # GTK Base Theme
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # Background Video & Settings
    settings = {
      # background = {
      #   path = "${../assets/background.mp4}";
      #   fit = "Cover";
      # };
      GTK = {
        application_prefer_dark_theme = true;
      };
    };

    # GTK4 CSS styling matching the QML colors & tactical glass aesthetic
    extraCss = ''
      window {
        background-color: transparent;
      }

      .card, box.main-box {
        background-color: rgba(10, 10, 9, 0.55);
        border: 1px solid rgba(247, 197, 148, 0.15);
        border-radius: 8px;
        padding: 30px;
        box-shadow: 0 12px 32px rgba(0, 0, 0, 0.6);
      }

      label {
        color: #fffdf5;
        font-weight: 700;
        letter-spacing: 1.5px;
      }

      .dim-label, label.subtitle {
        color: #a89e8d;
        font-weight: 600;
        letter-spacing: 2px;
      }

      entry {
        background-color: rgba(255, 255, 255, 0.035);
        color: #fffdf5;
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 4px;
        padding: 10px 14px;
        font-weight: 600;
        letter-spacing: 4px;
        transition: all 0.25s ease;
      }

      entry:focus {
        border-color: rgba(247, 197, 148, 0.5);
        box-shadow: 0 0 12px rgba(247, 197, 148, 0.25);
        background-color: rgba(255, 255, 255, 0.06);
      }

      button {
        background-color: rgba(255, 255, 255, 0.03);
        color: #a89e8d;
        border: 1px solid rgba(255, 255, 255, 0.05);
        border-radius: 4px;
        font-weight: 700;
        letter-spacing: 2px;
        padding: 8px 16px;
        transition: all 0.2s ease;
      }

      button:hover {
        color: #f7c594;
        background-color: rgba(247, 197, 148, 0.08);
        border-color: rgba(247, 197, 148, 0.3);
      }

      menu, popover {
        background-color: rgba(10, 10, 9, 0.85);
        border: 1px solid rgba(247, 197, 148, 0.2);
        border-radius: 6px;
        color: #fffdf5;
      }

      .error {
        color: #f06060;
        font-weight: bold;
        letter-spacing: 2px;
      }
    '';
  };

  # ── Remove Unwanted GNOME Bloat ──────────────────────────
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    gnome-console # Replaced by Ghostty
    gnome-characters
    yelp # GNOME Help
    epiphany # GNOME Web Browser
    geary # GNOME Mail Client
  ];

  # ── System Packages & Tools ──────────────────────────────
  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  # Modern GNOME credential manager integration
  programs.seahorse.enable = true;

  # ── Modern Wayland Environment Variables ─────────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Forces Chromium/Electron apps to run natively on Wayland
    MOZ_ENABLE_WAYLAND = "1"; # Forces Firefox to run natively on Wayland
  };

  # ── Typography ───────────────────────────────────────────
  fonts.packages = with pkgs.nerd-fonts; [
    geist-mono
  ];
}
