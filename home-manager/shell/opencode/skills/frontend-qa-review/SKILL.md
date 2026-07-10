---
name: frontend-qa-review
description: Use when a frontend change is ready for QA, review, or release. Focus on loading, empty, error, and success states, responsiveness, keyboard access, visual regressions, and data edge cases.
---

# Frontend QA review

Check the states users actually hit in production.

## QA pass

- happy path
- slow loading state
- empty data state
- error and retry path
- mobile viewport behavior
- keyboard and focus behavior
- destructive or irreversible actions

## Output format

Report findings by severity:

- blocker
- major
- minor
- polish
