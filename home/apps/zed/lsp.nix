_: {
  programs.zed-editor.userSettings.lsp = {
    nixd = {
      initialization_options = {
        formatting.command = [ "nixfmt" ];
      };
    };

    # Prefer project dependencies, including pnpm, over extension fallbacks.
    oxlint = {
      initialization_options.settings = {
        run = "onSave";
        configPath = null;
        disableNestedConfig = false;
        # Follow the project's type-aware policy and installed tsgolint.
        typeAware = null;
      };
    };
    oxfmt.initialization_options.settings = {
      "fmt.configPath" = null;
      "fmt.disableNestedConfig" = false;
    };

    vtsls = {
      settings = {
        vtsls.autoUseWorkspaceTsdk = true;
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
            enable = false;
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
            enable = false;
          };
          debug = {
            enable = true;
          };
        };
      };
    };

    clangd = {
      initialization_options = {
        fallbackFlags = [ ];
      };
    };
  };
}
