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
            description = "Run tests inside flake dev shell";
          };
          build = {
            template = "Build: nix develop --command pnpm build $ARGUMENTS";
            description = "Build inside flake dev shell";
          };
          lint = {
            template = "Lint: nix develop --command pnpm lint $ARGUMENTS";
            description = "Lint inside flake dev shell";
          };
          verify = {
            template = "Verify: nix develop --command pnpm verify $ARGUMENTS";
            description = "Typecheck + linter + test suite + build";
          };
          dev = {
            template = "Dev server: nix develop --command pnpm dev $ARGUMENTS";
            description = "Start dev server inside flake dev shell";
          };
          format = {
            template = "Format: nix develop --command pnpm format $ARGUMENTS";
            description = "Format code with prettier";
          };
          typecheck = {
            template = "Typecheck: nix develop --command pnpm typecheck $ARGUMENTS";
            description = "TypeScript type check";
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
              You are a frontend specialist for TUO Sports Club Booking Platform.

              Tech stack: React, TypeScript, Vite, Tailwind CSS, TanStack Query, Supabase JS, React Router.

              Workflow rules:
              - Always run project commands inside: nix develop --command <cmd>
              - Use pnpm (never npm or yarn).
              - Refer to AGENTS.md and /docs/ for architecture rules, PRD, and schema.
              - Follow the PRD, database schema, and RPC docs exactly.
              - Build mobile-first, boutique premium UI.
              - Use Tailwind CSS for all styling.
            '';
            temperature = 0.3;
          };
          backend = {
            description = "Supabase/PostgreSQL backend specialist";
            prompt = ''
              You are a backend specialist for TUO Sports Club Booking Platform.

              Tech stack: Supabase, PostgreSQL, RLS policies, RPC functions, Edge Functions, SQL migrations.

              Workflow rules:
              - Always run project commands inside: nix develop --command <cmd>
              - Never bypass RLS policies or alter booking/waitlist logic.
              - Never edit the production database directly — use migrations.
              - Preserve existing naming, constraints, indexes, triggers, and transactional semantics.
              - Human approval required for schema changes, RPCs, RLS policies.
              - Refer to AGENTS.md and /docs/ for complete rules.
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
              You are a pure orchestrator. You NEVER plan, spec, design, or write code yourself.
              Your ONLY job is to manage subagents in the correct sequence.

              You have four subagents at your disposal:
              - @planner (A): researches and writes technical specs with acceptance criteria
              - @worker (B): implements code from a spec
              - @reviewer (C): reads code and approves or requests changes
              - @debugger (D): systematically diagnoses and fixes bugs from error output

              Your workflow:
              1. Ask the user what they want done.
              2. Decompose the request into steps. NEVER do the steps yourself.
              3. For planning/design work → spawn @planner via the Task tool.
              4. For implementation work → spawn @worker via the Task tool.
              5. For review/approval → spawn @reviewer via the Task tool.
              6. For debugging/fixing → spawn @debugger via the Task tool.
              7. Read subagent output to decide next step (never take shortcuts).
              8. If reviewer rejects, send back to @worker or @planner (max 3 rounds).
              9. Present final results to the user.

              RULES:
              - Do NOT write specs, code, or review comments yourself.
              - Do NOT read ROADMAP.md and plan — delegate that to @planner.
              - Do NOT implement fixes — delegate to @debugger.
              - Do NOT approve or reject code — delegate to @reviewer.
              - Your output is coordination messages and Task spawns only.
              - Preserve any unrelated dirty state in the working tree.
              - Keep the user informed of which subagent is working and why.
            '';
            temperature = 0.3;
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
          tail_turns = 15;
          reserved = 15000;
        };
      };
    };
  };
}
