{
  config,
  lib,
  ...
}:
{
  programs = {
    nushell = {
      enable = true;
      loadSessionVariables = true;
      settings = {
        show_banner = false;
        edit_mode = "emacs";
        completions = {
          algorithm = "fuzzy";
          case_sensitive = false;
          sort = "smart";
        };
        history = {
          file_format = "sqlite";
          isolation = true;
        };
      };
      extraConfig = lib.mkAfter ''
        # Starship aligns the header itself; a second right prompt would duplicate it.
        $env.PROMPT_COMMAND_RIGHT = ""
        $env.TRANSIENT_PROMPT_COMMAND_RIGHT = ""
        $env.config.history.path = ($env.HOME | path join '.local/state/noctalia/nushell-history.sqlite3')
        use ${../desktop/menu}/completions.nu *
      '';
    };
    starship.enableNushellIntegration = true;
    # Match the declarative login shell in Ghostty.
    ghostty.settings = {
      command = lib.getExe config.programs.nushell.package;
      shell-integration = lib.mkForce "detect";
    };
  };
}
