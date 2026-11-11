{ inputs, ... }:
{
  imports = [ inputs.nix-index-database.homeModules.default ];

  programs.nix-index-database.comma.enable = true;

  programs = {
    atuin = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        auto_sync = false;
        update_check = false;
        secrets_filter = true;
      };
    };
    fzf = {
      enable = true;
      # Keep Tab native to Nu and Ctrl+R owned by Atuin.
      enableNushellIntegration = false;
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
