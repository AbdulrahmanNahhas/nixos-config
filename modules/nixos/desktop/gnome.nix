{ pkgs, ... }:
{
  # Niri is the only desktop session. Keep just the GTK applications and
  # services needed by the workflow, rather than installing GNOME Shell.
  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
  };
  programs.dconf.enable = true;

  # These remain native, trusted applications and use the normal Unix user
  # boundary. Flatpak is used where per-application filesystem mediation is
  # required.
  environment.systemPackages = with pkgs; [
    nautilus
    gnome-text-editor
    gnome-clocks
    gnome-calendar
    gnome-disk-utility
  ];
}
