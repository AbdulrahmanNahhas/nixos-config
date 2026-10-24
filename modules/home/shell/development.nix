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

  # Shadow Fish’s vendor hook with conf.d; devenv owns terminal activation.
  xdg.configFile."fish/conf.d/direnv.fish".text = ''
    # Native devenv owns terminal activation; Zed invokes direnv directly.
  '';
}
