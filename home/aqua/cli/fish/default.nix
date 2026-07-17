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


      # Warn once per day when flake.lock is older than seven days.
      set -l flake_dir /saved/nixos-config
      if set -q NH_FLAKE
          set flake_dir $NH_FLAKE
      end

      set -l lockfile "$flake_dir/flake.lock"

      set -l cache_home "$HOME/.cache"
      if set -q XDG_CACHE_HOME
          set cache_home $XDG_CACHE_HOME
      end

      set -l warning_dir "$cache_home/nh"
      set -l warning_stamp "$warning_dir/flake-update-warning"

      if test -f $lockfile
          set -l now (date +%s)
          set -l lock_modified (stat -c %Y $lockfile)
          set -l lock_age (math "$now - $lock_modified")

          set -l last_warning 0
          if test -f $warning_stamp
              set last_warning (stat -c %Y $warning_stamp)
          end

          set -l warning_age (math "$now - $last_warning")

          # Seven days old, and no warning displayed during the last day.
          if test $lock_age -gt 604800; and test $warning_age -gt 86400
              set_color yellow --bold
              echo "󰚰  NixOS flake inputs haven't been updated in over 7 days."
              set_color cyan
              echo "   Run: nh os switch --update"
              set_color normal
              echo

              mkdir -p $warning_dir
              touch $warning_stamp
          end
      end
    '';
  };
}
