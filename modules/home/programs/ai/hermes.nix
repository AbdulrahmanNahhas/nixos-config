{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  upstream = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.minimal;
  sandboxTools = [
    pkgs.bubblewrap
    pkgs.util-linux
  ];

  # Apply to CLI and Desktop's child runtime without rewriting an existing .env.
  hermes = upstream.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      wrapProgram "$out/bin/hermes" \
        --set HERMES_NATIVE_FILE_READ 0 \
        --prefix PATH : ${lib.makeBinPath sandboxTools}
    '';
  });

  workspace = "${config.home.homeDirectory}/Documents/Hermes";
in
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent = {
    enable = true;
    desktop = {
      enable = true;
      # Keep Electron preferences inside the same persistent private directory.
      package = hermes.hermesDesktop.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          wrapProgram "$out/bin/hermes-desktop" \
            --set HERMES_DESKTOP_USER_DATA_DIR ${lib.escapeShellArg "${config.services.hermes-agent.hermesHome}/desktop/electron"}
        '';
      });
    };
  };

  services.hermes-agent = {
    enable = true;
    package = hermes;
    workingDirectory = workspace;

    # Start interactively; enable messaging and unattended work separately.
    gateway.enable = false;
    backend.mode = "none";
    extraPackages = sandboxTools;

    settings = {
      model = {
        provider = "openai-codex";
        default = "gpt-6.1-sol";
        openai_runtime = "auto";
      };
      terminal = {
        backend = "bubblewrap";
        cwd = workspace;
        degraded_mode = "fail";
        timeout = 180;
      };
      plugins = {
        enabled = [ "bubblewrap" ];
        entries.bubblewrap.settings = {
          profile = "workspace";
          memory_mb = 2048;
          cpu_seconds = 600;
          max_procs = 256;
          # Shared skill scripts are visible read-only through their home path.
          home_allow = [ ".agents" ];
        };
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
        provider = "";
      };
      skills.external_dirs = [ "${config.home.homeDirectory}/.agents/skills" ];
    };

    hermesHomeFiles."SOUL.md" = ./SOUL.md;
  };
}
