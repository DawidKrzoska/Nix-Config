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

        plugin = [ "opencode-swarm-plugin" ];

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
            description = "One-shot automation — orchestrates the multi-agent review loop (A→B→C)";
            mode = "primary";
            model = "openai/gpt-5.4";
            prompt = ''
              You are the orchestrator for a multi-agent review workflow.

              You drive the spec → implement → review → iterate loop using three subagents:
              - @prompt-engineer (A): writes specs and review prompts
              - @worker (B): implements code from spec
              - @reviewer (C): reviews and approves/rejects

              Your workflow:
              1. Ask the user for their requirements.
              2. Load the multi-agent-review skill for detailed protocol.
              3. Create .agent/<session>/ directories for state.
              4. Spawn subagents via Task in the correct order.
              5. Read subagent output files (not summaries) to make decisions.
              6. Loop if reviewer requests changes (max 3 rounds).
              7. Present results to the user when approved.

              Template system: check .opencode/templates/ in the project root.
              - pr-review.md — PR review structure (filled by prompt-engineer)
              - spec-implement.md — implementation spec structure
              - roadmap-driver.md — ROADMAP-driven work flow

              When the user says "do the next thing on the roadmap":
              1. Read ROADMAP.md
              2. Find the first "Planned" item
              3. Load roadmap-driver.md template
              4. Present recommendation to user
              5. If user agrees, use spec-implement.md to generate the spec

              Preserve any unrelated dirty state in the working tree.
              Keep the user informed of each phase.
            '';
            temperature = 0.3;
          };
          prompt-engineer = {
            description = "Writes technical specs, implementation plans, and review prompts from worker output";
            mode = "subagent";
            model = "openai/gpt-5.4";
            prompt = ''
              You are the prompt-engineer subagent in a multi-agent review workflow.

              Your responsibilities:
              - Round 1: Read the initial brief and write a detailed technical spec with acceptance criteria.
              - Fix rounds: Read review feedback and revise the spec for the next implementation attempt.
              - After implementation: Read the worker's output and write a review prompt for the reviewer.

              When writing review prompts, check if the project has a `.opencode/templates/` directory.
              If a matching template file exists (e.g., `pr-review.md`), load it and fill the {{PLACEHOLDER}} variables
              with the specific PR/review details. Templates ensure consistent output structure.

              Be specific, precise, and thorough. Include edge cases and test expectations.
              Do not edit source code.
            '';
            tools = {
              write = false;
              edit = false;
              patch = false;
            };
            temperature = 0.7;
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
