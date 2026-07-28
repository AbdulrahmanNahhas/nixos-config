{
  # Keep unused peripheral stacks disabled, but retain fwupd so UEFI and device
  # security updates remain available through LVFS.
  hardware.sane.enable = false;
  networking.modemmanager.enable = false;
  services = {
    fwupd.enable = true;
    gnome.gnome-online-accounts.enable = false;
    usbmuxd.enable = false;
  };
}
