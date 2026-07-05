{ ... }:
{
  # ── Add-ons (force-installed via enterprise policy) ───────────────────────
  programs.firefox.policies.ExtensionSettings = {
    # uBlock Origin
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
