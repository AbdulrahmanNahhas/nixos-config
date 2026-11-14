use common.nu [state-dir read-json write-json choose]

const BASE = path self ../noctalia/config.toml
const PRESETS = path self ../noctalia/layouts.toml

export def appearance-config [settings: record, opacity: string] {
    if $opacity not-in [solid soft] { error make {msg: 'Panel opacity must be solid or soft'} }
    let solid = ($opacity == 'solid')
    let alpha = if $solid { 1.0 } else { 0.85 }
    $settings
    | upsert bar {||
        $settings.bar | transpose key value | each {|entry|
            {key: $entry.key, value: (if $entry.key == 'order' { $entry.value } else { $entry.value | merge {background_opacity: $alpha, compositor_blur: (not $solid)} })}
        } | transpose -r -d
    }
    | upsert dock.background_opacity $alpha
    | upsert dock.compositor_blur (not $solid)
    | upsert shell.panel.transparency_mode $opacity
    | upsert shell.settings_window_translucent false
    | upsert osd.background_opacity $alpha
    | upsert plugin_settings.'avivbintangaringga/nix-monitor'.panel_card_opacity (if $solid { 100 } else { 85 })
}

# Keep old CLI callers and saved selections working after retiring the sidebar.
export def layout-name [name: string] {
    match $name {
        gnome | right => { 'main' }
        bottom => { 'traditional' }
        main | traditional => { $name }
        _ => { error make {msg: $"Unknown desktop layout: ($name)"} }
    }
}

export def whatsapp-launchers [profile?: path] {
    let applications = (($env.XDG_DATA_HOME? | default ($env.HOME | path join .local/share)) | path join applications)
    if not ($applications | path exists) { return [] }
    glob ($applications | path join '*.webapp-*.desktop') | sort | where {|path|
        let text = (try { open --raw $path } catch { '' })
        let command = ($text | lines | parse 'Exec={command}' | get -o command.0 | default '')
        (('Hidden=true' not-in ($text | lines))
        and ($command | str contains '"-taskbar-tab" "')
        and ($command | str contains '"-container" "0"')
        and ($profile == null or ($command | str contains $'"-profile" "($profile)"'))
        and (['"-new-window" "https://web.whatsapp.com"' '"-new-window" "https://web.whatsapp.com/"'] | any {|url| $command | str contains $url }))
    } | each {|path| $path | path basename }
}

# Firefox assigns native Web Apps a runtime desktop ID; keep its ordered slot.
export def resolve-pins [pins: list<string>] {
    if 'whatsapp-web' not-in $pins { return $pins }
    let profile = (($env.XDG_CONFIG_HOME? | default ($env.HOME | path join .config)) | path join mozilla firefox default)
    let native = (whatsapp-launchers $profile | get -o 0)
    if $native == null { return $pins }
    let id = ($native | str replace --regex '\.desktop$' '')
    $pins | each {|pin| if $pin == 'whatsapp-web' { $id } else { $pin } } | uniq
}

def panel-options [prefix: string, placement: string, position: string] {
    [
        {key: $"($prefix)_placement", value: $placement}
        {key: $"($prefix)_position", value: $position}
        {key: $"($prefix)_open_near_click", value: false}
        {key: $"($prefix)_layer", value: overlay}
    ] | transpose -r -d
}

def panel-config [settings: record, placement: string, position: string] {
    let panels = ([clipboard control_center launcher session wallpaper polkit] | reduce --fold {} {|panel, result|
        $result | merge ([
            {key: $"($panel)_placement", value: $placement}
            {key: $"($panel)_position", value: $position}
        ] | transpose -r -d)
    })
    let plugins = ([
        {id: 'avivbintangaringga/nix-monitor', entries: [panel]}
        {id: 'ycf/mawaqit', entries: [panel]}
        {id: 'noctalia/umbriel-companion', entries: [panel]}
        {id: 'noctalia/wallhaven', entries: [browser]}
        {id: 'alexander/screen-toolkit', entries: [panel result pick]}
    ] | each {|plugin|
        {key: $plugin.id, value: ($plugin.entries | reduce --fold {} {|entry, result|
            $result | merge (panel-options $entry $placement $position)
        })}
    } | transpose -r -d)
    $settings
    | upsert shell.panel {||
        $settings.shell.panel | merge $panels | merge {
            open_near_click_clipboard: false
            open_near_click_control_center: false
            open_near_click_launcher: false
            open_near_click_session: false
            open_near_click_wallpaper: false
        }
    }
    | upsert plugin_settings {|| $settings.plugin_settings | merge deep $plugins }
}

