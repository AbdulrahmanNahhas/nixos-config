{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      palette = "vercel";

      format = "$username$sudo$nix_shell$directory$git_branch$git_status$container$fill$rust$nodejs$python$jobs$status$cmd_duration$time$line_break$character";

      palettes.vercel = {
        bg = "#0f0f10";
        fg = "#ededed";
        muted = "#7d7d7d";
        soft = "#1a1a1c";
        surface = "#161618";
        border = "#2a2a2d";
        green = "#4ade80";
        yellow = "#facc15";
        red = "#fb7185";
        blue = "#60a5fa";
      };

      # Every module below follows the same pattern:
      #   format = "[ $symbol content ]($style) ";
      # i.e. a flat square block with one space of internal padding
      # on each side, and exactly one space of gap after it.
      # No powerline arrow glyphs — flat blocks read as "square",
      # and avoids the glyph-loss problem that caused the empty
      # `[]()` segments (and the resulting stray spacing) before.

      username = {
        disabled = false;
        show_always = true;
        format = "[ 󰧱 $user ]($style) ";
        style_user = "bg:surface fg:fg";
        style_root = "bg:surface fg:red";
      };

      sudo = {
        disabled = false;
        symbol = "󰌾";
        style = "bg:surface fg:red";
        format = "[ $symbol ]($style) ";
      };

      nix_shell = {
        disabled = false;
        symbol = "";
        style = "bg:surface fg:blue";
        format = "[ $symbol $name ]($style) ";
      };

      directory = {
        format = "[ $path ]($style) ";
        style = "bg:surface fg:fg";
        truncation_length = 2;
        truncation_symbol = "…/";
        truncate_to_repo = true;
        read_only = " ";
        home_symbol = "~";
      };

      directory.substitutions = {
        Documents = "󰈙";
        Downloads = " ";
        Music = " ";
        Pictures = " ";
        Programming = "󰲋";
        Projects = "󰲋";
      };

      fill = {
        style = "fg:border";
        symbol = " ";
      };

      character = {
        disabled = false;
        success_symbol = "[❯](fg:green)";
        error_symbol = "[❯](fg:red)";
        vimcmd_symbol = "[❮](fg:blue)";
      };

      git_branch = {
        format = "[ $symbol $branch ]($style) ";
        style = "bg:surface fg:fg";
        symbol = "";
      };

      # Wrapped entirely in ( ) so a clean repo renders nothing at
      # all — not even a stray gap — instead of an empty pill.
      git_status = {
        disabled = false;
        format = "([ $staged$modified$deleted$untracked ]($style) )";
        style = "bg:surface fg:yellow";

        staged = "[+$count ](bg:surface fg:green)";
        modified = "[~$count ](bg:surface fg:yellow)";
        deleted = "[-$count ](bg:surface fg:red)";
        untracked = "[?$count ](bg:surface fg:blue)";
      };

      container = {
        format = "[ $symbol $name ]($style) ";
        symbol = "⬢";
        style = "bg:surface fg:blue";
      };

      rust = {
        style = "bg:surface fg:fg";
        format = "[ $symbol$version ]($style) ";
        symbol = " ";
        disabled = false;
      };

      nodejs = {
        style = "bg:surface fg:fg";
        format = "[ $symbol$version ]($style) ";
        symbol = "󰎙 ";
        disabled = false;
      };

      python = {
        style = "bg:surface fg:fg";
        format = "[ $symbol$version ]($style) ";
        symbol = " ";
        disabled = false;
      };

      jobs = {
        symbol = "";
        style = "bg:surface fg:yellow";
        format = "[ $symbol $number ]($style) ";
        disabled = false;
      };

      status = {
        disabled = false;
        format = "[ ✘ $status ]($style) ";
        style = "bg:surface fg:red";
      };

      cmd_duration = {
        min_time = 1000;
        format = "[ took $duration ]($style) ";
        style = "bg:surface fg:muted";
      };

      time = {
        disabled = false;
        format = "[ 󰴈 $time ]($style) ";
        style = "bg:surface fg:muted";
        time_format = "%I:%M%P";
      };

      # Languages / package managers not in use — trimmed to one line.
      c.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      golang.disabled = true;
      haskell.disabled = true;
      java.disabled = true;
      julia.disabled = true;
      nim.disabled = true;
      scala.disabled = true;
      conda.disabled = true;
      php.disabled = true;
      ruby.disabled = true;
      package.disabled = true;
    };
  };
}
