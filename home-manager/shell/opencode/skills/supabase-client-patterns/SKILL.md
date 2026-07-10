---
name: supabase-client-patterns
description: Use when writing frontend or server code with Supabase client libraries. Focus on auth-aware data access, typed query shape, error handling, pagination, and avoiding duplicated fetch logic.
---

# Supabase client patterns

Favor consistent, typed, auth-aware data access.

## General guidelines

- Keep Supabase access behind reusable functions, hooks, or query modules.
- Select only required columns and name joins clearly.
- Handle `data` and `error` together; do not ignore partial failure paths.
- Preserve session-aware flows for user-specific queries and mutations.
- Prefer cursor or explicit range pagination for growing lists.
- Keep optimistic updates aligned with server truth and invalidation strategy.

## Watch for

- duplicate inline queries across components
- broad `select("*")` usage
- auth assumptions hidden in UI code
- missing empty, loading, or permission-denied states

## TuoStudio-specific conventions

When working in TuoStudio, follow existing patterns in `src/services/` and `src/hooks/`.

- RPC results use typed wrappers (see existing service files for the convention).
- Service functions throw on error; callers handle via TanStack Query.
- Query keys are arrays. Follow the key format used by existing hooks.
- Coordinate cache invalidation after mutations. Check existing hooks to identify which queries to invalidate.
- Do not duplicate authoritative business rules (booking, capacity, eligibility) in frontend services.
- Read `@tuo-docs` canonical docs before changing data access patterns.
