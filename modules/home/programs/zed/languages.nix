_: {
  programs.zed-editor.userSettings.languages = {
    Nix = {
      language_servers = [
        "nixd"
        "!nil"
      ];
      formatter = {
        language_server = {
          name = "nixd";
        };
      };
      format_on_save = "on";
    };
    Rust = {
      tab_size = 2;
      formatter = "language_server";
      format_on_save = "on";
    };
    C = {
      formatter = "language_server";
      format_on_save = "on";
    };
    "C++" = {
      formatter = "language_server";
      format_on_save = "on";
    };
    CSS = {
      language_servers = [
        "biome"
        "..."
      ];
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "biome";
        };
      };
    };
    JavaScript = {
      language_servers = [
        "vtsls"
        "biome"
        "..."
      ];
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "biome";
        };
      };
    };
    TypeScript = {
      language_servers = [
        "vtsls"
        "biome"
        "..."
      ];
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "biome";
        };
      };
    };
    TSX = {
      language_servers = [
        "vtsls"
        "biome"
        "..."
      ];
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "biome";
        };
      };
    };
    JSON = {
      language_servers = [
        "biome"
        "..."
      ];
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "biome";
        };
      };
    };
    JSONC = {
      language_servers = [
        "biome"
        "..."
      ];
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "biome";
        };
      };
    };
    # Biome does not cover these formats. Keep Zed's supported defaults,
    # which currently use Prettier for HTML, Markdown, and YAML.
    HTML.format_on_save = "on";
    Markdown = {
      format_on_save = "on";
    };
    YAML.format_on_save = "on";
  };
}
