_: {
  programs.zed-editor.userKeymaps = [
    {
      context = "Workspace";
      bindings = {
        # Individual panels and center views: Ctrl+Shift plus a mnemonic.
        "ctrl-shift-e" = "project_panel::ToggleFocus";
        "ctrl-shift-a" = "agent::ToggleFocus";
        "ctrl-shift-b" = "outline_panel::ToggleFocus";
        "ctrl-shift-c" = "collab_panel::ToggleFocus";
        "ctrl-shift-g" = "git_panel::ToggleFocus";
        "ctrl-shift-d" = "debug_panel::ToggleFocus";
        "ctrl-shift-f" = "pane::DeploySearch";
        "ctrl-shift-m" = "diagnostics::Deploy";

        # Whole docks and special sidebars.
        "ctrl-b" = "workspace::ToggleLeftDock";
        "ctrl-alt-b" = "workspace::ToggleRightDock";
        "ctrl-j" = "workspace::ToggleBottomDock";
        "ctrl-`" = "terminal_panel::Toggle";
        "ctrl-alt-j" = "multi_workspace::ToggleWorkspaceSidebar";
      };
    }
  ];
}
