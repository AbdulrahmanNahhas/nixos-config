let
  lock = builtins.fromJSON (builtins.readFile ../../../../flake.lock);
  source = fetchTree lock.nodes.nixpkgs.locked;
  pkgs = import source.outPath { system = builtins.currentSystem; };
  quest = pkgs.writeShellScriptBin "menu-quest" ''
    exec cargo run --quiet --offline --manifest-path "${toString ./.}/Cargo.toml" -- "$@"
  '';
in
pkgs.mkShell {
  packages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer
    quest
  ];
}
