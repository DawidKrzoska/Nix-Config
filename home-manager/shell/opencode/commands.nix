{ config, lib, pkgs, inputs, ... }: {
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
}
