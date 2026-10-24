_: {
  programs.fish.interactiveShellInit = ''
    # Space completed commands without adding a line on startup or screen redraw.
    function __starship_local_spacing --on-event fish_postexec
        set -l command_status $status
        set -l last_command (string trim -- "$argv[1]")

        # Let a standalone clear (including flags) leave the prompt at the top.
        if string match --quiet --regex '^(command[ \t]+)?clear([ \t]+[^;&|\n]*)?;?$' -- "$last_command"
            return $command_status
        end

        printf '\n'
        return $command_status
    end
  '';

  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = false;
      palette = "moonlit";
      format = "$username$hostname$directory($git_branch$git_commit$git_status$git_state[](fg:git_bg) )$nix_shell$container$fill$rust$nodejs$python$cmd_duration$jobs$sudo$status$time$line_break$character";
      palettes = {
        moonlit = {
          ink = "#191b26";
          text = "#dce1ef";
          muted = "#a0a8bd";
          surface = "#292d3e";
          lavender = "#c4b5fd";
          blue = "#b9d6fb";
          path_bg = "#25354d";
          mint = "#a7dfbc";
          git_bg = "#253c34";
          amber = "#f1cf91";
          red = "#f29aa5";
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
        style = "bold fg:blue bg:path_bg";
        format = "[](fg:path_bg)[󰉋 $path]($style)[$read_only](fg:red bg:path_bg)[](fg:path_bg) ";
        home_symbol = "~";
        read_only = " ";
        truncation_length = 3;
        truncation_symbol = "…/";
        truncate_to_repo = true;
        fish_style_pwd_dir_length = 1;
      };
      git_branch = {
        symbol = "";
        style = "fg:mint bg:git_bg";
        format = "[](fg:git_bg)[$symbol $branch]($style)";
        truncation_length = 22;
        truncation_symbol = "…";
      };
      git_commit = {
        only_detached = true;
        tag_disabled = true;
        style = "fg:mint bg:git_bg";
        format = "[ @$hash]($style)";
      };
      git_status = {
        style = "fg:mint bg:git_bg";
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
        style = "bold fg:amber bg:git_bg";
        format = "[ $state( $progress_current/$progress_total)]($style)";
      };
      nix_shell = {
        disabled = false;
        symbol = "";
        style = "fg:lavender bg:surface";
        format = "[](fg:surface)[$symbol dev]($style)[](fg:surface) ";
      };
      container = {
        symbol = "";
        style = "fg:blue bg:surface";
        format = "[](fg:surface)[$symbol $name]($style)[](fg:surface) ";
      };
      rust = {
        symbol = " ";
        style = "fg:amber";
        format = "[$symbol$version]($style) ";
      };
      nodejs = {
        symbol = " ";
        style = "fg:mint";
        format = "[$symbol$version]($style) ";
      };
      python = {
        symbol = " ";
        style = "fg:blue";
        format = "[\${symbol}\${version}( $virtualenv)]($style) ";
      };
      fill = {
        symbol = " ";
      };
      cmd_duration = {
        min_time = 2000;
        style = "fg:amber";
        format = "[󰔟 $duration]($style) ";
      };
      jobs = {
        symbol = "";
        number_threshold = 1;
        style = "fg:amber";
        format = "[$symbol $number]($style) ";
      };
      sudo = {
        disabled = false;
        symbol = "󰌾";
        style = "fg:amber";
        format = "[$symbol]($style) ";
      };
      status = {
        disabled = false;
        symbol = "×";
        style = "fg:red";
        format = "[$symbol $status]($style) ";
      };
      time = {
        disabled = false;
        time_format = "%I:%M%P";
        style = "fg:muted bg:surface";
        format = "[](fg:surface)[󰥔 $time]($style)[](fg:surface)";
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
