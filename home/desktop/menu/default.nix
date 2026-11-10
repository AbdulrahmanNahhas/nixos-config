{
  config,
  lib,
  pkgs,
  ...
}:
let
  mode = import ./rofi-mode.nix { inherit pkgs; };
  runtime = lib.makeBinPath [
    mode
    pkgs.fastfetch
    pkgs.nushell
    pkgs.rofi
    pkgs.coreutils
    pkgs.git
    pkgs.nh
    pkgs.nix
    pkgs.systemd
    pkgs.power-profiles-daemon
    pkgs.brightnessctl
    pkgs.wireplumber
    pkgs.wlr-randr
    pkgs.libnotify
    pkgs.ghostty
    pkgs.yazi
    pkgs.fd
    pkgs.xdg-utils
    config.programs.noctalia.package
  ];
  shadow = pkgs.writeTextFile {
    name = "shadow-desktop";
    destination = "/bin/shadow";
    executable = true;
    text = ''
      #!${lib.getExe pkgs.nushell} --no-config-file
      use ${./.}/shadow.nu
      def --wrapped main [...args: string] {
        $env.PATH = ($env.PATH | prepend (${builtins.toJSON runtime} | split row ':'))
        $env.SHADOW_MENU_PLUGIN = '${mode}/lib/rofi'
        $env.SHADOW_NOCTALIA_BASE = '${../noctalia/config.toml}'
        $env.SHADOW_NOCTALIA_LAYOUTS = '${../noctalia/layouts.toml}'
        shadow ...$args
      }
    '';
  };
  compatibility =
    name: command:
    pkgs.writeTextFile {
      inherit name;
      destination = "/bin/${name}";
      executable = true;
      text = ''
        #!${lib.getExe pkgs.nushell} --no-config-file
        def --wrapped main [...args: string] { ^${shadow}/bin/shadow ${command} ...$args }
      '';
    };
in
{
  home.packages = [
    shadow
    (compatibility "desktop-menu" "menu")
    (compatibility "wallpaper-tag" "wallpaper")
  ];
  # Retire obsolete GUI overrides when this Home Manager generation is activated.
  home.activation.noctaliaBarLayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${shadow}/bin/shadow layout migrate
  '';
  # Noctalia owns generated colors; this theme owns layout and the fallback palette.
  programs.rofi = {
    enable = true;
    theme = ./desktop.rasi;
    settings = {
      modi = "drun,run";
      show-icons = true;
      matching = "normal";
      scroll-method = 1;
      cycle = false;
      kb-clear-line = "Control+a,Control+w";
      kb-move-front = "Control+Home";
      sorting-method = "fzf";
      drun-display-format = "{name}";
      disable-history = false;
    };
  };
}
