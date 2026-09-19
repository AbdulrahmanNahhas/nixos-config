{
  lib,
  pkgs,
  ...
}:
let
  llama-server = lib.getExe' pkgs.llama-cpp-cuda "llama-server";
  models = "/saved/models";

  # One OpenAI-compatible endpoint that loads the requested model on demand,
  # unloads it after `ttl` seconds, and serves llama.cpp's chat UI at
  # /upstream/<model>/. `--jinja` enables the native tool-call template.
  settings = {
    healthCheckTimeout = 120;
    models = {
      # q8 KV cache keeps 32k context inside the 8 GiB of VRAM. The dGPU wakes
      # on load and sleeps again after the ttl unload.
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

  # Zed's agent panel: pick "Local" as the provider. It asks for an API key
  # once; any value works, llama-swap ignores it.
  programs.zed-editor.userSettings.language_models.openai_compatible.Local = {
    api_url = "http://127.0.0.1:8080/v1";
    available_models = [
      (zedModel "qwen-main" "Qwen3.5 9B" 32768)
    ];
  };
}
