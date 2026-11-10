{
  lib,
  pkgs,
  ...
}:
{
  # Local AI is parked; re-enable with its Noctalia launcher.
  # llama-cpp-cuda rebuilds locally on Nixpkgs updates.
  # imports = [ ./local.nix ];

  # Keep config.toml mutable for the desktop app and /model; declare only AGENTS.md.
  programs.codex = {
    enable = true;
    package = pkgs.codex;
    context = ./AGENTS.md;
  };

  xdg.configFile."delta/AGENTS.md".source = ./AGENTS.md;

  # Use packaged ACP binaries; registry entries download separate builds.
  # codex-acp shares ~/.codex with the CLI.
  programs.zed-editor.userSettings.agent_servers = {
    Codex = {
      type = "custom";
      command = lib.getExe pkgs.codex-acp;
    };
  };
}
