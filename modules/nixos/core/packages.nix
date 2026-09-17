{ pkgs, ... }:
{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    # ─── Network / Downloads ─── #
    curl

    # ─── Version Control ─── #
    git

    # ─── System Utilities ─── #
    usbutils # lsusb
    pciutils # lspci

    # Tools
    wl-clipboard
    gpu-screen-recorder
  ];
}
