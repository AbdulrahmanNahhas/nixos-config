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

  # Fish loads direnv's packaged vendor hook even with HM integration disabled.
  # A user conf.d file with the same name shadows that vendor startup file.
  xdg.configFile."fish/conf.d/direnv.fish".text = ''
    # Native devenv owns terminal activation; Zed invokes direnv directly.
  '';
}
