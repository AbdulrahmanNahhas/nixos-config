{
  # Keep fwupd for firmware updates; disable unused peripheral stacks.
  hardware.sane.enable = false;
  networking.modemmanager.enable = false;
  services = {
    fwupd.enable = true;
    gnome.gnome-online-accounts.enable = false;
    usbmuxd.enable = false;
  };
}
