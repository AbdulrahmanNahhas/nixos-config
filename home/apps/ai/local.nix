{
  lib,
  pkgs,
  ...
}:
let
  llama-server = lib.getExe' pkgs.llama-cpp-cuda "llama-server";
  models = "/saved/models";

  # Load models on demand; unload after ttl. --jinja enables tool templates.
  # Chat UI: /upstream/<model>/.
  settings = {
    healthCheckTimeout = 120;
    models = {
      # Fit 32k context in 8 GiB VRAM with q8 KV cache; sleep the GPU after unload.
      qwen-main = {
        cmd = "${llama-server} -m ${models}/Qwen3.5-9B-Q4_K_M.gguf -ngl 99 -c 32768 -fa on -ctk q8_0 -ctv q8_0 --jinja --port \${PORT} --host 127.0.0.1";
        ttl = 600;
      };
    };
  };
  config = (pkgs.formats.yaml { }).generate "llama-swap.yaml" settings;
  zedModel = name: display: ctx: {
    inherit name;
    display_name = display;
    max_tokens = ctx;
    capabilities = {
      tools = true;
      images = false;
      parallel_tool_calls = false;
      prompt_cache_key = false;
    };
  };
in
{
  home.packages = [
    pkgs.llama-cpp-cuda
    pkgs.python3Packages.huggingface-hub # `hf download` into ${models}
  ];

  systemd.user.tmpfiles.rules = [ "d ${models} 0755 - - -" ];

  # Started by hand (`ai on`); nothing runs, and no GPU wakes, until then.
  systemd.user.services.llama-swap = {
    Unit.Description = "llama-swap model router";
    Service = {
      ExecStart = "${lib.getExe pkgs.llama-swap} -config ${config} -listen 127.0.0.1:8080";
      Restart = "on-failure";
    };
  };

  programs.fish.functions.ai = ''
    switch $argv[1]
      case on
        systemctl --user start llama-swap
      case off
        systemctl --user stop llama-swap
      case unload
        curl -s http://127.0.0.1:8080/unload >/dev/null; and echo "Models unloaded."
      case status
        systemctl --user is-active llama-swap
        curl -s http://127.0.0.1:8080/running 2>/dev/null; and echo
      case chat
        xdg-open http://127.0.0.1:8080/upstream/qwen-main/
      case logs
        journalctl --user -u llama-swap -f
      case '*'
        echo "Usage: ai on|off|chat|unload|status|logs"
    end
  '';

  # Select Zed’s Local provider; llama-swap accepts any API-key value.
  programs.zed-editor.userSettings.language_models.openai_compatible.Local = {
    api_url = "http://127.0.0.1:8080/v1";
    available_models = [
      (zedModel "qwen-main" "Qwen3.5 9B" 32768)
    ];
  };
}
