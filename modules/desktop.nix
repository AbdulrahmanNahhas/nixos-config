# GNOME desktop + fonts + environment
{ pkgs, ... }:
{
  # security.pam.services.gdm-password.enableGnomeKeyring = true;

  # ── Remove unwanted GNOME apps ───────────────────────────
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    gnome-console       # replaced by ghostty
    gnome-characters
    yelp                # gnome help
    epiphany            # gnome web
    geary               # gnome mail
  ];

  programs.seahorse.enable = true;

  # ── GNOME desktop packages ───────────────────────────────
  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  # ── Wayland env vars ─────────────────────────────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # ── Fonts ────────────────────────────────────────────────
  fonts.packages = with pkgs.nerd-fonts; [
    geist-mono
  ];
}
