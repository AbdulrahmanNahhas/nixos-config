{
  programs.devenv = {
    enable = true;
    enableFishIntegration = true;
  };

  # Zed loads direnv directly; native devenv owns terminal activation.
  programs.direnv = {
    enable = true;
    enableFishIntegration = false;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableNushellIntegration = false;
    nix-direnv.enable = false;
  };
}
