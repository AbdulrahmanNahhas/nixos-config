# GNOME desktop + fonts + environment
{ pkgs, ... }:

{
  # ── X11 / Display Manager / GNOME ────────────────────────
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ]; # remove legacy terminal

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-software.enable = false; # replaced by flatpak
  programs.seahorse.enable = true;

  # ── Remove unwanted GNOME apps ───────────────────────────
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    gnome-console # kgx — replaced by ghostty
    gnome-characters
    yelp # gnome help
    epiphany # gnome web
    geary # gnome mail
  ];

  # ── GNOME desktop packages ───────────────────────────────
  environment.systemPackages = with pkgs; [
    gnome-tweaks # no flatpak available; pulls Extensions app as dep
  ];

  # ── Firefox (profile & theme managed by home-manager) ──

  # ── Wayland env vars ─────────────────────────────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # ── Fonts ────────────────────────────────────────────────
  fonts.packages = with pkgs.nerd-fonts; [
    geist-mono # ghostty terminal & zed integrated terminal
  ];
}
