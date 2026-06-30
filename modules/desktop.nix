# GNOME desktop + fonts + environment
{ pkgs, ... }:
{
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

  environment.systemPackages = with pkgs; [ gnome-tweaks ];

  # ── Wayland / GPU session variables ──────────────────────
  # LIBVA: video decode goes to AMD iGPU by default
  # GLX vendor: pin Mesa (AMD) so libglvnd never silently hands
  # GLX off to NVIDIA. `nvidia-offload <cmd>` and the Jovian Steam
  # session override these per-process / per-session as needed.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "radeonsi";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
  };

  fonts.packages = with pkgs.nerd-fonts; [ geist-mono ];
}