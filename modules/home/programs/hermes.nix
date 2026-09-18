{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.hermes.homeManagerModules.default ];

  # CLI and desktop app only. `services.hermes-agent` is the always-on
  # gateway daemon (Telegram etc.), which runs without approval prompts or
  # container isolation; keep it off. Runtime config lives in ~/.hermes.
  programs.hermes-agent = {
    enable = true;
    desktop = {
      enable = true;
      # Upstream nix/desktop.nix hardcodes a stale hash for the Electron
      # ${electron.version} headers tarball. Feed it a fetchurl with the real
      # one; drop this once a hermes bump fixes it.
      package = config.programs.hermes-agent.package.hermesDesktop.override {
        pkgs = pkgs // {
          fetchurl =
            args: pkgs.fetchurl (args // { sha256 = "sha256-xDgc5PpkcLpWHnlqVcjBD3SxJKtkUoSGLnJaSSrxJtI="; });
        };
      };
    };
  };
}
