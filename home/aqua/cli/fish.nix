{ ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      # NVIDIA dGPU Offload, Usage:
      # - if flatpak: `nv flatpak run org.blender.Blender` (flatpak list)
      # - if nix pkg: `nv blender` (blender = name of pkg)
      nv = "nvidia-offload";

      # NixOS System Management
      nx-rebuild = "nh os switch /saved/nixos-config";
      nx-test = "nh os test /saved/nixos-config";
      nx-clean = "nh clean all --keep-since 14d --keep 10";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Eza (modern ls)
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --git";
      la = "eza -la --icons --group-directories-first --git";
      tree = "eza --tree --icons --level=2";

      # Archives
      compress = "ouch compress";
      extract = "ouch decompress";

      # Git
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";
    };

    shellAliases = {
      # Core Replacements
      cat = "bat";
      grep = "rg";
      find = "fd";
      top = "btop";
      htop = "btop";
      ps = "procs";
      nano = "micro";

      # Quick Utils
      df = "duf";
      du = "dust";
      lazy = "lazygit";
      http = "xh";
    };

    functions = {
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
    };

    interactiveShellInit = ''
      # Remove fish startup greeting
      set fish_greeting ""

      # Fastfetch — ONLY trigger when running inside Ghostty
      if test "$TERM_PROGRAM" = "ghostty"
          fastfetch
      end

      # Initialize starship prompt
      starship init fish | source

      # Initialize zoxide
      zoxide init fish | source

      # Initialize atuin (shell history)
      atuin init fish | source
    '';
  };

  # Starship prompt config
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

      username = {
        disabled = false;
        show_always = true;
        format = "[](fg:surface)[ 󰧱 $user ]($style)[](fg:surface) ";
        style_user = "bg:surface fg:fg";
        style_root = "bg:surface fg:red";
      };

      sudo = {
        disabled = false;
        symbol = "󰌾";
        style = "bg:surface fg:red";
        format = "[](fg:surface)[$symbol ]($style)[](fg:surface) ";
      };

      nix_shell = {
        disabled = false;
        symbol = " ";
        style = "bg:surface fg:blue";
        format = "[](fg:surface)[$symbol$name ]($style)[](fg:surface) ";
      };

      directory = {
        format = "[](fg:surface)[$path ]($style)[](fg:surface) ";
        style = "bg:surface fg:fg";
        truncation_length = 2;
        truncation_symbol = "…/";
        truncate_to_repo = true;
        read_only = " ";
        home_symbol = "~";
      };

      directory.substitutions = {
        Documents = "󰈙";
        Downloads = " ";
        Music = " ";
        Pictures = " ";
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
        format = "[](fg:surface)[$symbol $branch]($style)[](fg:surface) ";
        style = "bg:surface fg:fg";
        symbol = "";
      };

      git_status = {
        disabled = false;
        format = "[](fg:surface)([$staged$modified$deleted$untracked]($style))[](fg:surface)";
        style = "bg:surface fg:yellow";

        staged = "[+$count ](bg:surface fg:green)";
        modified = "[~$count ](bg:surface fg:yellow)";
        deleted = "[-$count ](bg:surface fg:red)";
        untracked = "[?$count ](bg:surface fg:blue)";
      };

      container = {
        format = "[](fg:surface)[$symbol $name ]($style)[](fg:surface) ";
        symbol = "⬢";
        style = "bg:surface fg:blue";
      };

      rust = {
        style = "bg:surface fg:fg";
        format = " [](fg:surface)[$symbol$version ]($style)[](fg:surface)";
        symbol = " ";
        disabled = false;
      };

      nodejs = {
        style = "bg:surface fg:fg";
        format = " [](fg:surface)[$symbol$version ]($style)[](fg:surface)";
        symbol = "󰎙 ";
        disabled = false;
      };

      python = {
        style = "bg:surface fg:fg";
        format = " [](fg:surface)[$symbol$version ]($style)[](fg:surface)";
        symbol = " ";
        disabled = false;
      };

      jobs = {
        symbol = " ";
        style = "bg:surface fg:yellow";
        format = " [](fg:surface)[$symbol$number ]($style)[](fg:surface)";
        disabled = false;
      };

      status = {
        disabled = false;
        format = " [](fg:surface)[✘ $status ]($style)[](fg:surface)";
        style = "bg:surface fg:red";
      };

      cmd_duration = {
        min_time = 1000;
        format = " [](fg:surface)[took $duration ]($style)[](fg:surface)";
        style = "bg:surface fg:muted";
      };

      time = {
        disabled = false;
        format = " [](fg:surface)[$time 󰴈 ]($style)[](fg:surface)";
        style = "bg:surface fg:muted";
        time_format = "%I:%M%P";
      };

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
