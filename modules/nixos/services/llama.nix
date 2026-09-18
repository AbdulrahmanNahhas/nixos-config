{
  lib,
  pkgs,
  username,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp.override { cudaSupport = true; };
  llama-server = lib.getExe' llama-cpp "llama-server";
  models = "/saved/models";
in
{
  # One OpenAI-compatible endpoint on :8080 that loads whichever model is
  # requested and unloads it after `ttl` seconds so the other can take the
  # 8 GiB of VRAM. Models are fetched by hand into ${models}.
  services.llama-swap = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 8080;
    settings = {
      healthCheckTimeout = 120;
      models = {
        qwen-main = {
          cmd = "${llama-server} -m ${models}/Qwen3.5-9B-Q4_K_M.gguf -ngl 99 -c 32768 --port \${PORT} --host 127.0.0.1 --no-webui";
          ttl = 600;
        };
        qwen-fast = {
          cmd = "${llama-server} -m ${models}/Qwen3.5-4B-Q4_K_M.gguf -ngl 99 -c 16384 --port \${PORT} --host 127.0.0.1 --no-webui";
          ttl = 300;
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${models} 0755 ${username} users -"
  ];

  environment.systemPackages = [
    llama-cpp
    pkgs.python3Packages.huggingface-hub
  ];
}
