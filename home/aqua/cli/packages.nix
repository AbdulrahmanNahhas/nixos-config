{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # ─── Terminal & Editor ─────────────────────── #

    ghostty # Modern GPU terminal (run: ghostty)
    # zed-editor is installed by programs.zed-editor.enable in zed.nix
    micro # Nano alternative (run: micro)

    # ─── Shell ─────────────────────────────────── #

    fish # Friendly interactive shell
    starship # Cross-shell prompt

    # ─── Modern CLI ────────────────────────────── #

    eza # Better ls (aliases: ls, ll, la, tree)
    bat # Better cat (alias: cat)
    fd # Better find (alias: find)
    ripgrep # Better grep (alias: grep, command: rg)
    yazi # Terminal file manager (run: yazi)
    zoxide # Smart cd with history (alias: cd or z)
    atuin # Shell history search & sync

    dust # Better du (alias: du)
    duf # Better df (alias: df)
    procs # Better ps (alias: ps)
    btop # Interactive system monitor

    fastfetch # System information

    fzf # Fuzzy finder used everywhere
    xh # Friendly HTTP client (curl alternative)

    # ─── Archives ──────────────────────────────── #

    ouch # Compress/extract almost any archive

    # ─── Nix ───────────────────────────────────── #

    nixd # Nix language server (required by Zed's Nix extension)
    nil # alternative Nix language server (editor support)
    nixfmt # Official Nix formatter
    statix # Nix linter (alias nixlint)
    deadnix # Find unused Nix code
    devenv

    # ─── Git ───────────────────────────────────── #

    gh
    lazygit # Terminal Git UI

    # ─── Networking ────────────────────────────── #

    dig # DNS lookup tool
    nmap # Network scanner

    # ─── Security ──────────────────────────────── #

    age # Modern file encryption
    sops # Manage encrypted secrets
    gnupg # GPG encryption & signing

    # ─── Media ─────────────────────────────────── #

    ffmpeg # Audio/video conversion & processing

    # ─── AI ────────────────────────────────────── #
    opencode
    opencode-desktop

    # ─── Android ───────────────────────────────── #

    # android-tools    # adb & fastboot

    # ─── Obsidian ───────────────────────────────── #
    obsidian
  ];
}
