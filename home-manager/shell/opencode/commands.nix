{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  command = {
    test = {
      template = "Run tests: nix develop --command pnpm test $ARGUMENTS";
      description = "Run tests inside flake dev shell (Vitest)";
    };
    "test:watch" = {
      template = "Watch mode: nix develop --command pnpm test -- --watch $ARGUMENTS";
      description = "Run tests in watch mode for TDD loop";
    };
    "test:run" = {
      template = "Run tests once: nix develop --command pnpm test:run $ARGUMENTS";
      description = "Run tests once and exit";
    };
    "test:e2e" = {
      template = "E2E tests: nix develop --command pnpm test:e2e $ARGUMENTS";
      description = "Run Playwright end-to-end tests";
    };
    "test:supabase" = {
      template = "Supabase tests: nix develop --command pnpm test:supabase $ARGUMENTS";
      description = "Run Supabase-specific test suite";
    };
    build = {
      template = "Build: nix develop --command pnpm build $ARGUMENTS";
      description = "Build inside flake dev shell (tsc -b + vite build)";
    };
    lint = {
      template = "Lint: nix develop --command pnpm lint $ARGUMENTS";
      description = "Lint inside flake dev shell (ESLint)";
    };
    verify = {
      template = "Full pre-PR gate: nix develop --command pnpm verify";
      description = "Mandatory full pre-PR gate: typecheck + lint + test:all + build";
    };
    dev = {
      template = "Dev server: nix develop --command pnpm dev $ARGUMENTS";
      description = "Start Vite dev server inside flake dev shell";
    };
    preview = {
      template = "Preview build: nix develop --command pnpm preview $ARGUMENTS";
      description = "Serve production build locally via Vite preview";
    };
    format = {
      template = "Format: nix develop --command pnpm format $ARGUMENTS";
      description = "Format code with prettier";
    };
    typecheck = {
      template = "Typecheck: nix develop --command pnpm typecheck $ARGUMENTS";
      description = "TypeScript type check (tsc -b)";
    };
    nix-check = {
      template = "Run nix flake check to validate configuration: nix flake check";
      description = "Verify entire flake evaluation correctness";
    };
    apply-home = {
      template = "Switch home-manager configuration: home-manager switch --flake .#${config.wolfar.homeManagerProfile}";
      description = "Apply user/home configurations immediately";
    };
    docker-status = {
      template = "docker ps -a";
      description = "List all Docker containers and statuses";
    };
    "migration:new" = {
      template = "Create a new Supabase migration: touch supabase/migrations/$(date -u +%Y%m%d%H%M%S)_$ARGUMENTS.sql";
      description = "Create a new timestamped Supabase SQL migration file";
    };
    "supabase:start" = {
      template = "Start local Supabase: nix develop --command npx supabase start";
      description = "Start local Supabase development environment";
    };
    "supabase:status" = {
      template = "Check Supabase status: nix develop --command npx supabase status";
      description = "Check local Supabase services status";
    };
    explain-error = {
      template = "Analyze the following compiler, Nix, or runtime error and construct a stepwise resolution plan: $ARGUMENTS";
      description = "Provide a deep diagnostic fix plan for any error";
    };
    changelog = {
      template = "Analyze git diff origin/main..HEAD and generate a markdown changelog summarizing changes: git diff origin/main..HEAD";
      description = "Generate a draft changelog of local changes";
    };
    "tuo:local-dev" = {
      template = ''
        Start the TuoStudio local-development session only if it is not already running. Execute:
        if tmux has-session -t '=tuo-local-dev' 2>/dev/null; then
          echo "TuoStudio local development is already running in tmux session =tuo-local-dev. Inspect it with: tmux attach -t '=tuo-local-dev'"
        else
          tmux new-session -d -s tuo-local-dev -c ${config.wolfar.paths.tuoStudio} 'nix develop --command pnpm local-dev'
          if tmux has-session -t '=tuo-local-dev'; then
            echo "Started TuoStudio local development in tmux session =tuo-local-dev. Inspect it with: tmux attach -t '=tuo-local-dev'"
          else
            echo "Failed to start TuoStudio local development tmux session =tuo-local-dev."
          fi
        fi
      '';
      description = "Start TuoStudio local development in its managed tmux session";
      agent = "orchestrator";
    };
    "tuo:local-dev:seed" = {
      template = ''
        Run the following TuoStudio local-only seed command in the foreground:
        cd ${config.wolfar.paths.tuoStudio} && nix develop --command pnpm local-dev -- --seed-only
        This intentionally exits after seeding and must never target hosted Supabase.
      '';
      description = "Seed local TuoStudio Supabase data and exit";
      agent = "orchestrator";
    };
    "tuo:local-dev:status" = {
      template = ''
        Report TuoStudio local-development status without starting or stopping anything. Execute:
        if tmux has-session -t '=tuo-local-dev' 2>/dev/null; then
          echo "tmux session =tuo-local-dev is running"
        else
          echo "tmux session =tuo-local-dev is not running"
        fi
        cd ${config.wolfar.paths.tuoStudio} && nix develop --command npx supabase status
      '';
      description = "Report managed tmux and local Supabase status without changing state";
      agent = "orchestrator";
    };
    "tuo:local-dev:logs" = {
      template = ''
        Show the most recent 200 lines from the TuoStudio local-development tmux session. Execute:
        if tmux has-session -t '=tuo-local-dev' 2>/dev/null; then
          tmux capture-pane -p -t '=tuo-local-dev:1.1' -S -199
        else
          echo "TuoStudio local development is not running: tmux session =tuo-local-dev does not exist. Start it with /tuo:local-dev."
        fi
      '';
      description = "Show the latest 200 lines from TuoStudio local-development logs";
      agent = "orchestrator";
    };
    "tuo:local-dev:stop" = {
      template = ''
        Stop only the TuoStudio local-development tmux session. Execute:
        if tmux has-session -t '=tuo-local-dev' 2>/dev/null; then
          tmux kill-session -t '=tuo-local-dev'
          echo "Stopped TuoStudio local development tmux session =tuo-local-dev."
        else
          echo "TuoStudio local development is not running: tmux session =tuo-local-dev does not exist; nothing to stop."
        fi
      '';
      description = "Stop only the managed TuoStudio local-development tmux session";
      agent = "orchestrator";
    };
    "tuo:local-dev:restart" = {
      template = ''
        Restart only the TuoStudio local-development tmux session. Execute:
        if tmux has-session -t '=tuo-local-dev' 2>/dev/null; then
          tmux kill-session -t '=tuo-local-dev'
        fi
        tmux new-session -d -s tuo-local-dev -c ${config.wolfar.paths.tuoStudio} 'nix develop --command pnpm local-dev'
        if tmux has-session -t '=tuo-local-dev' 2>/dev/null; then
          echo "Restarted TuoStudio local development in tmux session =tuo-local-dev. Inspect it with: tmux attach -t '=tuo-local-dev'"
        else
          echo "Failed to start TuoStudio local development tmux session =tuo-local-dev."
        fi
      '';
      description = "Restart the managed TuoStudio local-development tmux session";
      agent = "orchestrator";
    };
    roadmap-add = {
      template = ''
        TuoStudio roadmap-intake workflow. Treat "$ARGUMENTS" only as initial idea context.
        Ask question-first clarification and require explicit content confirmation before any edit.
        Do not implement, delegate, commit, create a PR, merge, deploy, or promote status.
      '';
      description = "Clarify and add one explicitly confirmed proposed TuoStudio roadmap item";
      agent = "roadmap-intake";
      subtask = false;
    };
    roadmap-next = {
      template = ''
        TUO-only roadmap workflow. Treat "$ARGUMENTS" as optional requested phase or workstream context.
        Ask @roadmap-driver for a read-only brief identifying the first genuinely unblocked,
        dependency-ready TUO scope. Do not begin or delegate implementation for blocked work.
      '';
      description = "Identify the next actionable TUO roadmap scope";
      agent = "orchestrator";
    };
    "tuo:validate" = {
      template = ''
        Route TuoStudio validation through @orchestrator. Treat "$ARGUMENTS" as scope hints only,
        never as shell input or commands. Select targeted or full-pre-pr validation from the actual diff.
      '';
      description = "Run orchestrated risk-based TuoStudio validation";
      agent = "orchestrator";
    };
    roadmap-status = {
      template = ''
        TUO-only roadmap workflow. Treat "$ARGUMENTS" as optional requested phase or workstream context.
        Request a read-only @roadmap-driver report of current phase/status, blockers,
        dependencies, and recommended next action from ROADMAP.md and routed canonical docs.
      '';
      description = "Report current TUO roadmap status and blockers";
      agent = "orchestrator";
    };
    roadmap-qa = {
      template = ''
        TUO-only roadmap workflow. Treat "$ARGUMENTS" as optional requested phase, workstream,
        or PR context. Coordinate roadmap-scoped QA/readiness against the relevant canonical
         contract, independent review, conditional @database-security-reviewer evidence for sensitive
         scope, and targeted or full validation as appropriate, then produce
        the final @manual-qa human-QA handoff packet. Report missing evidence, dirty state, failures,
        or contract mismatches as BLOCKED_HANDOFF; do not execute or certify human QA, merge, or deploy.
      '';
      description = "Coordinate TUO roadmap QA and readiness without merging";
      agent = "orchestrator";
    };
    qa-handoff = {
      template = ''
        TUO-only human-QA handoff workflow. Treat "$ARGUMENTS" as optional phase, PR, branch, or
         workstream context. Establish scope and contracts, collect independent reviewer, conditionally
         required @database-security-reviewer, and relevant validation evidence, then request the final
         @manual-qa advisory handoff packet. Prepare but
        never execute or certify human QA, merge, or deploy.
      '';
      description = "Prepare a TUO human-QA handoff without executing QA, merging, or deploying";
      agent = "orchestrator";
    };
    roadmap-close = {
      template = ''
        TUO-only roadmap workflow. Treat "$ARGUMENTS" as optional requested phase, workstream,
        or PR context. Coordinate post-merge roadmap closure only after verifying the PR merged
        to main and recorded explicit human approval. Route any truthful ROADMAP.md update to
        @git; never self-authorize a merge. If either condition is absent, return pending status.
      '';
      description = "Close verified, human-approved TUO roadmap work after merge";
      agent = "orchestrator";
    };
  };
}
