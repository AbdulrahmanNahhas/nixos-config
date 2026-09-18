_: {
  programs.fish.shellAbbrs = {
    # NVIDIA dGPU Offload, Usage:
    # - if flatpak: `nv flatpak run org.blender.Blender` (flatpak list)
    # - if nix pkg: `nv blender` (blender = name of pkg)
    nv = "nvidia-offload";
    wp = "wallpaper";

    # NixOS System Management
    nx-rebuild = "nh os switch /saved/nixos-config";
    nx-test = "nh os test /saved/nixos-config";
    nx-boot = "nh os boot /saved/nixos-config"; # Safer rebuild for Kernel/NVIDIA driver updates
    nx-update = "nh os switch --update"; # Updates flake inputs before rebuilding
    # NixOS Maintenance
    nx-clean = "nh clean all --keep 3 --keep-since 7d --no-gcroots";
    nx-optimize = "sudo nix store optimise";

    # Hermes profiles (the Nix build does not write the ~/.hermes/bin wrappers)
    vivy = "hermes -p vivy";
    mira = "hermes -p mira";
    ash = "hermes -p ash";

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
