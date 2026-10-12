# Zed configuration

Home Manager owns extensions, language settings, language servers, keymaps and
global editor/agent defaults through the neighboring Nix modules. Project-specific
tool versions and configuration belong in each project's development environment.

JavaScript and TypeScript prefer workspace Oxc/Oxfmt and TypeScript tooling. Use
`source.fixAll.oxc` for safe save actions; keep broad `quickfix` automation disabled.
TOML uses Tombi. Hugo templates in this repository are recognized through
`.zed/settings.json`; Go HTML Template autoformat is disabled to preserve syntax.

Agent provider/model defaults are declared once in `settings.nix`. Subscription
authentication, account sessions and credentials are managed in the running
application and retained state, never committed to this repository. Declaring a
model or provider does not verify account access. Edit predictions are disabled.

Apply these settings through Home Manager/NixOS activation. A successful build
checks configuration generation, not editor behavior or provider authentication.
