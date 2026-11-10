use common.nu *
use catalog.nu *
use actions.nu run-action
use apps.nu applications

def escape-markup [text: string] {
    $text | str replace --all '&' '&amp;' | str replace --all '<' '&lt;' | str replace --all '>' '&gt;'
}

def grid-label [text: string] {
    mut lines = []
    mut line = ''
    for word in ($text | split row ' ') {
        let next = if $line == '' { $word } else { $line + ' ' + $word }
        if ($next | str length) > 16 and $line != '' {
            $lines = ($lines | append $line)
            $line = $word
        } else { $line = $next }
    }
    let wrapped = ($lines | append $line)
    ($wrapped | first 2 | str join (char nl)) + (if ($wrapped | length) > 2 { '…' } else { '' })
}

def action-icon [action: record, groups: table] {
    let icons = {
        panel-opacity: '󰂵', bar-layout: '󰕰', wallpaper-picker: '󰸉', wallpaper-tag: '󰓹', wallpaper-name: '󰈙',
        wallpaper-all: '󰒺', wallpaper-next: '→', wallpaper-previous: '←', wallpaper-random: '󰒟', wallpaper-history: '󰋚', wallpaper-folder: '󰉋',
        theme: '󰔎', settings: '󰒓', nightlight: '󰖔', bar: '󰍜',
        check: '󰄬', build: '󰏗', test: '󰙨', switch: '󰑓', boot: '󰋊', update: '󰚰', update-input: '󰑓',
        generations: '󰋚', rollback: '↶', clean-preview: '󰈈', clean: '󰃢', optimise: '󰆧', packages: '󰏖', options: '󰒓', edit: '󰏫',
        status: '󰋼', travel: '󰆊', restore: '↶', saver: '󰌪', balanced: '󰓅', performance: '󰓅',
        dnd: '󰂛', caffeine: '󰅶', focus: '󰈈', presentation: '󰐩', focus-restore: '󰂚',
        display-mode: '󰍹', display-info: '󰋼', screen-off: '󰶐', brightness-up: '󰃠', brightness-down: '󰃞',
        audio-panel: '󰋋', mute: '󰝟', mic: '󰍬', quieter: '󰕿', louder: '󰕾',
        wifi: '󰖩', bluetooth: '󰂯', bluetooth-off: '󰂲', bluetooth-on: '󰂱',
        region: '󰆞', window: '󰖯', fullscreen: '󰍹', annotate: '󰏫', record: '󰑋', record-stop: '󰓛', record-settings: '󰒓',
        clipboard: '󰅌', emoji: '󰞅', apps: '󰀻', terminal: '', files: '󰉋', projects: '󰏓',
        failed: '󰀦', failed-user: '󰀦', logs: '󰋚', disk: '󰋊', shortcuts: '󰌌',
        lock: '󰌾', suspend: '󰒲', sessions: '󰍺', logout: '󰍃', reboot: '󰜉', shutdown: '󰐥'
    }
    $icons | get -o $action.id | default ($groups | where id == $action.group | first | get icon)
}

