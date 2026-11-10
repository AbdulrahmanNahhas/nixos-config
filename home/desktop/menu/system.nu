use common.nu *

export def system-status [] {
    let batteries = (glob /sys/class/power_supply/BAT* | each {|p|
        let watts = if (($p | path join power_now) | path exists) {
            (open --raw ($p | path join power_now) | str trim | into float) / 1000000
        } else if (($p | path join current_now) | path exists) and (($p | path join voltage_now) | path exists) {
            (open --raw ($p | path join current_now) | str trim | into float) * (open --raw ($p | path join voltage_now) | str trim | into float) / 1000000000000
        } else { null }
        {battery: ($p | path basename), capacity: (open --raw ($p | path join capacity) | str trim), status: (open --raw ($p | path join status) | str trim), watts: $watts}
    })
    let gpus = (glob /sys/bus/pci/devices/*/vendor | where {|p| (open --raw $p | str trim) == '0x10de' } | each {|p|
        let device = ($p | path dirname)
        {device: ($device | path basename), runtime: (open --raw ($device | path join power/runtime_status) | str trim)}
    })
    {
        compositor: (compositor)
        running_system: (probe ['readlink' '-f' '/run/current-system'])
        boot_default: (probe ['readlink' '-f' '/nix/var/nix/profiles/system'])
        configuration: (probe ['git' '-C' '/saved/nixos-config' 'status' '--short'])
        failed_services: (probe ['systemctl' '--failed' '--no-legend' '--no-pager'])
        failed_user_services: (probe ['systemctl' '--user' '--failed' '--no-legend' '--no-pager'])
        storage: (probe ['df' '-h' '/nix' '/saved' '/home' '/tmp'])
        power_profile: (probe ['powerprofilesctl' 'get'])
        battery: $batteries
        nvidia_pci_functions: $gpus
        travel_saved: ((state-dir | path join travel.json) | path exists)
        nh: (probe ['nh' '--version'])
    }
}

export def --env nix-action [action: string, ...args: string] {
    let flake = '/saved/nixos-config'
    match $action {
        check => { ^nix flake check $flake ...$args }
        build => { ^nh os build $flake --ask ...$args }
        test => { ^nh os test $flake --ask ...$args }
        switch => { ^nh os switch $flake --ask ...$args }
        boot => { ^nh os boot $flake --ask ...$args }
        update => {
            print 'Updates flake.lock and builds. It does not activate the result.'
            if ((input 'Update inputs and build? [y/N] ' | str lowercase) != 'y') { $env.LAST_EXIT_CODE = 0; return }
            ^nh os build $flake --update --ask ...$args
        }
        input => {
            let name = if ($args | is-empty) { input 'Input to update: ' } else { $args.0 }
            let inputs = (open ($flake | path join flake.lock) | get nodes.root.inputs | columns)
            if $name not-in $inputs { error make {msg: 'Choose an input declared in flake.lock'} }
            print $"Updates ($name) in flake.lock and builds without activation."
            if ((input 'Continue? [y/N] ' | str lowercase) != 'y') { $env.LAST_EXIT_CODE = 0; return }
            ^nh os build $flake --update-input $name --ask ...($args | skip 1)
        }
        generations => { ^nh os info ...$args }
        rollback => { ^nh os rollback --ask ...$args }
        clean-preview => { ^nh clean all --dry --keep 5 --keep-since 14d --no-gcroots ...$args }
        clean => { ^nh clean all --ask --keep 5 --keep-since 14d --no-gcroots ...$args }
        search => { ^nh search packages ...$args }
        options => { ^nh search options ...$args }
        optimise => {
            if ((input 'Deduplicate store files? [y/N] ' | str lowercase) != 'y') { $env.LAST_EXIT_CODE = 0; return }
            ^sudo nix store optimise
        }
        _ => { error make {msg: $"Unknown NixOS action: ($action)"} }
    }
    if $env.LAST_EXIT_CODE != 0 { error make {msg: $"NixOS operation failed (exit ($env.LAST_EXIT_CODE))"} }
}
