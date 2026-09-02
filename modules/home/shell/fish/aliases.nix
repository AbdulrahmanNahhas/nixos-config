_: {
  programs.fish.shellAliases = {
    # Core Replacements
    cat = "bat";
    grep = "rg";
    find = "fd";
    top = "btop";
    htop = "btop";
    ps = "procs";
    nano = "hx";

    # Quick Utils
    df = "duf";
    du = "dust";
    lazy = "lazygit";
    http = "xh";
  };
}
