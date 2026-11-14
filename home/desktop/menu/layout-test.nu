# Run without a compositor: nu --no-config-file home/desktop/menu/layout-test.nu
use std/assert
use layout.nu [layout-config layout-name bar-layout resolve-pins]
use apps.nu applications

const BASE = path self ../noctalia/config.toml
const PRESETS = path self ../noctalia/layouts.toml

const PLUGIN_PANELS = [
    {id: 'avivbintangaringga/nix-monitor', entries: [panel]}
    {id: 'ycf/mawaqit', entries: [panel]}
    {id: 'noctalia/umbriel-companion', entries: [panel]}
    {id: 'noctalia/wallhaven', entries: [browser]}
    {id: 'alexander/screen-toolkit', entries: [panel result pick]}
]

def check-panels [config: record, placement: string, position: string] {
    for panel in [clipboard control_center launcher session wallpaper polkit] {
        assert equal ($config.shell.panel | get $"($panel)_placement") $placement
        assert equal ($config.shell.panel | get $"($panel)_position") $position
    }
    for panel in [clipboard control_center launcher session wallpaper] {
        assert equal ($config.shell.panel | get $"open_near_click_($panel)") false
    }
    for plugin in $PLUGIN_PANELS {
        let settings = ($config.plugin_settings | get $plugin.id)
        for entry in $plugin.entries {
            assert equal ($settings | get $"($entry)_placement") $placement
            assert equal ($settings | get $"($entry)_position") $position
            assert equal ($settings | get $"($entry)_open_near_click") false
        }
    }
}

