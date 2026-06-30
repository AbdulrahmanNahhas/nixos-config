{ pkgs, ... }:
{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    # ─── Network / Downloads ─── #
    wget
    curl

    # ─── Version Control ─── #
    git

    # ─── System Utilities ─── #
    brightnessctl
    usbutils # lsusb
    pciutils # lspci
  ];
}
