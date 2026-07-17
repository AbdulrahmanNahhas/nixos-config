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

      # Check if flake.lock is older than 7 days
      set -l lockfile "/saved/nixos-config/flake.lock"
      if test -f $lockfile
          set -l now (date +%s)
          set -l last_mod (stat -c %Y $lockfile)
          set -l age (math "$now - $last_mod")

          # 604800 seconds = 7 days
          if test $age -gt 604800
              set_color yellow --bold
              echo "󰚰  NixOS Flake hasn't been updated in over 7 days."
              set_color cyan
              echo "   Run: nh os switch -u /saved/nixos-config"
              set_color normal
              echo "" # Adds an empty line for clean spacing
          end
      end
    '';
  };
}
