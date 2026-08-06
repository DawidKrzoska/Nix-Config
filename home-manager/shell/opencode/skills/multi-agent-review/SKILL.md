---
name: multi-agent-review
description: Orchestrate a spec-first, review-driven code generation loop using planner, one implementation owner (worker or specialist), reviewer, testrunner, and debugger subagents. Direct handoff — the canonical handoff packet is passed verbatim to the executor and reviewer.
---

# Multi-agent review workflow

This skill automates the **plan → implement → review → verify → iterate** loop using the configured opencode subagents. The canonical handoff packet is passed directly in Task prompts — no manual copy-paste or filesystem session state is required.

## When to use

- You have a feature, bugfix, or refactor that benefits from spec-first planning and review-driven iteration.
- You want the planner's findings delivered directly to the implementation owner and reviewer.

## Agent roles

| Agent | Role |
|-------|------|
| **orchestrator** | Triages, classifies scope, selects exactly one implementation owner, forwards the packet, routes feedback |
| **planner** | Produces a compact implementation handoff packet (10 sections) — never codes |
| **worker** | Fallback implementation owner for non-specialist tasks |
| **frontend** | Implementation owner for TuoStudio client/UI work |
| **backend** | Implementation owner for Supabase/schema/RPC/RLS/Edge Function work |
| **nix-specialist** | Implementation owner for NixOS/Home Manager/OpenCode work |
| **reviewer** | Independent, read-only review of the diff against the packet |
| **testrunner** | Executes the packet's **section 8** validation matrix and reports full output |
| **debugger** | Read-only; diagnoses reproducible failures and returns root-cause findings to the implementation owner — never edits |

## Ownership

Exactly one agent owns source edits per task/round. The orchestrator selects the owner deterministically by scope:

- `@frontend` for TuoStudio client/UI work.
- `@backend` for Supabase/schema/RPC/RLS/Edge Function work.
- `@nix-specialist` for NixOS/Home Manager/OpenCode work.
- `@worker` only for non-specialist, mixed-but-safe repository tasks.

Never dispatch both `@worker` and a specialist for the same scope.

## Session state

Session files under `.agent/` are OPTIONAL audit copies created by the orchestrator only when needed. They are never required for execution or direct handoff. The canonical handoff packet is the planner's final Task response — or, when planning is skipped, the same compact 10-section packet the orchestrator constructs directly before delegation.

## Protocol

### 1. Triage

Ask the user for the task requirements. Classify the scope and select exactly one implementation owner.

### 2. Planning (only when needed)

Spawn the **planner** subagent via Task ONLY for ambiguous, cross-cutting, high-risk, contract-sensitive, or explicitly requested planning. Prompt with the brief. The planner returns the 10-section handoff packet as its final response.

For small, well-scoped tasks, skip planning. The orchestrator constructs the mandatory numbered 10-section handoff packet itself (exact template in step 3 below) before delegating. Planning is optional; the packet is not.

### 3. Implementation

Every implementation task receives a self-contained canonical handoff packet. If @planner ran, copy its complete packet VERBATIM. If planning was skipped, the orchestrator MUST construct the exact numbered 10-section packet below — every section required, aligned with the planner's template:

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

Copy the completed packet VERBATIM into the implementation owner's Task prompt AND into every testrunner Task prompt (the testrunner executes its section 8 validation matrix). Do not paraphrase or re-explore.

```
You are the implementation owner. Implement exactly the handoff packet below.
<full packet>
Record deviations, contract conflicts, changed files, and executed validation in your final response.
```

### 4. Review

Spawn the reviewer via Task. Forward the original handoff packet, the executor's report, the canonical constraints, and the current diff.

```
You are the reviewer. Review the ACTUAL diff against the handoff packet.
<Packet>
<Executor report>
<Current diff>
Classify every issue: implementation defect → executor; requirement/contract error → planner; scope/approval → orchestrator/user.
```

### 5. Verification

If the reviewer approves, copy the ORIGINAL canonical self-contained 10-section handoff packet VERBATIM into the testrunner's Task prompt. The testrunner executes the packet's **section 8 validation matrix** and reports full output:

- TuoStudio implementation/commit readiness: `nix develop --command pnpm verify`.
- Nix/OpenCode changes: the packet's Nix evaluation/format checks (system rebuild excluded unless separately approved).

If verification fails, send the full failure output to the implementation owner (or the read-only debugger for reproducible failures with supplied logs). The debugger returns root-cause findings to the implementation owner, who alone applies the fix.

### 6. Decision handling

- **approve**: Mark the task done. Present the final output to the user.
- **request_changes**: Route feedback by classification:
  - implementation defect → targeted executor correction.
  - missing/incorrect requirement or contract conflict → planner revision of only the affected sections.
  - scope/approval issue → orchestrator/user escalation.
- If a task exceeds **3 fix rounds**, stop and ask the user for direction.

## Rules for the orchestrator

1. Always read subagent output yourself — never trust a summary alone.
2. Exactly one implementation owner edits source files per task/round; @debugger and @reviewer are read-only and never edit.
3. Preserve any unrelated dirty state in the working tree.
4. Keep the user informed of each phase: "Planning...", "Implementing...", "Reviewing...", "Iterating...".
5. When done, summarize: what was built, what was reviewed, how many rounds.