def check-layouts [temporary: path] {
    let stale = {
        bar: {order: [default Utilities], Utilities: {position: right}}
        widget: {
            widget_2: {type: obsolete}
            volume: {show_label: true}
            clock: {tooltip_format: '{:%Y}', font_weight: 700, enabled: false}
            taskbar: {window_title_max_width: 222, icon_scale: 0.5}
            active_window: {display: title_only, min_length: 80}
            launcher: {scale: 0.5, custom_image: '/example/old.png', custom_image_colorize: false}
            umbriel_companion: {scale: 0.5}
        }
        wallpaper: {directory: '/example/wallpapers'}
        plugin_settings: {
            'noctalia/wallhaven': {api_key: 'test-only-placeholder', browser_position: top_center}
            'ycf/mawaqit': {city: 'Custom city', panel_open_near_click: true}
            'ashur-d/wallpaper-widget': {enabled: true}
        }
    }
    for name in [main traditional] {
        for opacity in [solid soft] {
            let config = (layout-config $stale $name $opacity)
            let main = ($name == 'main')
            check-panels $config (if $main { 'attached' } else { 'floating' }) (if $main { 'auto' } else { 'center' })
            assert equal $config.bar.order [default]
            assert equal $config.bar.default.position (if $main { 'top' } else { 'bottom' })
            assert equal $config.bar.default.shadow false
            assert equal $config.bar.default.concave_edge_corners (not $main)
            assert equal $config.bar.default.margin_edge 0
            assert equal $config.dock.enabled $main
            assert equal $config.dock.radius_bottom_left 0
            assert equal $config.dock.radius_bottom_right 0
            assert equal $config.dock.shadow false
            assert equal $config.widget.clock.enabled (not $main)
            assert equal $config.widget.active_window.display 'icon_only'
            assert equal $config.widget.active_window.min_length 0
            assert equal $config.widget.active_window.show_empty_label false
            assert equal $config.widget.launcher.custom_image '/home/aqua/Pictures/NixOS.png'
            assert equal $config.widget.launcher.custom_image_colorize true
            assert equal $config.widget.volume.show_label true
            assert equal $config.widget.clock.tooltip_format '{:%A, %d %B %Y}'
            assert equal $config.widget.clock.font_weight 700
            assert equal $config.widget.taskbar.window_title_max_width 222
            assert equal $config.desktop_widgets.grid.visible false
            assert equal $config.bar.default.background_opacity (if $opacity == 'solid' { 1.0 } else { 0.85 })
            assert equal $config.bar.default.compositor_blur ($opacity == 'soft')
            assert equal $config.wallpaper.directory '/example/wallpapers'
            assert equal $config.plugin_settings.'noctalia/wallhaven'.api_key 'test-only-placeholder'
            assert equal $config.plugin_settings.'ycf/mawaqit'.city 'Custom city'
            assert equal ($config.widget | get -o widget_2) null
            assert equal ($config.plugin_settings | get -o 'ashur-d/wallpaper-widget') null
            if $main {
                assert equal $config.bar.default.start ['group:main-app' workspaces]
                assert ('clock' not-in $config.bar.default.end)
                assert equal $config.bar.default.thickness 32
                assert equal $config.bar.default.capsule_group.0.members [launcher active_window]
                assert equal $config.bar.default.capsule_group.0.accordion false
                assert equal $config.bar.default.capsule_group.0.opacity 0.0
                assert equal $config.bar.default.capsule_group.0.padding 0.0
                assert equal $config.widget.taskbar.pinned $config.dock.pinned
                assert equal $config.widget.active_window.icon_size 18
                assert equal $config.widget.taskbar.icon_scale 1.0
                assert equal $config.widget.launcher.scale 1.0
                assert equal $config.widget.umbriel_companion.scale 1.0
            } else {
                assert equal $config.bar.default.start ['group:traditional-menu' taskbar]
                assert equal $config.bar.default.center [notifications]
                assert equal $config.bar.default.end [tray privacy volume network battery clock session]
                assert equal $config.bar.default.thickness 50
                assert equal $config.bar.default.scale 1.15
                assert equal $config.bar.default.capsule_group.0.members [launcher umbriel_companion]
                assert equal $config.bar.default.capsule_group.0.accordion true
                assert equal $config.bar.default.capsule_group.0.border_width 1.0
                assert equal $config.bar.default.capsule_group.0.padding 6.0
                assert equal $config.bar.default.capsule_group.0.radius 10.0
                assert equal $config.bar.default.capsule_group.0.opacity 1.0
                assert equal $config.widget.taskbar.pinned [firefox com.system76.CosmicFiles dev.zed.Zed com.mitchellh.ghostty codex-desktop whatsapp-web org.signal.Signal]
                assert equal $config.widget.clock.format '{:%H:%M}'
                assert equal $config.widget.taskbar.icon_scale 1.8
                assert equal $config.widget.launcher.scale 1.4
                assert equal $config.widget.umbriel_companion.scale 1.4
                assert equal $config.desktop_widgets.widget_order [desktop-weather desktop-calendar desktop-widget-0000000000000004]
                assert equal $config.widget.taskbar.show_window_title false
                assert equal $config.widget.taskbar.group_by_workspace false
            }
            assert equal (layout-config $config $name $opacity) $config
            let path = ($temporary | path join $"($name)-($opacity).toml")
            $config | to toml | save $path
            let validation = (^noctalia config validate $path | complete)
            assert equal $validation.exit_code 0 $"($validation.stdout)($validation.stderr)"
        }
    }
    let main = (layout-config $stale main)
    let traditional = (layout-config $main traditional)
    let restored = (layout-config $traditional main)
    assert equal $restored.bar $main.bar
    assert equal $restored.widget.clock $main.widget.clock
    assert equal $restored.widget.active_window $main.widget.active_window
    assert equal $restored.widget.taskbar $main.widget.taskbar
    assert equal $restored.widget.launcher $main.widget.launcher
    assert equal $restored.widget.umbriel_companion $main.widget.umbriel_companion
    assert equal $restored.desktop_widgets.widget_order $main.desktop_widgets.widget_order
    check-panels $restored attached auto

    for alias in [gnome bottom right] {
        let expected = if $alias == 'bottom' { 'traditional' } else { 'main' }
        assert equal (layout-name $alias) $expected
        assert equal (layout-config {} $alias) (layout-config {} $expected)
        let state = ($temporary | path join $alias)
        mkdir ($state | path join noctalia shadow)
        {name: $alias, opacity: soft} | to json | save ($state | path join noctalia shadow bar-layout.json)
        with-env {XDG_STATE_HOME: $state} { bar-layout migrate }
        let saved = (open ($state | path join noctalia shadow bar-layout.json))
        assert equal $saved {name: $expected, opacity: soft}
    }
    let rejected = (try { layout-name unsupported; false } catch { true })
    assert $rejected
}

def helper-script [path: path, body: string] {
    $"#!/bin/sh\n($body)\n" | save --force $path
    ^chmod +x $path
}