export def layout-config [settings: record, requested: string, opacity: string = 'solid'] {
    let name = (layout-name $requested)
    let base = (open --raw ($env.SHADOW_NOCTALIA_BASE? | default $BASE) | from toml)
    let presets = (open --raw ($env.SHADOW_NOCTALIA_LAYOUTS? | default $PRESETS) | from toml)

    let preset = ($presets | get $name)
    let desktop_widgets = (
        ($settings | get -o desktop_widgets | default {})
        | merge deep $base.desktop_widgets
        | merge deep $presets.defaults.desktop_widgets
        | merge deep ($preset | get -o desktop_widgets | default {})
    )
    let plugins = ($settings | get -o plugins.enabled | default $base.plugins.enabled | where $it != 'ashur-d/wallpaper-widget' | append 'noctalia/umbriel-companion' | uniq)
    # GUI overrides take precedence over the declarative file, so clean both layers.
    $settings
    | reject -o bar.Utilities widget.widget_2
    | upsert plugin_settings {|| $settings | get -o plugin_settings | default {} | reject -o 'ashur-d/wallpaper-widget' }
    | upsert plugins.enabled $plugins
    | upsert desktop_widgets $desktop_widgets
    | upsert bar { order: [default], default: ($base.bar.default | merge $preset.bar) }
    | upsert shell.panel {|| $base.shell.panel | merge ($settings | get -o shell.panel | default {}) }
    | upsert widget {||
        $base.widget
        | merge deep ($settings | get -o widget | default {})
        | upsert umbriel_companion $base.widget.umbriel_companion
        | upsert taskbar.pinned $presets.defaults.dock.pinned
        | merge deep $presets.defaults.widget
        | merge deep $preset.widget
        | reject -o widget_2
    }
    | upsert widget.nix-monitor $base.widget.nix-monitor
    | upsert widget.session $base.widget.session
    | upsert widget.launcher.actions $base.widget.launcher.actions
    | upsert hot_corners.bottom_left $base.hot_corners.bottom_left
    | upsert plugin_settings.'avivbintangaringga/nix-monitor' {||
        ($settings | get -o plugin_settings.'avivbintangaringga/nix-monitor' | default {})
        | merge $base.plugin_settings.'avivbintangaringga/nix-monitor'
    }
    | upsert dock {||
        ($settings | get -o dock | default {})
        | merge $presets.defaults.dock
        | merge $presets.main.dock
        | merge $preset.dock
    }
    | upsert widget.taskbar.pinned (resolve-pins $in.widget.taskbar.pinned)
    | panel-config $in $preset.panel.placement $preset.panel.position
    | appearance-config $in $opacity
}

def saved-layout [] {
    let saved = (read-json (state-dir | path join bar-layout.json) {})
    let selection = ({name: main, opacity: solid} | merge $saved)
    $selection | update name (layout-name $selection.name)
}

def settings-path [] {
    ($env.XDG_STATE_HOME? | default ($env.HOME | path join .local/state)) | path join noctalia settings.toml
}

def read-settings [] {
    let path = (settings-path)
    if ($path | path exists) { open --raw $path | from toml } else { {} }
}

def save-settings [updated: record, selection: record, --offline] {
    let path = (settings-path)
    let existed = ($path | path exists)
    let original = if $existed { open --raw $path } else { '' }
    mkdir ($path | path dirname)
    let temporary = ($path + '.' + (random uuid) + '.toml')
    $updated | to toml | save $temporary
    let validation = (^noctalia config validate $temporary | complete)
    if $validation.exit_code != 0 {
        rm $temporary
        error make {msg: $"Invalid layout settings: ($validation.stderr)($validation.stdout)"}
    }
    mv --force $temporary $path
    if not $offline {
        let reload = (^noctalia msg config-reload | complete)
        if $reload.exit_code != 0 {
            if $existed { $original | save --force $path } else { rm $path }
            error make {msg: $"Could not reload Noctalia; settings restored: ($reload.stderr)($reload.stdout)"}
        }
    }
    write-json (state-dir | path join bar-layout.json) $selection
}

export def bar-layout [requested: string = 'pick'] {
    let previous = (saved-layout)
    let name = match $requested {
        migrate | refresh => { $previous.name }
        cycle => {
            let names = [main traditional]
            let index = (($names | enumerate | where item == $previous.name | get index.0) + 1) mod ($names | length)
            $names | get $index
        }
        pick => {
            let choice = (choose 'Desktop layout' ['Main · attached top bar + dock' 'Traditional · bottom taskbar + centered panels'])
            if $choice == null { return }
            if ($choice | str starts-with Main) { 'main' } else { 'traditional' }
        }
        _ => { layout-name $requested }
    }
    let updated = (layout-config (read-settings) $name $previous.opacity)
    save-settings $updated {name: $name, opacity: $previous.opacity} --offline=($requested == 'migrate')
}

export def panel-opacity [requested: string = 'pick'] {
    let previous = (saved-layout)
    let opacity = match $requested {
        toggle => { if $previous.opacity == 'solid' { 'soft' } else { 'solid' } }
        pick => {
            let choice = (choose 'Panel opacity' ['Solid · 100%' 'Translucent · 85% + blur'])
            if $choice == null { return }
            if ($choice | str starts-with Solid) { 'solid' } else { 'soft' }
        }
        _ => { $requested }
    }
    let settings = (read-settings)
    let updated = if 'bar' in $settings { appearance-config $settings $opacity } else { layout-config $settings $previous.name $opacity }
    save-settings $updated {name: $previous.name, opacity: $opacity}
}
