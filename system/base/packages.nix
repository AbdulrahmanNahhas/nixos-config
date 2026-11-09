{ pkgs, ... }:
{
  # Keep recovery and hardware diagnostics available outside the user profile.
  environment.systemPackages = with pkgs; [
    curl
    git
    usbutils
    pciutils
  ];
}
