---
name: multi-agent-review
description: Orchestrate a spec-first, review-driven code generation loop using prompt-engineer, worker, and reviewer subagents. One-shot automation — give requirements once, the loop runs until approved.
---

# Multi-agent review workflow

This skill automates the **spec → implement → review → iterate** loop using three specialized subagents.

## When to use

- You have a feature, bugfix, or refactor that benefits from spec-first planning and review-driven iteration.
- You want to avoid manual copy-paste between agents.

## Agent roles

| Agent | Role | Model | Tools |
|-------|------|-------|-------|
| **orchestrator** | Drives the loop, owns state, makes final decisions | GPT-5.4 | Read, Write, Task |
| **prompt-engineer** (A) | Writes specs/plans and review prompts from worker output | GPT-5.4 | Read only |
| **worker** (B) | Implements code from spec | GPT-5.4-mini | Full tools |
| **reviewer** (C) | Reviews implementation, approves or requests changes | GPT-5.5 | Read only |

## Session state layout

Create this directory at the start of each orchestration session:

```
.agent/<session-timestamp>/
  spec.md          — from prompt-engineer (round 1)
  output/          — worker implementation files
  review-prompt.md — from prompt-engineer (wraps worker output for reviewer)
  review.md        — reviewer's decision
  fix-round-N.md   — feedback from rejected review, fed back to prompt-engineer
  status.md        — current phase, round, next action
```

## Protocol

### 1. Init

```
SESSION=$(date -u +%Y%m%dT%H%M%SZ)
AGENT_DIR=".agent/${SESSION}"
mkdir -p "${AGENT_DIR}/output"
```

Ask the user for the task requirements. Write them to `${AGENT_DIR}/spec.md` as the initial brief.

### 2. Prompt engineer rounds

Spawn the **prompt-engineer** subagent via Task. Prompt:

```
You are the prompt-engineer subagent. Read ${AGENT_DIR}/spec.md.
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
- Write source code to ${AGENT_DIR}/output/
- Do not implement features outside the spec
- Do not make unrelated refactors
- Run tests if the project has a test harness
- Summarize what was implemented, any deviations, and test results
Do not mark the task approved.
```

### 4. Review prompt generation

Spawn the **prompt-engineer** subagent again. Prompt:

```
You are the prompt-engineer subagent. Read:
- ${AGENT_DIR}/spec.md (original spec)
- Worker output in ${AGENT_DIR}/output/

Write a review prompt to ${AGENT_DIR}/review-prompt.md that:
- Lists what was supposed to be implemented (from spec)
- Lists what was actually implemented (from output)
- Highlights specific areas for the reviewer to check
Do not edit source code.
```

### 5. Reviewer evaluation

Spawn the **reviewer** subagent via Task. Prompt:

```
You are the reviewer subagent. Read:
- ${AGENT_DIR}/spec.md
- ${AGENT_DIR}/output/ (implementation)
- ${AGENT_DIR}/review-prompt.md

Return a decision:
  approve — implementation meets the spec, no issues
  request_changes — specific issues must be fixed, list exactly what needs to change

Write your full review to ${AGENT_DIR}/review.md.
Do not modify any files.
```

### 6. Decision handling

Read `${AGENT_DIR}/review.md`.

- **approve**: Mark the task done. Present the final output to the user. Clean up `.agent/` if user confirms.
- **request_changes**: Write review feedback to `${AGENT_DIR}/fix-round-N.md` (increment N). Go to step 2.
- If a task exceeds **3 fix rounds**, stop and ask the user for direction.

## Rules for the orchestrator

1. Always read subagent output files yourself — never trust a subagent's summary alone.
2. One active implementation at a time (the worker edits source files).
3. Preserve any unrelated dirty state in the working tree.
4. Keep the user informed of each phase: "Planning...", "Implementing...", "Reviewing...", "Iterating...".
5. When done, summarize: what was built, what was reviewed, how many rounds.
