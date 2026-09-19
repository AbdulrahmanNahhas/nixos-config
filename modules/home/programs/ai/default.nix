{ lib, pkgs, ... }:
{
  # Local models (llama-swap, Zed "Local" provider, `ai` function). Parked:
  # llama-cpp-cuda compiles locally on every nixpkgs bump. Re-import together
  # with the `ai` launcher entry in wm/noctalia/config.toml.
  # imports = [ ./local.nix ];

  # One persona for every assistant: each agent reads its own global
  # AGENTS.md. Zed's built-in agent keeps rules in a database instead, so
  # paste persona.md into its Rules Library once and mark it default; its
  # external agents below get the file through their own AGENTS.md.

  # Terminal agent for the ChatGPT subscription (`codex login`). Only the
  # AGENTS.md is declared: config.toml must stay a plain file because the
  # desktop app (nixos/desktop/chatgpt.nix) rewrites it and `/model` saves
  # into it. Next month's providers go there too, e.g. an OpenRouter entry
  # under [model_providers].
  programs.codex = {
    enable = true;
    context = ./persona.md;
  };

  # Provider-agnostic agent for after the subscription: `opencode providers
  # login` takes OpenCode Zen, OpenRouter, or any OpenAI-compatible endpoint.
  programs.opencode = {
    enable = true;
    context = ./persona.md;
  };

  # External agents in Zed's agent panel over ACP. Declared as "custom" with
  # nixpkgs binaries; the registry entries would fetch npx/tarball builds
  # instead. codex-acp is nixpkgs' codex, so it shares ~/.codex with the CLI.
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
