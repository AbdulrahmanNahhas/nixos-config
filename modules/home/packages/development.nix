{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    # Nix development
    deadnix
    devenv
    nixd
    nixfmt
    statix

    # Git and forge tooling
    gh
    lazygit

    # Sandboxing (used by Claude Code's bubblewrap-based agent sandbox)
    bubblewrap
    socat

    # Coding agent
    claude-code
    (inputs.goose.packages.${pkgs.system}.default.overrideAttrs (_oldAttrs: {
      doCheck = false;
      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = inputs.goose + "/Cargo.lock";
        outputHashes = {
          "agent-client-protocol-2.0.0" = "sha256-62Bc5XLIx38npCkmijutjJOxjfESg3+m/Ih409ELXNQ=";
          "cudaforge-0.1.6" = "sha256-w0e/mfx08BkphDEFEWxuyxyZu/gHiG0m6RHx+3BLzDY=";
        };
      };
    }))
  ];
}
