const BASE = path self ../noctalia/config.toml

export def applications [] {
    let base = (open --raw ($env.SHADOW_NOCTALIA_BASE? | default $BASE) | from toml)
    let path = (($env.XDG_STATE_HOME? | default ($env.HOME | path join .local/state)) | path join noctalia settings.toml)
    let overrides = if ($path | path exists) { open --raw $path | from toml } else { {} }
    let pinned = ($overrides | get -o shell.launcher.pinned | default $base.shell.launcher.pinned | each {|id| $id | str replace --regex '\.desktop$' '' })
    let result = (^shadow-apps list | complete)
    if $result.exit_code != 0 { error make {msg: $result.stderr} }
    $result.stdout | lines | where $it != '' | each {|line|
        let fields = ($line | split row (char tab) | each {|value| $value | decode base64 | decode utf-8 })
        let desktop = $fields.0
        let pin = ($pinned | enumerate | where item == ($desktop | str replace --regex '\.desktop$' '') | get -o index.0 | default 100000)
        {
            id: $"app:($desktop)", group: applications, label: $fields.1,
            description: ((if $pin < 100000 { 'Pinned · ' } else { '' }) + $fields.2),
            kind: application, args: [$desktop], terminal: false, confirm: false,
            icon: $"theme:($fields.3)", keywords: $fields.4, pin: $pin
        }
    } | sort-by pin label
}
