{
  imports = [
    ./abbrs.nix
    ./aliases.nix
    ./functions.nix
    ./starship.nix
  ];

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Remove fish startup greeting
      set fish_greeting ""

      # Fastfetch — ONLY trigger when running inside Ghostty
      # if test "$TERM_PROGRAM" = "ghostty"
      #     fastfetch
      # end

      # Initialize starship prompt
      starship init fish | source

      # Initialize zoxide
      zoxide init fish | source

      # Initialize atuin (shell history)
      atuin init fish | source
    '';
  };
}
