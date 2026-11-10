use catalog.nu actions
use apps.nu applications
use common.nu confirm
use menu.nu desktop-menu
use actions.nu run-action
use system.nu *
use power.nu [travel focus-mode]
use wallpaper.nu wallpaper-action
use layout.nu [bar-layout panel-opacity]

export def --wrapped main [...args: string] {
    if ($args.0? in ['--help' '-h']) or ($args.1? in ['--help' '-h']) {
        print 'shadow menu [category]         Actions + applications; use category applications for the grid'
        print 'shadow status [--json]         Running system, battery, GPU and storage summary'
        print 'shadow actions                 Action catalog as JSON'
        print 'shadow nix ACTION [ARGS]       check/build/test/switch/boot/update/input/generations/rollback/clean-preview/clean/search/options/optimise'
        print 'shadow layout [NAME]           bottom/gnome/right/cycle; omit NAME for picker'
        print 'shadow opacity [MODE]          solid/soft/toggle; omit MODE for picker'
        print 'shadow mode NAME               travel/restore/focus/presentation/focus-restore'
        print 'shadow wallpaper ACTION [KIND] picker/status/list/select/all/next/previous/random/history'
        print 'shadow run ID                  Run an action by its stable catalog ID'
        return
    }
    let command = ($args.0? | default 'menu')
    let rest = ($args | skip 1)
    match $command {
        menu => { desktop-menu ($rest.0? | default 'root') }
        status => {
            let result = (system-status)
            if '--json' in $rest { $result | to json } else { $result | table --expand }
        }
        actions => { actions | append (applications) | to json }
        nix => { nix-action ($rest.0? | default 'generations') ...($rest | skip 1) }
        mode => {
            let mode = ($rest.0? | default 'travel')
            if $mode in [focus presentation focus-restore] {
                focus-mode (if $mode == 'focus-restore' { 'restore' } else { $mode })
            } else { travel $mode }
        }
        opacity => { panel-opacity ($rest.0? | default 'pick') }
        layout => { bar-layout ($rest.0? | default 'pick') }
        wallpaper => { wallpaper-action ($rest.0? | default 'status') ($rest.1? | default 'tag') }
        run => {
            if ($rest.0 | str starts-with 'app:') { run-action $rest.0; return }
            let action = (actions | where id == $rest.0 | first)
            if not $action.confirm or (confirm $action.description) { run-action $action.id }
        }
        terminal => {
            let failed = (try { run-action $rest.0 | table --expand; false } catch {|error| print --stderr $error.msg; true })
            input 'Press Enter to close.' | ignore
            if $failed { exit 1 }
        }
        _ => { error make {msg: 'Usage: shadow [menu [category] | status [--json] | actions | nix ACTION | mode travel/restore | wallpaper ACTION | run ID]'} }
    }
}
