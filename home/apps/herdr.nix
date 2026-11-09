{ pkgs, ... }:
{
  home.packages = [
    # TODO(temporary): remove when Herdr declares zstd for the Cargo hook.
    (pkgs.herdr-desktop.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.zstd ];
    }))
    pkgs.herdr-core
  ];

  # Disable app telemetry without freezing its mutable settings file.
  # https://github.com/herdrdev/herdr-app/blob/master/docs/security.md
  home.sessionVariables.HERDR_TELEMETRY = "0";
  systemd.user.sessionVariables.HERDR_TELEMETRY = "0";
}
