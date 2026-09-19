{
  config,
  username,
  ...
}:
{
  imports = [
    ../modules/home/shell
    ../modules/home/desktop
    ../modules/home/programs
    ../modules/home/packages
    ../modules/home/wm
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "zeditor --wait";
    };
  };

  programs.home-manager.enable = true;

  # Decrypted at activation by sops-nix; the link contains no secret material.
  home.file.".config/nix/nix.conf".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/nix-config";
}

# After switching
# 1. `codex login` (ChatGPT account) → auth lands in ~/.codex/auth.json, shared with the desktop app and Zed's Codex agent. Then `codex` in a repo: it should introduce itself per persona.md (read from ~/.codex/AGENTS.md).
# 2. Launch "ChatGPT Community" from the launcher; sign in once (token goes to the keyring). Set persona for chat in ChatGPT itself: Settings → Personalization → Custom instructions (synced with the web).
# 3. Zed: agent panel → "Codex" (and "OpenCode") under external agents. Remove the old claude-acp registry entry from the panel. For the built-in agent, paste persona.md into Rules Library once and mark it default.
# 4. After the first ChatGPT app launch, confirm it created ~/.config/Codex (persisted); if it used another directory, change the entry in storage/preservation.nix.
# 5. Re-add WhatsApp as an app from Brave's menu; Nautilus takes over Mod+E.
# 6. Delete leftovers by hand: /saved/home/aqua/.hermes, /saved/home/aqua/.claude, /saved/home/aqua/.claude.json, /saved/home/aqua/.config/goose, /saved/home/aqua/.local/share/goose, /saved/var/lib/docker, /saved/home/aqua/.var/app/com.brave.Browser, /saved/home/aqua/.config/cosmic, /saved/home/aqua/.local/state/cosmic.
#
# Next month (OpenCode Zen or OpenRouter instead of ChatGPT): `opencode providers login` for the TUI; in Zed add the same key under the OpenRouter/OpenAI-compatible provider and point agent.default_model at it; Codex can keep working through a [model_providers] entry in ~/.codex/config.toml.
