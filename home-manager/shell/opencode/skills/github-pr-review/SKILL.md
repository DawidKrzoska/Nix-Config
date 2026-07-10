---
name: github-pr-review
description: Use when reviewing GitHub pull requests, diffs, or pre-merge changesets. Focus on correctness, scope control, UX impact, regression risk, test coverage, and review comments that are actionable.
---

# GitHub PR review

Review like a teammate protecting main, not a passive summarizer.

## Review flow

1. Restate what the PR changes.
2. Check correctness on the main code paths.
3. Look for edge cases, regressions, and hidden coupling.
4. Review UX impact for user-facing changes.
5. Check whether tests cover the risky behavior.

## Comment style

- Lead with the risk or bug, not vague preference.
- Be explicit about severity.
- Suggest the smallest safe fix when possible.
- Separate required changes from optional polish.
