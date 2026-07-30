_: {
  programs.zed-editor.userSettings.lsp = {
    nixd = {
      initialization_options = {
        formatting.command = [ "nixfmt" ];
      };
    };

    biome = {
      settings = {
        # Avoid Zed downloading and running its own Biome in projects that
        # have not explicitly opted in with biome.json or biome.jsonc.
        require_config_file = true;
      };
    };

    vtsls = {
      settings = {
        typescript = {
          updateImportsOnFileMove = {
            enabled = "always";
          };
          preferences = {
            includeInlayParameterNameHints = "none";
            includeInlayParameterNameHintsWhenArgumentMatchesName = false;
            includeInlayFunctionParameterTypeHints = false;
            includeInlayVariableTypeHints = false;
            includeInlayVariableTypeHintsWhenTypeMatchesName = false;
            includeInlayPropertyDeclarationTypeHints = false;
            includeInlayFunctionLikeReturnTypeHints = false;
            includeInlayEnumMemberValueHints = false;
          };
        };
        javascript = {
          updateImportsOnFileMove = {
            enabled = "always";
          };
          preferences = {
            includeInlayParameterNameHints = "none";
            includeInlayParameterNameHintsWhenArgumentMatchesName = false;
            includeInlayFunctionParameterTypeHints = false;
            includeInlayVariableTypeHints = false;
            includeInlayVariableTypeHintsWhenTypeMatchesName = false;
            includeInlayPropertyDeclarationTypeHints = false;
            includeInlayFunctionLikeReturnTypeHints = false;
            includeInlayEnumMemberValueHints = false;
          };
        };
      };
    };

    rust-analyzer = {
      enable_lsp_tasks = true;
      initialization_options = {
        check = {
          command = "clippy";
        };
        inlayHints = {
          maxLength = null;
          lifetimeElisionHints = {
            enable = "skip_trivial";
            useParameterNames = true;
          };
          closureReturnTypeHints = {
            enable = "always";
          };
          bindingModeHints = {
            enable = true;
          };
          discriminantHints = {
            enable = "fieldless";
          };
          closingBraceHints = {
            enable = true;
            minLines = 1;
          };
        };
        lens = {
          enable = true;
          implementations = {
            enable = true;
          };
          references = {
            adt = {
              enable = false;
            };
            enumVariant = {
              enable = false;
            };
            method = {
              enable = false;
            };
            trait = {
              enable = false;
            };
          };
          run = {
            enable = true;
          };
          debug = {
            enable = true;
          };
        };
      };
    };

    clangd = {
      initialization_options = {
        fallbackFlags = [ "-std=c++20" ];
      };
    };
  };
}
