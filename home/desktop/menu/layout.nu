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

export def layout-config [settings: record, name: string, opacity: string = 'solid'] {
    let base = (open --raw ($env.SHADOW_NOCTALIA_BASE? | default $BASE) | from toml)
    let presets = (open --raw ($env.SHADOW_NOCTALIA_LAYOUTS? | default $PRESETS) | from toml)
    if $name not-in [bottom gnome right] { error make {msg: $"Unknown bar layout: ($name)"} }
    let preset = ($presets | get $name)
    let desktop_widgets = (
        ($settings | get -o desktop_widgets | default {})
        | merge deep $base.desktop_widgets
        | merge deep (if $name == 'bottom' { {} } else { $presets.defaults.desktop_widgets })
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
    | upsert widget.umbriel_companion $base.widget.umbriel_companion
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
        | merge ($presets.gnome.dock)
        | merge {enabled: ($name == 'gnome')}
    }
    | appearance-config $in $opacity
}

def saved-layout [] {
    let saved = (read-json (state-dir | path join bar-layout.json) {})
    {name: bottom, opacity: solid} | merge $saved
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
        error make {msg: $"Invalid bar settings: ($validation.stderr)($validation.stdout)"}
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
        migrate => { $previous.name }
        cycle => {
            let names = [bottom gnome right]
            let index = (($names | enumerate | where item == $previous.name | get index.0) + 1) mod 3
            $names | get $index
        }
        pick => {
            let choice = (choose 'Bar layout' ['Bottom bar' 'GNOME · top bar + dock' 'Right sidebar'])
            if $choice == null { return }
            if $choice == 'Bottom bar' { 'bottom' } else if ($choice | str starts-with GNOME) { 'gnome' } else { 'right' }
        }
        _ => { $requested }
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
