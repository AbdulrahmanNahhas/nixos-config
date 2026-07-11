{ ... }:
{
  programs.fish.functions = {
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

    phone = ''
      switch $argv[1]
        case on
          gnome-extensions enable gsconnect@andyholmes.github.io
        case off
          gnome-extensions disable gsconnect@andyholmes.github.io && pkill -f gsconnect
        case info
          gnome-extensions info gsconnect@andyholmes.github.io
        case '*'
          echo "Usage: phone on|off|info"
      end
    '';

    devenv-new = ''
      devenv init
      echo "use devenv" > .envrc
      direnv allow
    '';

    wallpaper = ''
      set -l base_dir ~/Pictures/Wallpapers

      switch $argv[1]
        case set
          # Ensure the base directory exists
          if not test -d $base_dir
            echo "Directory $base_dir does not exist."
            return 1
          end

          # Save current directory and move into Wallpapers for a clean fzf list
          set -l old_pwd $PWD
          cd $base_dir

          # fd searches current dir, fzf shows clean names, chafa previews locally
          set -l target (command fd -t f -e jpg -e jpeg -e png -e webp | fzf \
            --height=80% \
            --layout=reverse \
            --border \
            --prompt="󰸉 Select Wallpaper > " \
            --preview 'chafa -f symbols --size={$FZF_PREVIEW_COLUMNS}x{$FZF_PREVIEW_LINES} {}')

          # Return to the original directory transparently
          cd $old_pwd

          # If a choice was made, construct the absolute path and apply
          if test -n "$target"
            set -l abs_path (realpath "$base_dir/$target")

            gsettings set org.gnome.desktop.background picture-uri "file://$abs_path"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$abs_path"

            echo "Wallpaper successfully set to: " (basename "$abs_path")
          else
            echo "Selection cancelled."
          end

        case random
          # Ensure the base directory exists
          if not test -d $base_dir
            echo "Directory $base_dir does not exist."
            return 1
          end

          # Use -a to force absolute paths for the random background selection
          set -l target (command fd -a -t f -e jpg -e jpeg -e png -e webp . $base_dir | shuf -n 1)

          # If an image was found, apply it
          if test -n "$target"
            set -l abs_path (realpath "$target")

            gsettings set org.gnome.desktop.background picture-uri "file://$abs_path"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$abs_path"

            echo "🎲 Randomly selected: " (basename "$abs_path")
          else
            echo "No wallpapers found in $base_dir"
          end

        case info
          # Fetch URIs from GNOME and trim surrounding single quotes
          set -l raw_light (gsettings get org.gnome.desktop.background picture-uri | string trim -c "'")
          set -l raw_dark (gsettings get org.gnome.desktop.background picture-uri-dark | string trim -c "'")

          # Clean the paths by stripping the "file://" prefix
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
