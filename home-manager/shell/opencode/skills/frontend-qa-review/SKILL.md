---
name: frontend-qa-review
description: Use when a frontend change is ready for QA, review, or release. Focus on loading, empty, error, and success states, responsiveness, keyboard access, visual regressions, and data edge cases.
---

# Frontend QA review

Check the states users actually hit in production.

## General QA pass

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

## TuoStudio-specific QA items

When QA'ing changes to TuoStudio:

- Run `pnpm typecheck` and `pnpm lint` before finishing; `pnpm verify` before committing.
- **Auth boundary testing**: Test with each applicable role (unauthenticated, member, admin). Confirm denied paths are blocked.
- **Backend-read values**: Verify phone, config, and dynamic data come from read models, not frontend constants.
- **Admin/non-admin leak**: Verify admin-only data does not leak to non-admin routes. UI guards are not security.
- **Mobile-first**: All primary flows must work on mobile viewport. No hover-only interactions.
- **Cache invalidation**: Verify relevant queries refresh after mutations (see existing hooks for key patterns).
- **State coverage**: Confirm loading, empty, error, and success states for each new or changed component.
