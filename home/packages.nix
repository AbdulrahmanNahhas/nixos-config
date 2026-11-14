{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Modern CLI

    eza # Better ls (aliases: ls, ll, la, tree)
    bat # Better cat (alias: cat)
    fd # Better find (alias: find)
    ripgrep # Better grep (alias: grep, command: rg)
    chafa # Terminal graphics (Images)
    dust # Better du (alias: du)
    duf # Better df (alias: df)
    procs # Better ps (alias: ps)
    btop # Interactive system monitor

    fastfetch # System information

    xh # Friendly HTTP client (curl alternative)

    # Archives

    ouch # Compress/extract almost any archive
    zip
    unzip

    # Networking

    dig # DNS lookup tool
    nmap # Network scanner

    # Security

    age # Modern file encryption
    sops # Manage encrypted secrets
    gnupg # GPG encryption & signing

    # Media

    ffmpeg # Audio/video conversion & processing

    # Nix development
    flake-checker
    deadnix
    nixd
    nixfmt
    statix

    # Git and forge tooling
    gh
    lazygit

    # Zed's agent requires a non-setuid bwrap on PATH for OS sandboxing.
    bubblewrap

    # Desktop utilities
    cosmic-files
    cosmic-edit
    cosmic-monitor
    cosmic-viewer # Review alongside Loupe before changing the image default
    loupe
    papers
    gnome-disk-utility
    polychromatic

    wl-clipboard

    # Desktop apps without dedicated configuration
    obsidian
    mullvad-browser
  ];

  # Override the package's XDG autostart entry; keep manual device control available.
  xdg.configFile."autostart/polychromatic-autostart.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Polychromatic Autostart
    Hidden=true
  '';

  home.sessionVariables.FLAKE_CHECKER_NO_TELEMETRY = "true";
}
