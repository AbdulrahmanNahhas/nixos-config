use catalog.nu [actions categories]

def complete-command [] { [menu status actions nix layout opacity mode wallpaper run] }
def complete-menu [] { [root search] | append (categories | get id) }
def complete-nix [] { actions | where kind in [nix search] | get args | each { first } | uniq }
def complete-layout [] { [bottom gnome right cycle] }
def complete-opacity [] { [solid soft toggle] }
def complete-mode [] { [travel restore focus presentation focus-restore] }
def complete-wallpaper [] { [picker status list select all next previous random history] }
def complete-kind [] { [tag name] }
def complete-action [] { actions | select id description | rename value description }

# Signatures add completion without wrapping or replacing the command dispatcher.
export extern shadow [command?: string@complete-command ...args: string]
export extern "shadow menu" [category?: string@complete-menu]
export extern "shadow status" [--json]
export extern "shadow nix" [operation?: string@complete-nix ...args: string]
export extern "shadow layout" [layout?: string@complete-layout]
export extern "shadow opacity" [mode?: string@complete-opacity]
export extern "shadow mode" [mode?: string@complete-mode]
export extern "shadow wallpaper" [operation?: string@complete-wallpaper kind?: string@complete-kind]
export extern "shadow run" [action: string@complete-action]
