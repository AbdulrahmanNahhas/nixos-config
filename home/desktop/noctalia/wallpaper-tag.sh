die() {
  printf 'wallpaper-tag: %s\n' "$*" >&2
  exit 1
}

action=${1:-}
kind=${2:-tag}
case "$action" in
  select|list) [[ "$kind" == tag || "$kind" == name ]] || die 'Expected tag or name' ;;
  next|previous|random|all|status) [[ $# == 1 ]] || die 'Expected one action' ;;
  *) die 'Usage: wallpaper-tag select|list [tag|name] | next|previous|random|all|status' ;;
esac
(( $# <= 2 )) || die 'Too many arguments'

directory=${WALLPAPER_DIRECTORY:-"$HOME/Pictures/Wallpapers"}
# This directory is already persisted; filters are saved only after a successful set.
state="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/wallpaper-tag"
[[ -d "$directory" ]] || die "Wallpaper directory does not exist: $directory"

declare -a images=() matches=() rows=() keys=()
declare -A counts=() membership=() labels=()
separator='[[:space:]]+-[[:space:]]+'
shopt -s nullglob dotglob extglob
trim() {
  local value=$1
  value=${value##+([[:space:]])}
  trimmed=${value%%+([[:space:]])}
}
index_field() {
  local type=$1 value key
  trim "$2"
  value=$trimmed
  [[ -n "$value" ]] || return 0
  key="$type:${value,,}"
  if [[ ! -v 'membership[$key:$index]' ]]; then
    membership["$key:$index"]=1
    counts["$key"]=$(( ${counts["$key"]:-0} + 1 ))
    labels["$key"]=$value
  fi
}

# Version sorting keeps 2 before 10, including non-padded sequence IDs.
mapfile -d '' -t files < <(printf '%s\0' "$directory"/* | sort -zVf)
for path in "${files[@]}"; do
  [[ -f "$path" ]] || continue
  case "${path,,}" in
    *.jpg|*.jpeg|*.png|*.webp|*.avif|*.gif) ;;
    *) continue ;;
  esac
  index=${#images[@]}
  images+=("$path")
  filename=${path##*/}
  remaining=${filename%.*}
  if [[ "$remaining" =~ $separator ]]; then
    delimiter=${BASH_REMATCH[0]}
    index_field name "${remaining%%"$delimiter"*}"
    remaining=${remaining#*"$delimiter"}
  else
    index_field name "$remaining"
    continue
  fi
  while :; do
    if [[ "$remaining" =~ $separator ]]; then
      delimiter=${BASH_REMATCH[0]}
      tag=${remaining%%"$delimiter"*}
      remaining=${remaining#*"$delimiter"}
      last=false
    else
      tag=$remaining
      last=true
    fi
    trim "$tag"
    tag=$trimmed
    [[ "$tag" =~ ^[0-9]+$ ]] || index_field tag "$tag"
    "$last" && break
  done
done

selected=all
if [[ -f "$state/filter" ]]; then
  selected=$(<"$state/filter")
elif [[ -f "$state/selected" ]]; then
  # Import the earlier mixed tag/name selection without discarding the user's choice.
  legacy=$(<"$state/selected")
  if [[ "$legacy" != all ]]; then
    selected="tag:${legacy,,}"
    [[ -v 'counts[$selected]' ]] || selected="name:${legacy,,}"
  fi
fi
if [[ "$action" == status ]]; then
  if [[ "$selected" == all ]]; then
    printf 'All wallpapers\n'
  else
    printf '%s: %s\n' "${selected%%:*}" "${labels["$selected"]:-${selected#*:}}"
  fi
  exit 0
fi

if [[ "$action" == select || "$action" == list ]]; then
  keys=(all)
  rows=("All wallpapers"$'\t'"${#images[@]} images")
  while IFS= read -r -d '' key; do
    [[ "$key" == "$kind:"* ]] || continue
    marker=''
    [[ "$key" != "$selected" ]] || marker=' · selected'
    keys+=("$key")
    rows+=("${labels["$key"]}"$'\t'"${counts["$key"]} images$marker")
  done < <(printf '%s\0' "${!counts[@]}" | sort -zf)
  if [[ "$selected" == all ]]; then
    rows[0]+=' · selected'
  fi
  if [[ "$action" == list ]]; then
    printf '%s\n' "${rows[@]}"
    exit 0
  fi
  rows+=('Back')
  if choice=$(printf '%s\n' "${rows[@]}" | noctalia dmenu -p "Wallpapers › Filter by $kind"); then
    [[ "$choice" != Back && -n "$choice" ]] || exit 0
  else
    status=$?
    [[ "$status" == 1 && -z "$choice" ]] && exit 0
    die "Noctalia picker failed (exit $status)"
  fi
  found=false
  for index in "${!keys[@]}"; do
    if [[ "$choice" == "${rows[index]}" ]]; then
      selected=${keys[index]}
      found=true
      break
    fi
  done
  "$found" || die 'Choose a filter from the list'
fi
[[ "$action" != all ]] || selected=all

for index in "${!images[@]}"; do
  if [[ "$selected" == all || -v 'membership[$selected:$index]' ]]; then
    matches+=("${images[index]}")
  fi
done
(( ${#matches[@]} > 0 )) || die "No wallpapers match: $selected"
current=$(noctalia msg wallpaper-get)
target=0
if [[ "$action" == next || "$action" == previous ]]; then
  [[ "$action" != previous ]] || target=$((${#matches[@]} - 1))
  for index in "${!matches[@]}"; do
    if [[ "${matches[index]}" == "$current" ]]; then
      step=1
      [[ "$action" != previous ]] || step=-1
      target=$(( (index + step + ${#matches[@]}) % ${#matches[@]} ))
      break
    fi
  done
elif [[ "$action" == random ]]; then
  alternatives=()
  for path in "${matches[@]}"; do
    [[ "$path" == "$current" ]] || alternatives+=("$path")
  done
  (( ${#alternatives[@]} == 0 )) || matches=("${alternatives[@]}")
  target=$(shuf -i "0-$((${#matches[@]} - 1))" -n 1)
fi
noctalia msg wallpaper-set "${matches[target]}"
mkdir -p "$state"
temporary=$(mktemp "$state/filter.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT
printf '%s\n' "$selected" > "$temporary"
mv -- "$temporary" "$state/filter"
