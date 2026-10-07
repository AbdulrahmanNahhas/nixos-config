_: {
  programs.fish.shellAbbrs = {
    # NVIDIA dGPU Offload, Usage:
    # - if flatpak: `nv flatpak run org.blender.Blender` (flatpak list)
    # - if nix pkg: `nv blender` (blender = name of pkg)
    nv = "nvidia-offload";
    wp = "wallpaper";

    # NixOS System Management
    nx-rebuild = "sys-switch";
    nx-test = "sys-test";
    nx-boot = "nh os boot /saved/nixos-config"; # Safer rebuild for Kernel/NVIDIA driver updates
    nx-update = "sys-update"; # Updates flake inputs before rebuilding
    # NixOS Maintenance
    nx-clean = "sys-clean";
    nx-optimize = "sys-optimise";

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
}
