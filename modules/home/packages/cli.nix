{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ─── Modern CLI ────────────────────────────── #

    eza # Better ls (aliases: ls, ll, la, tree)
    bat # Better cat (alias: cat)
    fd # Better find (alias: find)
    ripgrep # Better grep (alias: grep, command: rg)
    yazi
    chafa # Terminal graphics (Images)
    dust # Better du (alias: du)
    duf # Better df (alias: df)
    procs # Better ps (alias: ps)
    btop # Interactive system monitor

    fastfetch # System information

    xh # Friendly HTTP client (curl alternative)

    # ─── Archives ──────────────────────────────── #

    ouch # Compress/extract almost any archive
    zip # Used by noctalia's libreoffice theme template to build its .oxt
    unzip

    # ─── Networking ────────────────────────────── #

    dig # DNS lookup tool
    nmap # Network scanner

    # ─── Security ──────────────────────────────── #

    age # Modern file encryption
    sops # Manage encrypted secrets
    gnupg # GPG encryption & signing

    # ─── Media ─────────────────────────────────── #

    ffmpeg # Audio/video conversion & processing

  ];
}
