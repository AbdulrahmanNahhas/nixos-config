use common.nu *

def library [] {
    let directory = ($env.WALLPAPER_DIRECTORY? | default ($env.HOME | path join Pictures Wallpapers))
    if not ($directory | path exists) { error make {msg: $"Wallpaper directory missing: ($directory)"} }
    glob ($directory | path join '*') | where {|p| ($p | path type) == 'file' and ($p | path parse | get extension | str lowercase) in [jpg jpeg png webp avif gif] } | sort --natural | each {|p|
        let fields = ($p | path parse | get stem | split row ' - ' | str trim)
        {path: $p, name: $fields.0, tags: ($fields | skip 1 | where {|t| $t !~ '^\d+$' } | str lowercase)}
    }
}

def filter-path [] {
    let base = ($env.XDG_STATE_HOME? | default ($env.HOME | path join '.local/state'))
    $base | path join noctalia wallpaper-tag filter
}

def current-filter [] {
    let path = (filter-path)
    if ($path | path exists) { open --raw $path | str trim } else { 'all' }
}

def apply-wallpaper [target: string, filter: string] {
    let previous = (^noctalia msg wallpaper-get | str trim)
    ^noctalia msg wallpaper-set $target
    if $env.LAST_EXIT_CODE != 0 { error make {msg: 'Wallpaper did not apply; filter and history were not changed'} }
    mkdir (filter-path | path dirname)
    $filter | save --force (filter-path)
    let history_path = (state-dir | path join wallpapers.json)
    let history = (read-json $history_path [])
    let next = ($history | where {|p| $p != $previous and $p != $target } | append $previous | append $target | last 100)
    write-json $history_path $next
}

export def wallpaper-action [action: string, kind: string = 'tag'] {
    if $action == 'status' { return (current-filter) }
    if $action == 'picker' { ^noctalia msg panel-open wallpaper; return }
    let images = (library)
    if ($images | is-empty) { error make {msg: 'No images found'} }
    mut filter = (current-filter)
    if $action in [select list] {
        if $kind not-in [tag name] { error make {msg: 'Expected tag or name'} }
        let values = if $kind == 'tag' { $images | get tags | flatten | uniq | sort } else { $images | get name | uniq | sort --natural }
        let rows = (['All wallpapers'] | append $values)
        if $action == 'list' { return ($rows | str join (char nl)) }
        let selected = (choose $"Filter by ($kind)" $rows)
        if $selected == null { return }
        $filter = if $selected == 'All wallpapers' { 'all' } else { $"($kind):($selected | str lowercase)" }
    }
    if $action == 'all' { $filter = 'all' }
    if $action == 'history' {
        let history = (read-json (state-dir | path join wallpapers.json) [] | reverse | where {|p| $p | path exists })
        if ($history | is-empty) { error make {msg: 'History starts when wallpapers are changed through this menu'} }
        let selected = (choose 'Wallpaper history' $history)
        if $selected != null { apply-wallpaper $selected $filter }
        return
    }
    let parts = ($filter | split row ':')
    let matches = if $filter == 'all' { $images } else {
        let value = ($parts | skip 1 | str join ':')
        $images | where {|image| if $parts.0 == 'name' { ($image.name | str lowercase) == $value } else { $value in $image.tags } }
    }
    if ($matches | is-empty) { error make {msg: $"No images match ($filter); choose another filter"} }
    let paths = ($matches | get path)
    let current = (^noctalia msg wallpaper-get | str trim)
    let index = ($paths | enumerate | where item == $current | get index | get -o 0 | default (-1))
    let target = match $action {
        next => { $paths | get (($index + 1) mod ($paths | length)) }
        previous => { if $index == -1 { $paths | last } else { $paths | get (($index - 1 + ($paths | length)) mod ($paths | length)) } }
        random => {
            let bag_path = (state-dir | path join shuffle.json)
            let saved = (read-json $bag_path {filter: '', remaining: []})
            mut bag = if $saved.filter == $filter { $saved.remaining | where {|p| $p in $paths and $p != $current } } else { [] }
            if ($bag | is-empty) { $bag = ($paths | where {|p| $p != $current } | shuffle) }
            if ($bag | is-empty) { $bag = $paths }
            let target = $bag.0
            apply-wallpaper $target $filter
            write-json $bag_path {filter: $filter, remaining: ($bag | skip 1)}
            return
        }
        all | select => { $paths.0 }
        _ => { error make {msg: $"Unknown wallpaper action: ($action)"} }
    }
    apply-wallpaper $target $filter
}
