_: {
  programs.fish.functions = {
    sys-check = "nix flake check /saved/nixos-config $argv";
    sys-build = "nh os build $argv";
    sys-switch = "nh os switch $argv";
    sys-test = "nh os test $argv";
    sys-clean = "nh clean all --keep 3 --keep-since 7d --no-gcroots $argv";
    sys-optimise = "sudo nix store optimise";
    sys-update = "nix flake update --flake /saved/nixos-config $argv";

    sys-search = ''
      set -l initial_query (string join ' ' -- $argv)

      set -l reload "nh search packages --limit 50 {q} 2>/dev/null | awk 'BEGIN { RS=\"\"; ORS=\"\0\" } /^\033\[34m/ { print }'"

      set -l selected (
        fzf \
          --read0 \
          --ansi \
          --tac \
          --no-multi \
          --height=100% \
          --layout=reverse \
          --border \
          --highlight-line \
          --query="$initial_query" \
          --disabled \
          --header="Nixpkgs packages • Enter select • Esc cancel" \
          --bind "start:reload($reload)" \
          --bind "change:reload($reload)"
      )

      test -n "$selected"; or return 0

      # Split fzf records, strip ANSI and extract fields.
      set -l lines (string replace -ra '\e\[[0-9;]*m' "" -- $selected)
      set -l package (string replace -r '\s+\(.*$' "" -- $lines[1])
      set -l version (string replace -r '^.*\((.*)\)$' '$1' -- $lines[1])
      set -l homepage (string replace -rf '^\s*Homepage:\s*' "" -- $lines)
      set -l github (string replace -rf '^\s*GitHub link:\s*' "" -- $lines)
      set -l description (string trim -- (string match -rv '^\s*(Main program|Homepage|Defined at|GitHub link):' -- $lines[2..]))

      test -n "$package"; or return 0

      echo
      set_color -o cyan; printf '  %s' $package
      set_color brblack; printf '  %s\n' $version; set_color normal
      test -n "$description"; and printf '  %s\n' $description
      echo
      printf '  '
      test -n "$homepage"; and _link $homepage Homepage; and printf '  ·  '
      test -n "$github"; and _link $github "GitHub (nixpkgs source)"
      echo
      echo
      set_color brblack; echo '  [enter/w] website  [g] github  [c] copy name  [q] quit'; set_color normal

      read -n 1 -l -P '  › ' key
      switch $key
        case "" w
          test -n "$homepage"; and xdg-open $homepage >/dev/null 2>&1 &
        case g
          test -n "$github"; and xdg-open $github >/dev/null 2>&1 &
        case c
          printf '%s' $package | wl-copy; and echo "  Copied $package"
      end
      disown >/dev/null 2>&1
    '';

    # OSC 8 terminal hyperlink: _link <url> <label>
    _link = "printf '\\e]8;;%s\\a%s\\e]8;;\\a' $argv[1] $argv[2]";

    mkcd = ''
      if test (count $argv) -gt 0
        mkdir -p -- $argv[1]
        and cd -- $argv[1]
      else
        echo "Usage: mkcd <directory>"
      end
    '';

    book_library = ''
      switch $argv[1]
        case on
          sudo systemctl start kavita --no-pager
        case off
          sudo systemctl stop kavita --no-pager
        case status
          sudo systemctl status kavita.service --no-pager
        case '*'
          echo "Usage: book_library on|off|status"
      end
    '';

    wallpaper = ''
      set -l base_dir ~/Pictures/Wallpapers

      switch $argv[1]
        case set
          if not test -d $base_dir
            echo "Directory $base_dir does not exist."
            return 1
          end

          # Select wallpapers relative to their directory.
          set -l old_pwd $PWD
          cd $base_dir

          set -l target (command fd -t f -e jpg -e jpeg -e png -e webp | fzf \
            --height=80% \
            --layout=reverse \
            --border \
            --prompt="󰸉 Select Wallpaper > " \
            --preview 'chafa -f symbols --size={$FZF_PREVIEW_COLUMNS}x{$FZF_PREVIEW_LINES} {}')

          cd $old_pwd

          if test -n "$target"
            set -l abs_path (realpath "$base_dir/$target")

            gsettings set org.gnome.desktop.background picture-uri "file://$abs_path"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$abs_path"

            echo "Wallpaper successfully set to: " (basename "$abs_path")
          else
            echo "Selection cancelled."
          end

        case random
          if not test -d $base_dir
            echo "Directory $base_dir does not exist."
            return 1
          end

          # Use absolute paths for random selection.
          set -l target (command fd -a -t f -e jpg -e jpeg -e png -e webp . $base_dir | shuf -n 1)

          if test -n "$target"
            set -l abs_path (realpath "$target")

            gsettings set org.gnome.desktop.background picture-uri "file://$abs_path"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$abs_path"

            echo "🎲 Randomly selected: " (basename "$abs_path")
          else
            echo "No wallpapers found in $base_dir"
          end

        case info
          # Strip gsettings quoting from wallpaper URIs.
          set -l raw_light (gsettings get org.gnome.desktop.background picture-uri | string trim -c "'")
          set -l raw_dark (gsettings get org.gnome.desktop.background picture-uri-dark | string trim -c "'")

          set -l path_light (string replace "file://" "" $raw_light)
          set -l path_dark (string replace "file://" "" $raw_dark)

          echo "🖼️  Current Wallpaper Setup:"
          if test -n "$path_light"
            echo "  Light Mode: " (basename $path_light) " -> ($path_light)"
          else
            echo "  Light Mode: Default / Not Set"
          end

          if test -n "$path_dark"
            echo "  Dark Mode:  " (basename $path_dark) " -> ($path_dark)"
          else
            echo "  Dark Mode:  Default / Not Set"
          end

        case '*'
          echo "Usage: wallpaper set|random|info"
      end
    '';
  };
}
