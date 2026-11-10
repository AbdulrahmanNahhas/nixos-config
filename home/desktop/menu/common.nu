const MENU_THEME = path self desktop.rasi

export def menu-runtime [] {
    let uid = (^id -u | str trim)
    ($env.XDG_RUNTIME_DIR? | default ($env.TMPDIR? | default '/tmp')) | path join $"shadow-menu-($uid)"
}

export def state-dir [] {
    let base = ($env.XDG_STATE_HOME? | default ($env.HOME | path join '.local/state'))
    $base | path join noctalia shadow
}

export def read-json [path: path, fallback: any] {
    if ($path | path exists) { open --raw $path | from json } else { $fallback }
}

export def write-json [path: path, value: any] {
    mkdir ($path | path dirname)
    let temporary = ($path + '.tmp.' + (random uuid))
    $value | to json | save --force $temporary
    mv --force $temporary $path
}

export def probe [command: list<string>] {
    let result = (do { ^timeout 3s $command.0 ...($command | skip 1) } | complete)
    if $result.exit_code == 0 { $result.stdout | str trim } else { 'Unavailable' }
}

export def choose [title: string, rows: list<string>, --multiple, --timeout: int = 0] {
    let flags = if $multiple { ['-multi-select'] } else { [] }
    let command = if $timeout > 0 { ['timeout' $"($timeout)s" 'rofi'] } else { ['rofi'] }
    let result = ($rows | str join (char nl) | ^($command.0) ...($command | skip 1) -dmenu -i -no-custom -p $title ...(theme-args) ...$flags | complete)
    if $result.exit_code == 1 { return null }
    if $timeout > 0 and $result.exit_code == 124 { return null }
    if $result.exit_code != 0 { error make {msg: $"Rofi failed: ($result.stderr)"} }
    $result.stdout | str trim
}

export def confirm [message: string] {
    (choose $message ['Cancel' 'Continue']) == 'Continue'
}

export def theme-args [] {
    let config = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join .config))
    let generated = ($config | path join rofi noctalia.rasi)
    if ($generated | path exists) {
        let palette = (open --raw $generated | parse --regex '(?s)\A(?P<palette>\*\s*\{[^}]*\})' | get palette.0)
        ['-theme' $MENU_THEME '-theme-str' $palette]
    } else { [] }
}

export def compositor [] {
    if (($env.XDG_CURRENT_DESKTOP? | default '' | str lowercase) | str contains 'umbriel') { 'umbriel' } else if ($env.NIRI_SOCKET? | is-not-empty) { 'niri' } else { 'unknown' }
}
