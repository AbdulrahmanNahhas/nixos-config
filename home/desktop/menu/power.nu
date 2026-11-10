use common.nu *

export def displays [] {
    if (compositor) == 'niri' {
        ^niri msg --json outputs | from json | values | where current_mode != null | each {|o|
            let mode = ($o.modes | get $o.current_mode)
            {name: $o.name, mode: $"($mode.width)x($mode.height)@($mode.refresh_rate / 1000)", width: $mode.width, height: $mode.height, modes: ($o.modes | each {|m| {mode: $"($m.width)x($m.height)@($m.refresh_rate / 1000)", hz: ($m.refresh_rate / 1000), width: $m.width, height: $m.height}})}
        }
    } else {
        let result = (^wlr-randr --json | complete)
        if $result.exit_code != 0 { error make {msg: 'This session does not expose wlr-output-management; display controls are unavailable'} }
        $result.stdout | from json | where enabled == true | each {|o|
            let mode = ($o.modes | where current == true | first)
            {name: $o.name, mode: $"($mode.width)x($mode.height)@($mode.refresh / 1000)", width: $mode.width, height: $mode.height, modes: ($o.modes | each {|m| {mode: $"($m.width)x($m.height)@($m.refresh / 1000)", hz: ($m.refresh / 1000), width: $m.width, height: $m.height}})}
        }
    }
}

export def set-display [name: string, mode: string] {
    if (compositor) == 'niri' { ^niri msg output $name mode $mode } else { ^wlr-randr --output $name --mode $mode }
    if $env.LAST_EXIT_CODE != 0 { error make {msg: $"Could not change ($name) to ($mode)"} }
}

export def display-picker [] {
    let outputs = (displays)
    let selected = (choose 'Display' ($outputs | get name))
    if $selected == null { return }
    let output = ($outputs | where name == $selected | first)
    let mode = (choose $"($selected) · current ($output.mode)" ($output.modes | get mode | uniq))
    if $mode == null { return }
    set-display $selected $mode
    let keep = (try { (choose 'Keep display mode? Reverts in 15 seconds' ['Revert' 'Keep'] --timeout 15) == 'Keep' } catch {|error|
        set-display $selected $output.mode
        error make {msg: $error.msg}
    })
    if not $keep { set-display $selected $output.mode }
}

export def travel [action: string] {
    let path = (state-dir | path join travel.json)
    if $action == 'restore' {
        if not ($path | path exists) { error make {msg: 'No saved Travel mode settings'} }
        let saved = (read-json $path {})
        for output in $saved.outputs { set-display $output.name $output.mode }
        ^powerprofilesctl set $saved.profile
        if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Power profile restore failed; saved settings retained'} }
        ^brightnessctl --device $saved.backlight set ($saved.brightness | into string)
        if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Brightness restore failed; saved settings retained'} }
        rm $path
        print 'Previous display modes, brightness and power profile restored.'
        return
    }
    if $action != 'travel' { error make {msg: 'Expected travel or restore'} }
    if ($path | path exists) { error make {msg: 'Travel settings already saved. Restore before applying again.'} }
    let outputs = (displays)
    let internal = ($outputs | where {|o| $o.name | str starts-with 'eDP-' } | first)
    let mode = ($internal.modes | where {|m| $m.width == $internal.width and $m.height == $internal.height and $m.hz >= 59 and $m.hz <= 61 } | first)
    let backlight = (^brightnessctl --machine-readable info | str trim | split row ',' | first)
    let brightness = (^brightnessctl --device $backlight get | str trim | into int)
    let profile = (^powerprofilesctl get | str trim)
    # Save before applying so a partial failure still has a recovery path.
    write-json $path {outputs: ($outputs | select name mode), profile: $profile, brightness: $brightness, backlight: $backlight}
    set-display $internal.name $mode.mode
    ^powerprofilesctl set power-saver
    if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Power saver failed. Use shadow mode restore.'} }
    ^brightnessctl --device $backlight set 30%
    if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Brightness change failed. Use shadow mode restore.'} }
    print 'Travel: 60 Hz, power-saver, brightness 30%. Use shadow mode restore to undo.'
    print 'NVIDIA is not forcibly disabled. Check shadow status for runtime suspension.'
}

export def focus-mode [mode: string] {
    let path = (state-dir | path join focus.json)
    if $mode == 'restore' {
        if not ($path | path exists) { error make {msg: 'No saved Focus or Presentation settings'} }
        let saved = (read-json $path {})
        if $saved.presentation {
            let active = (^systemctl --user is-active shadow-presentation.service | complete)
            if $active.exit_code == 0 {
                ^systemctl --user stop shadow-presentation.service
                if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Could not release Presentation inhibitor; saved state retained'} }
            }
        }
        ^noctalia msg notification-dnd-set $saved.dnd
        if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Could not restore notifications; saved state retained'} }
        rm $path
        return
    }
    if $mode not-in [focus presentation] { error make {msg: 'Expected focus, presentation or restore'} }
    if ($path | path exists) { error make {msg: 'Restore the current Focus or Presentation mode first'} }
    let dnd = (^noctalia msg notification-dnd-status | str trim)
    if $dnd not-in [on off] { error make {msg: 'Cannot read notification state'} }
    write-json $path {dnd: $dnd, presentation: false}
    if $mode == 'presentation' {
        ^systemd-run --user --unit=shadow-presentation --collect systemd-inhibit --what=idle:sleep --who=Shadow --why=Presentation sleep infinity
        if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Could not start Presentation inhibitor. Restore saved mode before retrying.'} }
        write-json $path {dnd: $dnd, presentation: true}
    }
    ^noctalia msg notification-dnd-set on
    if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Could not silence notifications. Restore saved mode before retrying.'} }
}
