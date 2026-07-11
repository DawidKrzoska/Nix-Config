{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  "$schema" = "https://opencode.ai/config.json";
  default_agent = "orchestrator";
  autoupdate = "notify";
  instructions = [ "AGENTS.md" ];
  lsp = true;

  tool_output = {
    max_lines = 300;
    max_bytes = 16384;
  };

  compaction = {
    auto = true;
    prune = true;
    tail_turns = 20;
    reserved = 25000;
  };
}
