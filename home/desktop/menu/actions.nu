use common.nu *
use catalog.nu actions
use system.nu *
use power.nu *
use wallpaper.nu *
use layout.nu [bar-layout panel-opacity]

def calculate [initial: string = ''] {
    # Capture stdout instead of interpolating calculator output into a shell command.
    let result = (^rofi -modi calc -show calc -no-show-match -no-sort -no-history -terse -filter $initial -p 'Calculate' -hint-welcome 'Math · 100 USD to EUR · 10 miles to km · Enter copies' -hint-result '= ' -kb-accept-entry '' -kb-accept-custom Return ...(theme-args) -theme-str 'mainbox { children: [ inputbar, message ]; } message { padding: 12px; } textbox { font: "GeistMono Nerd Font 12"; }' | complete)
    if $result.exit_code == 1 { return }
    if $result.exit_code != 0 { error make {msg: $"Calculator failed: ($result.stderr)"} }
    let value = ($result.stdout | str trim)
    if $value == '' { return }
    let copied = ($value | ^wl-copy --type text/plain | complete)
    if $copied.exit_code != 0 { error make {msg: $"Copy failed: ($copied.stderr)"} }
    ^notify-send --app-name Shadow --expire-time 2500 'Result copied' $value
}

def refresh-rates [] {
    ^notify-send --app-name Shadow --expire-time 2500 'Currency rates' 'Downloading exchange rates…'
    let result = (^timeout 45s qalc -exrates -terse '1' | complete)
    if $result.exit_code != 0 { error make {msg: $"Exchange-rate refresh failed: ($result.stderr) ($result.stdout)"} }
    ^notify-send --app-name Shadow --expire-time 3500 'Currency rates' 'Exchange-rate refresh finished.'
}

export def run-action [id: string] {
    if ($id | str starts-with 'app:') {
        ^shadow-apps launch ($id | str substring 4..)
        if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Application launch failed'} }
        return
    }
    let matches = (actions | where id == $id)
    if ($matches | is-empty) { error make {msg: $"Unknown action: ($id)"} }
    let action = $matches.0
    match $action.kind {
        exec => {
            let theme = if $action.args.0 == 'rofi' { theme-args } else { [] }
            ^($action.args.0) ...($action.args | skip 1) ...$theme
        }
        nix => { nix-action $action.args.0 ...($action.args | skip 1) }
        search => {
            let query = (input 'Search: ')
            if ($query | is-not-empty) { nix-action $action.args.0 $query }
        }
        calculator => { calculate $action.args.0 }
        rates => { refresh-rates }
        status => { system-status }
        mode => { travel $action.args.0 }
        focus => { focus-mode $action.args.0 }
        display => { display-picker }
        outputs => { displays }
        opacity => { panel-opacity }
        layout => { bar-layout }
        wallpaper => { wallpaper-action $action.args.0 ($action.args.1? | default 'tag') }
        folder => { ^ghostty -e yazi ($env.HOME | path join ...$action.args) }
        shortcuts => {
            if (compositor) == 'umbriel' { ^umbriel msg cheatsheet-open } else { ^niri msg action show-hotkey-overlay }
        }
        session => { ^noctalia msg session logout }
        projects => {
            let root = ($env.HOME | path join Projects)
            let result = (^fd --hidden --no-ignore --max-depth 6 --type d --type f '^\.git$' $root | complete)
            if $result.exit_code != 0 { error make {msg: $result.stderr} }
            let projects = ($result.stdout | lines | each {|p| $p | path dirname } | uniq | sort)
            let selected = (choose 'Open project in Zed' $projects)
            if $selected != null { ^zeditor $selected }
        }
    }
    if $action.kind == 'exec' and $env.LAST_EXIT_CODE != 0 { error make {msg: $"($action.label) failed (exit ($env.LAST_EXIT_CODE))"} }
    if $id in [travel restore focus presentation focus-restore wallpaper-next wallpaper-previous wallpaper-random saver balanced performance] {
        let notification = (^notify-send --app-name Shadow --expire-time 2500 'Desktop' $action.label | complete)
        if $notification.exit_code != 0 { print --stderr $"Notification delivery failed: ($notification.stderr)" }
    }
}
