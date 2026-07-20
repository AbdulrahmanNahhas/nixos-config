_: {
  programs.keepassxc = {
    enable = true;
    settings = {
      Browser = {
        Enabled = true;
        UpdateBinaryPath = false;
      };
      GUI = {
        AdvancedSettings = true;
        ApplicationTheme = "dark";
        HidePasswords = true;
      };
    };
  };
}
