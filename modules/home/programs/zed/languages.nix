_: {
  programs.zed-editor.userSettings.languages = {
    Nix = {
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
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    HTML = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    JavaScript = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    TypeScript = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    TSX = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    JSON = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    JSONC = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    Markdown = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
    YAML = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "oxfmt";
        };
      };
    };
  };
}
