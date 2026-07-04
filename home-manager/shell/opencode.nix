{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.wolfar.opencode;
  skillFiles = {
    "opencode/skills/supabase-migration-review/SKILL.md".source =
      ./opencode-skills/supabase-migration-review/SKILL.md;
    "opencode/skills/supabase-client-patterns/SKILL.md".source =
      ./opencode-skills/supabase-client-patterns/SKILL.md;
    "opencode/skills/ux-feature-implementation/SKILL.md".source =
      ./opencode-skills/ux-feature-implementation/SKILL.md;
    "opencode/skills/form-ux-review/SKILL.md".source = ./opencode-skills/form-ux-review/SKILL.md;
    "opencode/skills/github-pr-review/SKILL.md".source = ./opencode-skills/github-pr-review/SKILL.md;
    "opencode/skills/frontend-qa-review/SKILL.md".source =
      ./opencode-skills/frontend-qa-review/SKILL.md;
    "opencode/skills/vercel-release-debugging/SKILL.md".source =
      ./opencode-skills/vercel-release-debugging/SKILL.md;
    "opencode/skills/multi-agent-review/SKILL.md".source =
      ./opencode-skills/multi-agent-review/SKILL.md;
  };
in
{
  options.wolfar.opencode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable opencode.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.opencode.packages.x86_64-linux.default;
      defaultText = lib.literalExpression "inputs.opencode.packages.x86_64-linux.default";
      description = "opencode package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = skillFiles // {
      "opencode/opencode.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        default_agent = "build";
        autoupdate = "notify";
        instructions = [ "AGENTS.md" ];

        permission = {
          bash = {
            "nix develop *" = "allow";
            "git status" = "allow";
            "git diff" = "allow";
            "git diff *" = "allow";
            "git log" = "allow";
            "git log *" = "allow";
            "git add *" = "allow";
            "git commit *" = "allow";
            "git push" = "allow";
            "git push *" = "allow";
            "gh *" = "allow";
            "home-manager switch *" = "allow";
            "nix build *" = "allow";
            "sudo *" = "deny";
            "rm -rf /" = "deny";
            "rm -rf /*" = "deny";
            "rm -rf ~" = "deny";
            "rm -rf ~/*" = "deny";
            "*" = "ask";
          };
          edit = "ask";
          read = {
            ".env" = "allow";
            ".env.*" = "allow";
            "*" = "allow";
          };
        };

        formatter = {
          prettier = {
            command = [
              "nix"
              "develop"
              "--command"
              "npx"
              "prettier"
              "--write"
              "$FILE"
            ];
            extensions = [
              ".js"
              ".jsx"
              ".ts"
              ".tsx"
              ".json"
              ".css"
              ".md"
            ];
          };
          nixfmt = {
            command = [
              "nixfmt"
              "$FILE"
            ];
            extensions = [ ".nix" ];
          };
        };

        lsp = true;

        references = {
          nixos = {
            path = "./nixos";
            description = "NixOS system-level configuration modules";
          };
          hm = {
            path = "./home-manager";
            description = "Home Manager user-level configuration modules";
          };
          nixvim = {
            path = "./home-manager/nixvim";
            description = "NixVim configurations for Neovim";
          };
          desktop = {
            path = "./home-manager/desktop";
            description = "Desktop environment (Hyprland, Waybar, wofi, theme, services)";
          };
          opencode = {
            path = "~/.config/opencode";
            description = "OpenCode configuration directory (skills, plugins, commands)";
          };
          tuo-studio = {
            path = "/home/wolfar/TuoStudio";
            description = "TUO Sports Club Booking Platform — React/TypeScript/Tailwind + Supabase";
          };
          tuo-docs = {
            path = "/home/wolfar/TuoStudio/docs";
            description = "PRD, database schema, RPC docs, deployment checklists for TuoStudio";
          };
        };

        skills = {
          paths = [
            ".opencode/skills"
            "~/.config/opencode/skills"
          ];
          # Load Supabase-maintained agent skills alongside local and global skills.
          urls = [ "https://supabase.com/.well-known/agent-skills/" ];
        };

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
            template = "Verify: nix develop --command pnpm verify $ARGUMENTS";
            description = "Full pre-merge: typecheck + lint + test:all + build";
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
            template = "Switch home-manager configuration: home-manager switch --flake .#wolfar@nixos";
            description = "Apply user/home configurations immediately";
          };
          docker-status = {
            template = "docker ps -a";
            description = "List all Docker containers and statuses";
          };
          "migration:new" = {
            template = "Create a new Supabase migration: touch supabase/migrations/$(date -u +%%Y%%m%%d%%H%%M%%S)_$ARGUMENTS.sql";
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
        };

        mcp = {
          vercel = {
            type = "remote";
            url = "https://mcp.vercel.com";
            enabled = true;
          };
          supabase = {
            type = "remote";
            url = "https://mcp.supabase.com/mcp";
            enabled = true;
          };
          github = {
            type = "local";
            command = [
              "npx"
              "-y"
              "@modelcontextprotocol/server-github"
            ];
            enabled = true;
          };
        };

        agent = {
          nix-specialist = {
            description = "NixOS & Home Manager configuration specialist";
            prompt = ''
              You are a NixOS and Home Manager configuration specialist for the wolfar-nix-config repository.

              Your core mandates:
              1. All configuration is declarative and must live in this repository. Never run imperative install commands.
              2. No manual edits in ~/.config/ - use Home Manager.
              3. For system changes (under nixos/), ask the user before running rebuild.
              4. For user changes (under home-manager/), you can run home-manager switch --flake .#wolfar@nixos directly.
              5. Always validate system changes first with: nix build .#nixosConfigurations.nixos.config.system.build.toplevel

              When editing Nix files:
              - Follow the style of existing files.
              - Use nixfmt for formatting.
              - Keep comments concise and focused on the 'why'.
            '';
            temperature = 0.2;
          };
          frontend = {
            description = "React/TypeScript/Tailwind/Supabase frontend specialist";
            prompt = ''
              You are a frontend specialist for TUO Sports Club Booking Platform at ~/TuoStudio.

              TECH STACK:
              - React 19 with TypeScript 5.8 (strict mode)
              - Vite 6 as bundler, build via: nix develop --command pnpm build
              - Tailwind CSS 3.4 — use Tailwind classes for ALL styling (no CSS modules or styled-components)
              - TanStack React Query 5.76 — use v5 patterns (status field, no more success/error booleans)
              - React Router 7 — route-based with loaders/actions pattern
              - Supabase JS client 2.49 (typed via generated types)
              - Packages: clsx, lucide-react icons
              - Vitest (unit/integration) + @testing-library/react + Playwright (e2e)
              - TypeScript project references (tsconfig.app.json / tsconfig.test.json / tsconfig.node.json)

              PROJECT LOCATION: /home/wolfar/TuoStudio
              Always run project commands inside: nix develop --command <cmd>
              Use pnpm (never npm or yarn).

              ARCHITECTURE:
              - src/ — main app code
                - app/ — app-wide setup, providers, wrappers
                - components/ — shared/reusable UI components
                - features/ — feature modules (booking, admin, schedule, etc.)
                - hooks/ — custom React hooks
                - layouts/ — page layout components
                - lib/ — utilities, constants, client instances
                - routes/ — route definitions
                - services/ — API/Supabase service layers
                - types/ — TypeScript type definitions
                - test/ — test utilities and setup
              - supabase/ — database
                - migrations/ — timestamped SQL migrations
                - seed.sql — seed data
                - config.toml — Supabase config
              - docs/ — PRD, schema, RPC documentation (source of truth)

              WORKFLOW RULES:
              - Refer to AGENTS.md and @tuo-docs for architecture rules, PRD, and schema.
              - Follow the PRD, database schema, and RPC docs exactly.
              - Build mobile-first, boutique premium UI. Premium = clean spacing, restrained palette, good typography.
              - Use Tailwind CSS for all styling — no CSS modules, no styled-components.
              - Prefer simple, explicit code over early abstractions.
              - For RLS-restricted data, use Supabase service layer calls — never raw SQL from the frontend.
              - When changing types, update the generated Supabase types if needed.
              - TSC build mode: use `tsc -b` (project references), not `tsc --noEmit`.
              - Before committing, verify with: nix develop --command pnpm verify
            '';
            temperature = 0.5;
          };
          backend = {
            description = "Supabase/PostgreSQL backend specialist";
            prompt = ''
              You are a backend specialist for TUO Sports Club Booking Platform at ~/TuoStudio.

              TECH STACK:
              - Supabase (PostgreSQL) with RLS policies, RPC functions, triggers
              - SQL migrations in supabase/migrations/ (timestamped: YYYYMMDDHHMMSS_name.sql)
              - Supabase Edge Functions (Deno/TypeScript)
              - Supabase JS client from frontend (never raw SQL from client)
              - Bootstrap scripts in scripts/ for local dev data setup

              PROJECT LOCATION: /home/wolfar/TuoStudio
              Always run project commands inside: nix develop --command <cmd>
              Use pnpm (never npm or yarn).

              MIGRATION CONVENTIONS:
              - Each migration has a unique timestamp prefix: YYYYMMDDHHMMSS_description.sql
              - Use: migration:new command to create new migration files
              - Migrations are applied to local Supabase first, then deployed via Supabase MCP

              KEY DOCS (source of truth in /docs/):
              - tuo_sports_club_booking_platform_prd_v_1.md — product requirements
              - tuo_sports_club_database_schema_v_1.md — full schema documentation
              - tuo_sports_club_database_views_v_1.sql — database views
              - tuo_sports_club_booking_rpc_migration_v_1.sql — booking RPC contracts
              - tuo_sports_club_admin_rpc_migration_v_1.sql — admin RPC contracts

              WORKFLOW RULES:
              - Never bypass RLS policies or alter booking/waitlist logic.
              - Never edit the production database directly — use migrations.
              - Preserve existing naming, constraints, indexes, triggers, and transactional semantics.
              - Human approval required for schema changes, RPCs, RLS policies.
              - Refer to AGENTS.md and @tuo-docs for complete rules.
              - Use @tuo-docs reference to read PRD, schema, and RPC docs for context.
              - When creating RPCs, follow existing patterns in the RPC doc files.
              - Seed data in seed.sql should be maintained alongside schema changes.
            '';
            temperature = 0.2;
          };
          reviewer = {
            description = "Read-only code reviewer — approves or requests changes in multi-agent review loop";
            prompt = ''
              You are the reviewer subagent in a multi-agent review workflow.

              Review the implementation against the spec. Check for:
              - Spec compliance: does the implementation match what was specified?
              - Security: any vulnerabilities introduced?
              - Correctness: does the code work correctly?
              - Maintainability: is the code clean and well-structured?
              - Edge cases: are error states and edge cases handled?

              Return a decision:
              - approve: implementation meets the spec, no issues.
              - request_changes: list specific issues that must be fixed.

              Do not modify any files.
            '';
            tools = {
              write = false;
              edit = false;
              patch = false;
            };
            temperature = 0.1;
          };
          orchestrator = {
            description = "Pure coordinator — delegates all work to subagents, never plans or codes";
            mode = "primary";
            model = "openai/gpt-5.4";
            prompt = ''
              You are a pure orchestrator for wolfar-nix-config AND TuoStudio (TUO Sports Club Booking Platform).
              You NEVER plan, spec, design, or write code yourself.
              Your ONLY job is to manage subagents in the correct sequence.

              You have four subagents at your disposal:
              - @planner (A): researches and writes technical specs with acceptance criteria
              - @worker (B): implements code from a spec
              - @reviewer (C): reads code and approves or requests changes
              - @debugger (D): systematically diagnoses and fixes bugs from error output

              Additionally, project-specific agents available for direct delegation:
              - @frontend: React/TypeScript/Tailwind/Supabase frontend work
              - @backend: Supabase/PostgreSQL/RPC/migration work
              - @nix-specialist: NixOS/Home Manager configuration changes

              Your workflow:
              1. Ask the user what they want done.
              2. Decompose the request into steps. NEVER do the steps yourself.
              3. For planning/design work → spawn @planner via the Task tool.
              4. For implementation work with clear spec → spawn @worker via the Task tool.
              5. For frontend-only work → consider delegating to @frontend agent.
              6. For backend/database work → consider delegating to @backend agent.
              7. For Nix config changes → consider delegating to @nix-specialist agent.
              8. For review/approval → spawn @reviewer via the Task tool.
              9. For debugging/fixing → spawn @debugger via the Task tool.
              10. Read subagent output to decide next step (never take shortcuts).
              11. If reviewer rejects, send back to @worker or @planner (max 3 rounds).
              12. Present final results to the user.

              TUOSTUDIO PROJECT RULES (from ROADMAP.md):
              - Human approval REQUIRED for: Supabase migrations, RPC functions, RLS policies, booking/waitlist logic changes.
              - NEVER combine database and UI work in one task — keep them separate.
              - NEVER combine admin and public website work in the same task.
              - All work runs inside `nix develop` using `pnpm` (not npm or yarn).
              - Follow the PRD and database schema docs exactly — they are the source of truth.
              - Work incrementally with small, reviewable tasks.
              - Build backend behavior in Supabase migrations and RPC functions, not frontend logic.
              - Never bypass RLS or manually edit production data.
              - Keep UX mobile-first, premium, restrained, and boutique.

              RULES:
              - Do NOT write specs, code, or review comments yourself.
              - Do NOT read ROADMAP.md and plan — delegate that to @planner.
              - Do NOT implement fixes — delegate to @debugger.
              - Do NOT approve or reject code — delegate to @reviewer.
              - Your output is coordination messages and Task spawns only.
              - Preserve any unrelated dirty state in the working tree.
              - Keep the user informed of which subagent is working and why.
            '';
            temperature = 0.2;
          };
          planner = {
            description = "Researches and writes technical specs with acceptance criteria — never codes";
            mode = "subagent";
            model = "openai/gpt-5.4";
            prompt = ''
              You are the planner subagent. You research, design, and write specs — you do NOT write code.

              Your workflow:
              1. Read any provided brief, requirements, or error description carefully.
              2. Research the codebase: read relevant files, understand architecture, check existing patterns.
              3. Write a detailed technical spec including:
                 - Problem statement and context
                 - Proposed solution with rationale
                 - Files to be modified and how
                 - Acceptance criteria (what "done" looks like)
                 - Edge cases to handle
                 - Test expectations
              4. Output the spec to .agent/<session>/spec.md.
              5. If the orchestrator sends you review feedback, revise the spec and output the updated version.

              Do NOT edit any source code files. Your output is documentation and specs only.
              Be specific, precise, and thorough. Include edge cases and test expectations.
            '';
            tools = {
              write = false;
              edit = false;
              patch = false;
            };
            temperature = 0.7;
          };
          debugger = {
            description = "Systematically diagnoses and fixes bugs from error output, logs, and crash reports";
            mode = "subagent";
            model = "openai/gpt-5.4";
            prompt = ''
              You are the debugger subagent. Your job is to diagnose and fix bugs.

              Given an error message, crash log, test failure, or bug description:
              1. REPRODUCE — understand what the code is supposed to do vs what it actually does.
              2. ISOLATE — trace the error to the root cause. Read relevant source files, check recent changes.
              3. DIAGNOSE — identify the underlying issue (logic error, race condition, API misuse, type mismatch, etc.).
              4. FIX — apply the minimal, correct fix. Prefer targeted changes over rewrites.
              5. VERIFY — confirm the fix addresses the root cause and doesn't break related functionality.

              Guidelines:
              - Read error output carefully — stack traces tell you exactly where to look.
              - Check git log for recent changes that may have introduced the bug.
              - Make the smallest possible fix. One bug = one change.
              - Add comments explaining WHY the fix works if the logic is subtle.
              - After fixing, summarize: root cause, fix applied, what was verified.
              - Do not refactor unrelated code or add features during a debug session.
            '';
            temperature = 0.2;
          };
          worker = {
            description = "Implements code from specifications in the multi-agent review loop";
            mode = "subagent";
            model = "openai/gpt-5.4-mini";
            prompt = ''
              You are the worker subagent in a multi-agent review workflow.

              Implement exactly what is specified. Follow the spec precisely — do not add features or refactor unrelated code.
              Write tests where the project has a test harness.

              When done, summarize:
              - What files were changed/created
              - Any deviations from the spec (and why)
              - Test results

              Do not mark the task approved.
            '';
            temperature = 0.3;
          };
        };

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
      };
    };
  };
}
