---
name: supabase-client-patterns
description: Use when writing frontend or server code with Supabase client libraries. Focus on auth-aware data access, typed query shape, error handling, pagination, and avoiding duplicated fetch logic.
---

# Supabase client patterns

Favor consistent, typed, auth-aware data access.

## Guidelines

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
