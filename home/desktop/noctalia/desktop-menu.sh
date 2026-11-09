# One action catalog backs both submenus and cross-category search.
declare -a ids=() groups=() titles=()
add() {
  ids+=("$1"); groups+=("$2"); titles+=("$3")
}
add wallpaper-name wallpapers 'Filter by Name'
add wallpaper-tag wallpapers 'Filter by Tag'
add wallpaper-all wallpapers 'All Wallpapers'
add wallpaper-next wallpapers 'Next Wallpaper'
add wallpaper-previous wallpapers 'Previous Wallpaper'
add wallpaper-browse wallpapers 'Browse Wallpapers'
add theme appearance 'Toggle Light / Dark'
add settings appearance 'Noctalia Settings'
add check nix 'Check Configuration'
add build nix 'Build System'
add test nix 'Test Configuration'
add switch nix 'Switch Configuration'
add update nix 'Update Flake'
add packages nix 'Search Packages'
add edit nix 'Edit Configuration'
add clean nix 'Clean Old Generations'
add mute audio 'Mute / Unmute'
add quieter audio 'Volume Down'
add louder audio 'Volume Up'
add volume audio 'Set Volume'
add performance power 'Performance Profile'
add balanced power 'Balanced Profile'
add saver power 'Power Saver Profile'
add lock power 'Lock Screen'
add region capture 'Capture Region'
add window capture 'Capture Window'
add fullscreen capture 'Capture Fullscreen'
add clipboard tools 'Clipboard History'
add terminal tools 'Open Terminal'
add files tools 'Open Files'
add close tools 'Close Active Window'

pick() {
  local prompt=$1 choice status index
  shift
  if choice=$(printf '%s\n' "$@" | noctalia dmenu -p "$prompt"); then
    for index in "${!rows[@]}"; do
      if [[ "$choice" == "${rows[index]}" ]]; then
        printf '%s\n' "${choices[index]}"
        return 0
      fi
    done
    # Unmatched typed text is only a search, never a shell command.
    [[ -z "$choice" ]] || printf 'search:%s\n' "$choice"
    return 0
  else
    status=$?
    [[ "$status" == 1 ]] || printf 'desktop-menu: picker failed (exit %s)\n' "$status" >&2
    return "$status"
  fi
}

menu=${1:-root}
case "$menu" in
  root|search|wallpapers|appearance|nix|audio|power|capture|tools) ;;
  *) printf 'Usage: desktop-menu [root|search|wallpapers|appearance|nix|audio|power|capture|tools]\n' >&2; exit 1 ;;
esac
query=''
while :; do
  rows=(); choices=()
  if [[ "$menu" == root ]]; then
    rows=('Wallpapers ›' 'Search All Actions' 'Appearance ›' 'NixOS ›' 'Audio ›' 'Power ›' 'Capture ›' 'Tools ›')
    choices=(menu:wallpapers menu:search menu:appearance menu:nix menu:audio menu:power menu:capture menu:tools)
    prompt='Desktop · choose a category or type an action'
  else
    case "$menu" in
      search) title='All Actions' ;;
      wallpapers) title="Wallpapers · $(wallpaper-tag status)" ;;
      nix) title=NixOS ;;
      *) title=${menu^} ;;
    esac
    prompt="Desktop › $title"
    [[ -z "$query" ]] || prompt="Desktop › Search: $query"
    for index in "${!ids[@]}"; do
      [[ "$menu" == search || "${groups[index]}" == "$menu" ]] || continue
      searchable="${titles[index]} ${groups[index]}"
      [[ -z "$query" || "${searchable,,}" == *"${query,,}"* ]] || continue
      row=${titles[index]}
      [[ "$menu" != search ]] || row+=$'\t'"${groups[index]}"
      rows+=("$row"); choices+=("${ids[index]}")
    done
    rows+=('Back'); choices+=(back)
  fi
  # A unique typed action runs directly; ambiguous searches present their matches.
  if [[ -n "$query" && ${#choices[@]} == 2 ]]; then
    choice=${choices[0]}
  elif ! choice=$(pick "$prompt" "${rows[@]}"); then
    [[ "$menu" != root ]] || exit 0
    menu=root; query=''; continue
  fi
  case "$choice" in
    menu:*) menu=${choice#menu:}; query=''; continue ;;
    back) menu=root; query=''; continue ;;
    search:*) menu=search; query=${choice#search:}; continue ;;
    '') continue ;;
    wallpaper-name) wallpaper-tag select name ;;
    wallpaper-tag) wallpaper-tag select tag ;;
    wallpaper-all) wallpaper-tag all ;;
    wallpaper-next) wallpaper-tag next ;;
    wallpaper-previous) wallpaper-tag previous ;;
    wallpaper-browse) exec noctalia msg panel-toggle wallpaper ;;
    theme) noctalia msg theme-mode-toggle ;;
    check|build|test|switch|update|packages|clean)
      case "$choice" in
        check) command=sys-check ;; build) command=sys-build ;;
        test) command=sys-test ;; switch) command=sys-switch ;;
        update) command=sys-update ;; packages) command=sys-search ;;
        clean) command=sys-clean ;;
      esac
      exec ghostty -e fish -lc "$command; exec fish"
      ;;
    edit) exec zeditor /saved/nixos-config ;;
    mute) noctalia msg volume-mute ;;
    quieter) noctalia msg volume-down ;;
    louder) noctalia msg volume-up ;;
    volume)
      rows=('25%' '50%' '75%' '100%' '125%' '150%' 'Back')
      choices=('25%' '50%' '75%' '100%' '125%' '150%' back)
      if level=$(pick 'Desktop › Audio › Volume' "${rows[@]}"); then
        case "$level" in
          25%|50%|75%|100%|125%|150%) noctalia msg volume-set "$level" ;;
        esac
      fi
      ;;
    performance) noctalia msg power-set performance ;;
    balanced) noctalia msg power-set balanced ;;
    saver) noctalia msg power-set power-saver ;;
    lock) exec noctalia msg session lock ;;
    region) exec noctalia msg screenshot-region ;;
    window) exec noctalia msg screenshot-window ;;
    fullscreen) exec noctalia msg screenshot-fullscreen ;;
    clipboard) exec noctalia msg panel-toggle clipboard ;;
    terminal) exec ghostty ;;
    files) exec ghostty -e yazi ;;
    close) exec niri msg action close-window ;;
    settings) exec noctalia msg settings-open ;;
  esac
  query=''
done
