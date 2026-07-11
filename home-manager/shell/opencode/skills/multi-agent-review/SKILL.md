---
name: multi-agent-review
description: Orchestrate a spec-first, review-driven code generation loop using planner, worker, reviewer, testrunner, and debugger subagents. One-shot automation — give requirements once, the loop runs until approved.
---

# Multi-agent review workflow

This skill automates the **spec → implement → review → verify → iterate** loop using the configured opencode subagents.

## When to use

- You have a feature, bugfix, or refactor that benefits from spec-first planning and review-driven iteration.
- You want to avoid manual copy-paste between agents.

## Agent roles

| Agent | Role |
|-------|------|
| **orchestrator** | Drives the loop, delegates work, and reports status |
| **planner** | Researches the codebase and writes specs with acceptance criteria |
| **worker** | Implements the approved spec in the repository |
| **reviewer** | Reviews implementation against the spec and requests fixes if needed |
| **testrunner** | Runs `pnpm verify` for TuoStudio and reports full output |
| **debugger** | Diagnoses and fixes failures from test or runtime output |

## Session state layout

Create this directory at the start of each orchestration session:

```
.agent/<session-timestamp>/
  brief.md         — original user requirements
  spec.md          — planner output
  worker.md        — worker summary
  review.md        — reviewer's decision
  verify.md        — testrunner output
  fix-round-N.md   — feedback from rejected review or failed verify
  status.md        — current phase, round, next action
```

## Protocol

### 1. Init

```
SESSION=$(date -u +%Y%m%dT%H%M%SZ)
AGENT_DIR=".agent/${SESSION}"
mkdir -p "${AGENT_DIR}"
```

Ask the user for the task requirements. Write them to `${AGENT_DIR}/brief.md` as the initial brief.

### 2. Planner rounds

Spawn the **planner** subagent via Task. Prompt:

```
You are the planner subagent. Read ${AGENT_DIR}/brief.md.
If this is round 1 (no ${AGENT_DIR}/review.md exists yet):
  - Write a detailed technical spec and implementation plan to ${AGENT_DIR}/spec.md
  - Include acceptance criteria and test expectations
If this is a fix round (${AGENT_DIR}/fix-round-N.md exists):
  - Read ${AGENT_DIR}/fix-round-N.md and ${AGENT_DIR}/spec.md
  - Revise the spec and write updated implementation instructions to ${AGENT_DIR}/spec.md
Do not edit source code.
```

### 3. Worker implementation

Spawn the **worker** subagent via Task. Prompt:

```
You are the worker subagent. Implement exactly what is specified in ${AGENT_DIR}/spec.md.
- Edit the repository source files directly.
- Do not implement features outside the spec
- Do not make unrelated refactors
- Run tests if the project has a test harness
- Write a summary of changed files, deviations, and test results to ${AGENT_DIR}/worker.md
Do not mark the task approved.
```

### 4. Reviewer evaluation

Spawn the **reviewer** subagent via Task. Prompt:

```
You are the reviewer subagent. Read:
- ${AGENT_DIR}/spec.md
- ${AGENT_DIR}/worker.md
- The current git diff

Return a decision:
  approve — implementation meets the spec, no issues
  request_changes — specific issues must be fixed, list exactly what needs to change

Write your full review to ${AGENT_DIR}/review.md.
Do not modify any files.
```

### 5. Verification

If the reviewer approves and the work touches TuoStudio, spawn the **testrunner** subagent before PR or commit work. Write its output to `${AGENT_DIR}/verify.md`.

- If verification passes, finish the loop.
- If verification fails, write the failure summary to `${AGENT_DIR}/fix-round-N.md` and send it to **debugger** or **worker** as appropriate.

### 6. Decision handling

Read `${AGENT_DIR}/review.md`.

- **approve**: Mark the task done. Present the final output to the user. Clean up `.agent/` if user confirms.
- **request_changes**: Write review feedback to `${AGENT_DIR}/fix-round-N.md` (increment N). Go to step 2 or send directly to worker for narrow fixes.
- If a task exceeds **3 fix rounds**, stop and ask the user for direction.

## Rules for the orchestrator

1. Always read subagent output files yourself — never trust a subagent's summary alone.
2. One active implementation at a time (the worker edits source files).
3. Preserve any unrelated dirty state in the working tree.
4. Keep the user informed of each phase: "Planning...", "Implementing...", "Reviewing...", "Iterating...".
5. When done, summarize: what was built, what was reviewed, how many rounds.
