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
          echo "Usage: phone on|off|status"
      end
    '';

    wallpapers = ''
      set -l dir $argv[1]
      if test -z "$dir"
        set dir ~/Pictures/Wallpapers
      end
      yazi $dir
    '';

    wallpaper-next = ''
      set -l dir ~/Pictures/Wallpapers
      set -l files (find $dir -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort)
      set -l count (count $files)
      if test $count -eq 0
        echo "No wallpapers found in $dir"
        return 1
      end
      set -l idx_file ~/.cache/wall_index
      set -l current 0
      if test -f $idx_file
        set current (cat $idx_file)
      end
      set current (math "($current + 1) % $count")
      setwallpaper $files[(math $current + 1)]
      echo $current > $idx_file
      echo "Set: "(basename $files[(math $current + 1)])
    '';

    wallpaper-prev = ''
      set -l dir ~/Pictures/Wallpapers
      set -l files (find $dir -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort)
      set -l count (count $files)
      if test $count -eq 0
        echo "No wallpapers found in $dir"
        return 1
      end
      set -l idx_file ~/.cache/wall_index
      set -l current 0
      if test -f $idx_file
        set current (cat $idx_file)
      end
      set current (math "($current - 1 + $count) % $count")
      setwallpaper $files[(math $current + 1)]
      echo $current > $idx_file
      echo "Set: "(basename $files[(math $current + 1)])
    '';
  };
}
