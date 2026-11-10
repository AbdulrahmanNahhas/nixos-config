_: {
  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = false;
      palette = "moonlit";
      format = "$username$hostname$directory($git_branch$git_status$git_state[](fg:git_bg) )$cmd_duration$status$line_break$character";
      # Keep both lines left-aligned; avoid width-dependent fill and right prompts.
      right_format = "";
      palettes = {
        moonlit = {
          # Terminal / Ghostty ANSI colors

          ink = "black";
          text = "white";
          muted = "bright-black";

          # Surfaces / Backgrounds
          surface = "black";
          path_bg = "blue";
          git_bg = "green";

          # Accents
          lavender = "bright-purple";
          blue = "bright-blue";
          mint = "bright-green";
          amber = "bright-yellow";
          red = "bright-red";

        };
      };
      username = {
        show_always = true;
        style_user = "bold fg:ink bg:lavender";
        style_root = "bold fg:ink bg:red";
        format = "[](fg:lavender)[ $user]($style)[](fg:lavender) ";
      };
      hostname = {
        ssh_only = true;
        ssh_symbol = "󰣀 ";
        style = "fg:amber bg:surface";
        format = "[](fg:surface)[$ssh_symbol$hostname]($style)[](fg:surface) ";
      };
      directory = {
        style = "bold fg:ink bg:path_bg";
        format = "[](fg:path_bg)[󰉋 $path]($style)[$read_only](fg:red bg:path_bg)[](fg:path_bg) ";
        home_symbol = "~";
        read_only = " ";
        truncation_length = 2;
        truncation_symbol = "…/";
        truncate_to_repo = true;
        fish_style_pwd_dir_length = 0;
      };
      git_branch = {
        symbol = "";
        style = "fg:ink bg:git_bg";
        format = "[](fg:git_bg)[$symbol $branch]($style)";
        truncation_length = 16;
        truncation_symbol = "…";
      };
      git_status = {
        style = "fg:ink bg:git_bg";
        format = "([ $all_status$ahead_behind]($style))";
        conflicted = "=$count ";
        stashed = "*$count ";
        staged = "+$count ";
        modified = "~$count ";
        renamed = "»$count ";
        deleted = "-$count ";
        untracked = "?$count ";
        ahead = "↑$count ";
        behind = "↓$count ";
        diverged = "↑$ahead_count ↓$behind_count ";
      };
      git_state = {
        style = "bold fg:ink bg:git_bg";
        format = "[ $state( $progress_current/$progress_total)]($style)";
      };
      cmd_duration = {
        min_time = 2000;
        style = "fg:amber";
        format = "[󰔟 $duration]($style) ";
      };
      status = {
        disabled = false;
        symbol = "×";
        style = "fg:red";
        format = "[$symbol $status]($style) ";
      };
      character = {
        success_symbol = "[❯](bold fg:lavender)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:mint)";
        vimcmd_replace_one_symbol = "[❮](bold fg:amber)";
        vimcmd_replace_symbol = "[❮](bold fg:amber)";
        vimcmd_visual_symbol = "[❮](bold fg:blue)";
      };
      package = {
        disabled = true;
      };
    };
  };
}
