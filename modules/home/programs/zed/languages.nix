{ lib, ... }:
let
  oxfmt = {
    format_on_save = "on";
    formatter.language_server.name = "oxfmt";
    language_servers = [
      "oxfmt"
      "!biome"
      "..."
    ];
    # Mutable settings retain old entries after activation. Explicitly turn
    # off the former Biome actions as well as broad quick fixes.
    code_actions_on_format = {
      "source.fixAll.biome" = false;
      "source.organizeImports.biome" = false;
      quickfix = false;
    };
  };
  web = oxfmt // {
    language_servers = [
      "vtsls"
      "oxlint"
      "oxfmt"
      "!biome"
      "!eslint"
      "!typescript-language-server"
      "..."
    ];
    code_actions_on_format = oxfmt.code_actions_on_format // {
      "source.fixAll.oxc" = true;
    };
  };
in
{
  programs.zed-editor.userSettings.languages =
    lib.genAttrs [ "JavaScript" "JSX" "TypeScript" "TSX" ] (_: web)
    // lib.genAttrs [
      "CSS"
      "JSON"
      "JSONC"
      "HTML"
      "Markdown"
      "YAML"
    ] (_: oxfmt)
    // {
      Nix = {
        language_servers = [
          "nixd"
          "!nil"
        ];
        formatter.language_server.name = "nixd";
        format_on_save = "on";
      };
      Rust = {
        tab_size = 2;
        formatter = "language_server";
        format_on_save = "on";
      };
      Java = {
        language_servers = [
          "jdtls"
          "..."
        ];
        formatter.language_server.name = "jdtls";
        format_on_save = "on";
      };
      C = {
        language_servers = [
          "clangd"
          "..."
        ];
        formatter.language_server.name = "clangd";
        format_on_save = "on";
      };
      "C++" = {
        language_servers = [
          "clangd"
          "..."
        ];
        formatter.language_server.name = "clangd";
        format_on_save = "on";
      };
      # The TOML extension supplies syntax; Tombi supplies its language server.
      TOML = {
        formatter.language_server.name = "tombi";
        language_servers = [
          "tombi"
          "!taplo"
          "!oxfmt"
          "..."
        ];
        format_on_save = "on";
      };
      # Go templates can contain HTML attributes that plain HTML formatters
      # cannot parse. Use a template formatter only after one is configured.
      "Go HTML Template" = {
        format_on_save = "off";
        formatter = "none";
        tab_size = 2;
        hard_tabs = false;
      };
    };
}
