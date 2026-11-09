{ pkgs, ... }:
let
  secret = pkgs.writeShellApplication {
    name = "secret";
    runtimeInputs = [
      pkgs.sops
      pkgs.coreutils
      pkgs.findutils
      pkgs.systemd
    ];
    text = ''
      root=/saved/nixos-config
      cd "$root"
      action="''${1:-list}"
      if [ "$action" = list ]; then
        find encrypted-secrets -maxdepth 1 -type f -name '*.enc' -printf '%f\n' | sort
        exit 0
      fi
      name="''${2:-}"
      name="''${name%.enc}"
      if [[ ! "$name" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
        echo "Use a secret name without spaces or path separators." >&2
        exit 2
      fi
      target="encrypted-secrets/$name.enc"
      case "$action" in
        edit) exec sops --input-type binary --output-type binary "$target" ;;
        status) exec sops filestatus "$target" ;;
        add|add-token)
          if [ -e "$target" ]; then
            echo "Already exists; use secret edit $name." >&2
            exit 1
          fi
          umask 077
          temporary=$(mktemp encrypted-secrets/.ciphertext.XXXXXX)
          trap 'rm -f "$temporary"' EXIT
          if [ "$action" = add ]; then
            source=$(realpath -- "''${3:?Usage: secret add name /private/path/file}")
            case "$source" in
              "$root"/*) echo "Keep plaintext outside this repository." >&2; exit 2 ;;
            esac
            sops encrypt --filename-override "$target" --input-type binary --output-type binary --output "$temporary" "$source"
          else
            systemd-ask-password "New secret: $name" | tr -d '\n' | sops encrypt \
              --filename-override "$target" --input-type binary --output-type binary --output "$temporary" /dev/stdin
          fi
          # Atomic no-clobber publication; another writer must never lose a secret.
          chmod 644 "$temporary"
          ln "$temporary" "$target"
          echo "Created ciphertext at $target. Declare its consumer before deployment."
          ;;
        *) echo "Usage: secret list|status|edit|add|add-token [name] [private-file]" >&2; exit 2 ;;
      esac
    '';
  };
in
{
  home.packages = [ secret ];
}
