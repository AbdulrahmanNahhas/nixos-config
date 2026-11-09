{ pkgs, ... }:
{
  # Opt in local compiler processes without constraining the editor/terminal.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "build-run";
      runtimeInputs = [ pkgs.systemd ];
      text = ''
        if [ "$#" -eq 0 ]; then
          echo "Usage: build-run COMMAND [ARG...]" >&2
          exit 2
        fi
        exec systemd-run --user --scope --collect --slice=build.slice -- "$@"
      '';
    })
  ];

  systemd.user.slices.build = {
    Unit.Description = "Local compiler workloads";
    Slice = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
  };

  programs.devenv = {
    enable = true;
    enableFishIntegration = true;
  };

  # Zed loads direnv directly; native devenv owns terminal activation.
  programs.direnv = {
    enable = true;
    enableFishIntegration = false;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableNushellIntegration = false;
    nix-direnv.enable = false;
  };

  # Shadow Fish’s vendor hook with conf.d; devenv owns terminal activation.
  xdg.configFile."fish/conf.d/direnv.fish".text = ''
    # Native devenv owns terminal activation; Zed invokes direnv directly.
  '';
}
