_: {
  programs.zed-editor.userKeymaps = [
    {
      context = "Workspace";
      bindings = {
        # Individual panels & docks
        "ctrl-shift-e" = "project_panel::ToggleFocus";
        "ctrl-shift-a" = "agent::ToggleFocus";
        "ctrl-shift-b" = "outline_panel::ToggleFocus";
        "ctrl-shift-c" = "collab_panel::ToggleFocus";
        "ctrl-shift-g" = "git_panel::ToggleFocus";
        "ctrl-shift-d" = "debug_panel::ToggleFocus";
        "ctrl-shift-f" = "project_search::ToggleFocus"; # Replaced pane search with global search focus
        "ctrl-shift-m" = "diagnostics::Deploy";

        # Dock and sidebar toggles
        "ctrl-b" = "workspace::ToggleLeftDock";
        "ctrl-alt-b" = "workspace::ToggleRightDock";
        "ctrl-j" = "workspace::ToggleBottomDock";
        "ctrl-`" = "terminal_panel::Toggle";
        "ctrl-alt-j" = "multi_workspace::ToggleWorkspaceSidebar";
      };
    }
    {
      context = "Pane";
      bindings = {
        # Linear sequential tab navigation (left-to-right order)
        "ctrl-tab" = "pane::ActivateNextItem";
        "ctrl-shift-tab" = "pane::ActivatePreviousItem";

        # Tab management
        "ctrl-w" = "pane::CloseActiveItem";
        "ctrl-shift-t" = "pane::ReopenClosedItem";
      };
    }
    {
      context = "Editor";
      bindings = {
        # Line manipulation & editing enhancements
        "alt-up" = "editor::MoveLineUp";
        "alt-down" = "editor::MoveLineDown";
        "shift-alt-down" = "editor::DuplicateLineDown";
        "ctrl-/" = "editor::ToggleComments";
      };
    }
  ];
}
