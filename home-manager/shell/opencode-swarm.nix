{ config, lib, pkgs, ... }:
{
  # DISABLED 2026-07-04: Swarm plugin dropped in favor of native opencode orchestrator.
  # The multi-agent review loop is now handled entirely via opencode's built-in
  # agent/subagent system (orchestrator/planner/worker/reviewer/debugger).
  #
  # Keep this file for reference — the swarm plugin provided Hive, Hivemind, and Swarm Mail,
  # but its agent spawning mechanism was unreliable. Native Task-based delegation is simpler.
  #
  # To re-enable, uncomment the import in home.nix and restore the logic below.
}
