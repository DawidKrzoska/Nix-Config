---
name: multi-agent-review
description: Orchestrate a direct-handoff, review-driven delivery loop with one implementation owner, risk-based validation, and conditional Supabase security review.
---

# Multi-agent review workflow

This skill automates the **plan → implement → targeted validate → review → final verify → iterate** loop. The canonical handoff packet is passed directly in Task prompts; no session files or source artifacts are required.

## When to use

- You have a feature, bugfix, or refactor that benefits from spec-first planning and review-driven iteration.
- You want the planner's findings delivered verbatim to the implementation owner, reviewer, and testrunner.

## Agent roles

| Agent | Role |
|---|---|
| **orchestrator** | Triages, selects exactly one implementation owner, forwards the packet, and routes feedback |
| **planner** | Produces the mandatory 10-section implementation handoff packet — never codes |
| **worker** | Fallback implementation owner for non-specialist tasks |
| **frontend** | Implementation owner for TuoStudio client/UI work |
| **backend** | Implementation owner for Supabase/schema/RPC/RLS/Edge Function work |
| **nix-specialist** | Implementation owner for NixOS/Home Manager/OpenCode work |
| **reviewer** | Independent, read-only review of the actual diff against the packet |
| **testrunner** | Runs targeted Nix/OpenCode or TuoStudio validation and final exact-HEAD verification |
| **debugger** | Read-only diagnosis; returns root-cause findings to the implementation owner — never edits |
| **database-security-reviewer** | Independent read-only review of sensitive Supabase/RLS changes |
| **roadmap-driver** | Read-only TUO roadmap briefs, readiness, and blockers |
| **manual-qa** | Read-only human-QA handoff packet producer |

## Ownership and packet

Exactly one agent owns source edits per task and every fix round: `@frontend` for TuoStudio client/UI, `@backend` for Supabase/schema/RPC/RLS/Edge Function, `@nix-specialist` for NixOS/Home Manager/OpenCode, and `@worker` only for non-specialist mixed-but-safe work. Never dispatch `@worker` and a specialist for the same scope. Reviewer and debugger are read-only. Route every fix to the original implementation owner.

Planning is optional for small, well-scoped work; the packet is not. For ambiguous, cross-cutting, high-risk, contract-sensitive, or explicitly requested planning, `@planner` returns the canonical packet. Otherwise, the orchestrator creates it. It must always contain these numbered sections:

1. Task classification and owner — repository, scope type, and exactly one implementation agent.
2. Goal and non-goals — explicit exclusions preventing scope expansion.
3. Authoritative sources — exact AGENTS.md, canonical Tuo docs/sections, relevant skill(s).
4. Constraints and approval status — RLS/RPC authority, public/admin separation, booking authority, declarative Nix rules, and whether a merge approval gate applies.
5. Evidence map — files inspected, existing patterns to follow, relevant interfaces/RPCs/views/types.
6. Implementation map — each expected file and its precise intended responsibility/change; no speculative files.
7. Behavior and edge cases — loading/empty/error/success states, authorization failures, cache invalidation, transactional or role-boundary cases.
8. Validation matrix — targeted tests/checks, required `pnpm verify` conditions, and Nix validation where applicable.
9. Escalation triggers — contract gaps, behavior conflicts, cross-scope needs, migration/deployment boundaries, or dirty-tree conflicts.
10. Review focus — the highest-risk conditions the independent reviewer must verify.

Copy the completed packet **verbatim** into each implementation-owner and testrunner Task prompt. Do not paraphrase, re-explore, or require `.agent/` session artifacts.

## Execution ordering

1. Triage and select the single owner. Optionally obtain the packet from the planner; otherwise construct the full packet.
2. The selected owner implements exactly the packet.
3. After implementation or a fix, `@git` creates and records a clean candidate commit SHA before targeted validation, review, security review, or full verification. It reports repository/path, branch, SHA, and clean `git status --porcelain`. Uncommitted work never satisfies readiness.
4. Send the original packet verbatim, candidate repository/path, branch, SHA, and actual changed surface to `@testrunner` for targeted validation. TuoStudio uses `$HOME/TuoStudio` and `nix develop --command pnpm ...`; wolfar-nix-config uses `$HOME/wolfar-nix-config` and relevant Nix formatting/evaluation/build checks. A targeted pass is not a pre-PR gate.
5. Send the original packet, candidate repository/path, branch, SHA, executor report, validation evidence, and candidate diff to the read-only `@reviewer`.
6. For sensitive scope or diff—Supabase migrations/baseline; SQL policy, RLS, RPC, function, view, grant, trigger, or security context; function auth configuration; or privileged Supabase Edge Functions—also send the candidate diff, packet, canonical docs, and `supabase-migration-review` skill to `@database-security-reviewer`. Its `REQUEST_CHANGES` or `BLOCKED_REVIEW` blocks progress. Rerun it after each sensitive change.
7. Route validation, reviewer, security, and debugger-informed fixes only to the original implementation owner. Any working tree, candidate commit, branch, or PR HEAD change invalidates targeted, general-review, security-review, full-verification, QA, and readiness evidence. Create/record the new clean candidate SHA and repeat all applicable checks against it.
8. Once required review/security evidence passes on the candidate SHA, send the packet, repository/path, branch, and SHA verbatim to `@testrunner` in `full-pre-pr` mode. For TuoStudio it must run exactly `nix develop --command pnpm verify` against that exact clean candidate SHA. Missing, stale, or failed evidence blocks PR creation.
9. Only immediately before merging, request fresh explicit user approval for that specific PR and exact HEAD. Any changed HEAD or intervening action invalidates the approval. Max three fix rounds; then ask the user.

## Roadmap and local-dev routing

Use `@roadmap-driver` for read-only roadmap next/status briefs and `@manual-qa` only after collecting relevant independent review, conditional security review, and validation evidence. A dirty tree, missing exact SHA, stale validation, inaccessible environment, MCP failure, or contract mismatch produces `BLOCKED_HANDOFF`.

For only `tuo:local-dev`, `tuo:local-dev:seed`, `tuo:local-dev:status`, `tuo:local-dev:logs`, `tuo:local-dev:stop`, and `tuo:local-dev:restart`, the orchestrator may run precisely the command template's fixed diagnostic/session-management bash commands. This exception never permits source edits, VCS mutations, implementation, or arbitrary shell commands.

## Rules

1. Read complete subagent output; never trust a summary alone.
2. Preserve unrelated dirty state.
3. Never combine database + UI, admin + public, booking engine + styling, or email + schedule in one implementation task.
4. TuoStudio work runs through `nix develop` with `pnpm`.
5. Human approval is only a merge gate, immediately before merge of an exact HEAD.