export def desktop-menu [initial: string = 'root'] {
    let catalog = (actions | append (applications))
    let groups = (categories)
    if $initial not-in (['root' 'search'] | append ($groups | get id)) { error make {msg: $"Unknown menu: ($initial)"} }
    mut route = $initial
    mut positions = {}
    let action_rows = ($catalog | each {|a| {
        id: $a.id, label: $a.label, description: $a.description,
        group_label: ($groups | where id == $a.group | first | get label),
        icon: (if $a.icon? != null { $a.icon } else { action-icon $a $groups }),
        search: $"($a.label) ($a.id) ($a.group) ($groups | where id == $a.group | first | get label) ($a.keywords? | default '')"
    }})
    loop {
        let grid = ($route == 'applications')
        let show_group = $route in [root search]
        let entries = if $route == 'root' {
            ($groups | each {|g| {id: $"menu:($g.id)", label: ($g.label + '  ›'), description: $g.description, icon: $g.icon}}) | append $action_rows
        } else {
            if $route == 'search' { $action_rows } else {
                let ids = ($catalog | where group == $route | get id)
                $action_rows | where {|a| $a.id in $ids }
            }
        }
        let rows = if $route == 'root' or $grid { $entries } else { [{id: back, label: 'Back', description: '', icon: ''}] | append $entries }
        let text = ($rows | each {|row|
            let label = (escape-markup (if $grid { grid-label $row.label } else { $row.label }))
            let description = if $show_group and $row.group_label? != null { $"($row.group_label) · ($row.description)" } else { $row.description }
            let display = if $grid or $row.description == '' { $label } else { $"<b>($label)</b>(char nl)<span size=\"small\" alpha=\"70%\">(escape-markup $description)</span>" }
            let kind = if $row.id == 'back' { 'back' } else if ($row.id | str starts-with 'menu:') { 'nav' } else { 'action' }
            let search = ($row.search? | default $row.label)
            [$kind ($display | encode base64) ($search | encode base64) ($row.label | encode base64) ($row.icon | encode base64)] | str join (char tab)
        } | str join (char nl))
        let remembered = ($positions | get -o $route | default (if $route != 'root' and not $grid and ($rows | length) > 1 { 1 } else { 0 }))
        let title = if $route == 'root' { 'Menu' } else if $route == 'search' { 'Search' } else { $groups | where id == $route | first | get label }
        # Rofi measures rows before loading their text; reserve both subtitle lines.
        let multiline = ($rows | any {|row| $row.description != '' })
        let row_height = if $multiline { 2 } else { 1 }
        let visible_rows = if $grid { 4 } else { 8 }
        let layout_flags = if $grid { ['-theme-str' 'actionbar { children: [ button-clear, spacer, button-accept ]; } listview { columns: 5; flow: horizontal; spacing: 8px; } element { orientation: vertical; spacing: 6px; padding: 10px 6px; background-color: @bg-alt; } element selected { background-color: @accent; } element-icon { size: 42px; horizontal-align: 0.5; expand: false; } element-text { font: "Geist 11"; horizontal-align: 0.5; vertical-align: 0.0; expand: false; }'] } else { [] }
        let back_label = if $route == 'root' { '"Esc  Close"' } else { '"Esc  Back"' }
        let accept_label = if $route == 'root' { '"Enter  Open"' } else { '"Enter  Run"' }
        let theme_flags = (theme-args)
        let icon_color = ($theme_flags | get -o 3 | default '' | parse --regex '(?m)^\s*fg:\s*(?<color>#[0-9a-fA-F]{6})' | get -o color.0 | default '#d8dee9')
        let selected_icon_color = ($theme_flags | get -o 3 | default '' | parse --regex '(?m)^\s*accent-fg:\s*(?<color>#[0-9a-fA-F]{6})' | get -o color.0 | default '#16161e')
        let result = (with-env {SHADOW_MENU_ROOT: (if $route == 'root' { '1' } else { '0' }), SHADOW_MENU_TITLE: $title, SHADOW_MENU_ICON_COLOR: $icon_color, SHADOW_MENU_SELECTED_ICON_COLOR: $selected_icon_color} {
            $text | ^rofi -modi shadow-menu -show shadow-menu -plugin-path $env.SHADOW_MENU_PLUGIN -show-icons -matching normal -no-sort -eh (if $grid { 2 } else { $row_height }) -selected-row $remembered -kb-custom-1 'Alt+s' -kb-custom-2 '' -kb-custom-3 'Alt+Left' ...$theme_flags ...$layout_flags -theme+listview+lines $visible_rows -theme+button-back+content $back_label -theme+button-accept+content $accept_label | complete
        })
        if $result.exit_code != 0 { error make {msg: $"Rofi failed: ($result.stderr)"} }
        let response = ($result.stdout | str trim)
        if $response == 'key:2' { if $route == 'root' { return }; $route = 'root'; continue }
        if $response == 'key:0' { $route = 'search'; continue }
        if ($response | str starts-with 'key:') { continue }
        if $response == '' {
            if $route == 'root' { return }
            $route = 'root'
            continue
        }
        let index = ($response | into int)
        $positions = ($positions | upsert $route $index)
        let selected = ($rows | get $index)
        if $selected.id == 'back' { $route = 'root'; continue }
        if ($selected.id | str starts-with 'menu:') { $route = ($selected.id | str substring 5..); continue }
        let action = ($catalog | where id == $selected.id | first)
        if $action.confirm and not (confirm $action.description) { continue }
        if $action.terminal { ^ghostty -e shadow terminal $action.id; return }
        try {
            run-action $action.id
        } catch {|error|
            ^notify-send --urgency=critical 'Desktop action failed' $error.msg
            print --stderr $error.msg
        }
        # Leave the screen clear for pickers, screenshots and launched windows.
        if $action.kind == 'exec' or $action.kind in [projects session folder application] { return }
    }
}
