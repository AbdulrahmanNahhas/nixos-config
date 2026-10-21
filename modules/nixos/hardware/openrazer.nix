{ pkgs, username, ... }:
{
  # TEMPORARY FIX: https://github.com/NixOS/nixpkgs/issues/575192#issuecomment-6300503908
  hardware.openrazer = {
    enable = false;
    users = [ username ];
  };

  environment.systemPackages = with pkgs; [ polychromatic ];
}
