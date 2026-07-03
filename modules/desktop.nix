# desktop.nix
{ pkgs, ... }:
{
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
