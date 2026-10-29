{
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./hermes.nix ];

  # Local AI is parked; re-enable with its Noctalia launcher.
  # llama-cpp-cuda rebuilds locally on Nixpkgs updates.
  # imports = [ ./local.nix ];

  # Share AGENTS.md through agent instruction files; set Zed’s Rules Library default manually.

  # Keep config.toml mutable for the desktop app and /model; declare only AGENTS.md.
  programs.codex = {
    enable = true;
    context = ./AGENTS.md;
  };

  # Use opencode providers login to configure a provider.
  programs.opencode = {
    enable = true;
    context = ./AGENTS.md;
  };

  # Delta looks for project-level instructions in its config directory.
  xdg.configFile."delta/AGENTS.md".source = ./AGENTS.md;

  # Use packaged ACP binaries; registry entries download separate builds.
  # codex-acp shares ~/.codex with the CLI.
  programs.zed-editor.userSettings.agent_servers = {
    Codex = {
      type = "custom";
      command = lib.getExe pkgs.codex-acp;
    };
    OpenCode = {
      type = "custom";
      command = lib.getExe pkgs.opencode;
      args = [ "acp" ];
    };
  };
}
