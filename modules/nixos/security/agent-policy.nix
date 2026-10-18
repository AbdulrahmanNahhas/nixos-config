{ pkgs, username, ... }:
let
  toml = pkgs.formats.toml { };
  home = "/home/${username}";
  credentialPaths = [
    ".ssh"
    ".gnupg"
    ".aws"
    ".azure"
    ".kube"
    ".netrc"
    ".npmrc"
    ".pypirc"
    ".config/sops"
    ".config/gh"
    ".config/gcloud"
    ".config/rclone"
    ".config/BraveSoftware"
    ".config/Codex"
    ".docker/config.json"
    ".cargo/credentials.toml"
    ".cargo/credentials"
    ".local/share/keyrings"
    ".local/share/opencode/auth.json"
    ".codex/auth.json"
    ".codex/config.toml"
  ];
in
{
  # A system policy survives mutable app settings and cannot be weakened by a
  # repository's config. It governs supported agent execution, not arbitrary
  # native processes, MCP services, or code later run in an ordinary terminal.
  environment.etc."codex/requirements.toml".source = toml.generate "agent-requirements.toml" {
    default_permissions = ":workspace";
    allowed_permission_profiles = {
      ":read-only" = true;
      ":workspace" = true;
    };
    # The installed CLI still exposes --sandbox as a legacy selector. Constrain
    # that entry point as well as the modern permission-profile selector.
    allowed_sandbox_modes = [
      "read-only"
      "workspace-write"
    ];
    permissions.filesystem.deny_read =
      map (path: "${home}/${path}") credentialPaths
      ++ map (path: "/saved${home}/${path}") credentialPaths
      ++ [
        "/saved/secrets"
        "/saved/var/lib/sops-nix"
        # /run/secrets is a symlink; deny its real backing parent so the
        # sandbox masks the target without trying to mount over a symlink.
        "/run/secrets.d"
        "/etc/NetworkManager/system-connections"
        "/saved/etc/NetworkManager/system-connections"
        "/var/lib/iwd"
        "/saved/var/lib/iwd"
      ];
  };
}
