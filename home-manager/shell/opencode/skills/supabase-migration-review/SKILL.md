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
- Confirm RLS still enforces tenant and auth boundaries for every applicable role, including both `USING`
  and `WITH CHECK` predicates.
- Review RPC authorization, stable public contracts, transaction scope, locking, and side effects. For
  `SECURITY DEFINER` functions, require a fixed `search_path` and narrowly scoped authority.
- Verify grants match intended caller roles and do not expose privileged functions or tables.
- Review triggers for execution role, recursion, side effects, ordering, and backfill interaction.
- Check views for admin/public leakage, underlying RLS behavior, and grants.
- Review privileged Edge Functions for JWT/auth enforcement, service-role containment, secret handling,
  and logs that do not expose credentials or sensitive data.
- Call out production rollout risks, backfill needs, and rollback limits.

## Review output

Structure feedback as:

1. schema correctness
2. auth and RLS impact
3. grants, triggers, views, RPC/SECURITY DEFINER, and Edge Function security impact
4. rollout and rollback risk, including migration ordering and backfills
5. performance implications
6. follow-up migration or test gaps

## TuoStudio-specific prompts

When reviewing TuoStudio migrations, read `@tuo-docs` canonical docs first.
Key concerns: RLS role coverage (all user states + admin), `USING`/`WITH CHECK` correctness, RPC auth
guards and SECURITY DEFINER search paths, grant consistency, trigger/view leakage, ordered backfills, and
privileged Edge Function authentication. Preserve canonical booking/waitlist/admin contracts; do not claim
database implementation requires pre-implementation human approval.