def check-native-pins [temporary: path] {
    let pins = [firefox whatsapp-web org.signal.Signal]
    assert equal (resolve-pins $pins) $pins
    let native = 'firefox.webapp-7b76e1f3-a250-44ed-a39d-5327946cb1ba'
    let applications = ($env.XDG_DATA_HOME | path join applications)
    mkdir $applications
    let profile = ($env.XDG_CONFIG_HOME | path join mozilla firefox default)
    let entry = ($applications | path join $"($native).desktop")
    let command = $'Exec="firefox" "-taskbar-tab" "7b76e1f3-a250-44ed-a39d-5327946cb1ba" "-new-window" "https://web.whatsapp.com" "-profile" "($profile)" "-container" "0"'
    $command | str replace 'web.whatsapp.com' 'web.whatsapp.com.invalid' | save $entry
    assert equal (resolve-pins $pins) $pins
    $command | str replace $profile ($profile | path dirname | path join whatsapp) | save --force $entry
    assert equal (resolve-pins $pins) $pins
    $command | save --force $entry
    assert equal (resolve-pins $pins) [firefox $native org.signal.Signal]
    assert equal (resolve-pins [whatsapp-web $native org.signal.Signal]) [$native org.signal.Signal]
    let old = 'firefox.webapp-00000000-0000-4000-8000-000000000000'
    $command | str replace $profile ($profile | path dirname | path join whatsapp) | save ($applications | path join $"($old).desktop")
    assert equal (resolve-pins $pins) [firefox $native org.signal.Signal]
    let rows = ([whatsapp-web $native $old firefox] | each {|id|
        [$"($id).desktop" $id 'Fixture application' whatsapp whatsapp]
        | each {|value| $value | encode base64 } | str join (char tab)
    } | str join (char nl))
    helper-script ($temporary | path join bin shadow-apps) $"printf '%s\\n' '($rows)'"
    with-env {XDG_STATE_HOME: ($temporary | path join menu-state)} {
        assert equal (applications | get id | sort) ['app:firefox.desktop' 'app:whatsapp-web.desktop']
    }
    for name in [main traditional] {
        let state = ($temporary | path join $"refresh-($name)")
        mkdir ($state | path join noctalia shadow)
        let selection = {name: $name, opacity: soft}
        $selection | to json | save ($state | path join noctalia shadow bar-layout.json)
        with-env {XDG_STATE_HOME: $state} { bar-layout refresh }
        assert equal (open ($state | path join noctalia shadow bar-layout.json)) $selection
        let updated = (open --raw ($state | path join noctalia settings.toml) | from toml)
        assert equal $updated.bar.default.background_opacity 0.85
        if $name == 'traditional' {
            assert equal $updated.widget.taskbar.pinned [firefox com.system76.CosmicFiles dev.zed.Zed com.mitchellh.ghostty codex-desktop $native org.signal.Signal]
        } else {
            assert equal $updated.widget.taskbar.pinned $updated.dock.pinned
        }
    }
    assert equal (open --raw $env.LAYOUT_TEST_RELOAD_LOG | lines | length) 2
}

def main [] {
    let real_noctalia = (which noctalia | first | get path)
    let temporary = (^mktemp -d | str trim)
    try {
        let bin = ($temporary | path join bin)
        mkdir $bin

        helper-script ($bin | path join noctalia) 'if [ "$1" = msg ] && [ "$2" = config-reload ]; then
    printf "%s\n" reload >> "$LAYOUT_TEST_RELOAD_LOG"
    exit 0
fi
exec "$LAYOUT_TEST_NOCTALIA" "$@"'
        with-env {
            SHADOW_NOCTALIA_BASE: $BASE
            SHADOW_NOCTALIA_LAYOUTS: $PRESETS
            PATH: ($env.PATH | prepend $bin)
            XDG_DATA_HOME: ($temporary | path join data)
            XDG_CONFIG_HOME: ($temporary | path join config)
            LAYOUT_TEST_NOCTALIA: $real_noctalia
            LAYOUT_TEST_RELOAD_LOG: ($temporary | path join reload.log)
        } {
            check-layouts $temporary
            check-native-pins $temporary
        }
    } catch {|error|
        rm -r $temporary
        error make {msg: $error.msg}
    }
    rm -r $temporary
    print 'Layout tests passed: presets, opacity, panel placement, preservation, migration and native-app pin refresh.'
}
