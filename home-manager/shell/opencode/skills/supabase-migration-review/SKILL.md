---
name: supabase-migration-review
description: Use when changing Supabase schema, SQL migrations, RLS policies, RPC functions, triggers, or indexes. Focus on safety, rollback risk, auth boundaries, and production impact before merge.
---

# Supabase migration review

Review changes with database safety first.

## General checkpoints

- Prefer additive migrations before destructive ones.
- Verify `NOT NULL`, default, enum, and foreign-key changes against existing data.
- Check whether indexes match new query paths and policy predicates.
- Confirm RLS still enforces tenant and auth boundaries.
- Review RPC and trigger changes for transaction scope and side effects.
- Call out production rollout risks, backfill needs, and rollback limits.

## Review output

Structure feedback as:

1. schema correctness
2. auth and RLS impact
3. rollout and rollback risk
4. performance implications
5. follow-up migration or test gaps

## TuoStudio-specific prompts

When reviewing TuoStudio migrations, read `@tuo-docs` canonical docs first.
Key concerns: RLS role coverage (all user states + admin), RPC auth guards, grant consistency, and human-approval requirements for any booking/waitlist/admim logic changes.
