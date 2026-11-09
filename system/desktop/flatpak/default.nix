{ lib, pkgs, ... }:
let
  apps = import ./apps.nix;
  policy = import ./policy.nix { inherit lib; };
in
{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub-verified";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        args = "--subset=verified";
      }
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "flathub-beta";
        location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
      {
        name = "nahhasio-alpha";
        # Pin the repository descriptor and signing key; app updates follow alpha.
        location = "${pkgs.fetchurl {
          url = "https://github.com/AbdulrahmanNahhas/nahhasio/releases/download/nahhasio-v0.1.1/nahhasio.flatpakrepo";
          sha256 = "4bbbc3e053aae2f7eb1bb649ecf5a1ed1b83e04115ff8b18dbb707bc142b50e3";
        }}";
      }
    ];
    packages = lib.mapAttrsToList (
      appId: app:
      {
        appId = app.ref or appId;
        origin = app.origin or "flathub-verified";
      }
      // lib.optionalAttrs (app ? flatpakref) {
        inherit (app) flatpakref sha256;
      }
    ) apps;
    update = {
      # Reconcile installed versions on rebuild as well as the daily timer.
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
    uninstallUnmanaged = true;
    uninstallUnused = true;
    # Back off when a remote is unavailable.
    restartOnFailure = {
      restartDelay = "5min";
      exponentialBackoff = {
        enable = true;
        steps = 4;
        maxDelay = "1h";
      };
    };
    overrides = {
      # Managed system overrides replace manual edits; user overrides are separate.
      writeMode = "replace";
      pruneUnmanagedOverrides = true;
      settings = lib.mapAttrs (_: policy.appOverrides) apps // {
        global = policy.global;
      };
    };
  };

  # Keep background reconciliation from competing with interactive workloads.
  systemd.services.flatpak-managed-install-timer.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };
  systemd.timers.flatpak-managed-install-timer.timerConfig.RandomizedDelaySec = "1h";
}
