---
name: tuo-admin-boundary-review
description: Use when implementing or reviewing admin panel features. Verifies that admin UI uses admin-safe views and RPCs, preserves RLS boundaries, and does not expose privileged data to unauthorized roles.
---

# TUO Admin boundary review

Admin authority lives in backend RPCs and RLS policies. Frontend routes are not security.

## Pre-flight

Before implementing admin features, read the canonical docs at `@tuo-docs`:

- admin RPC SQL for admin RPC contracts
- database views SQL for admin-safe read models
- database schema docs for table structure and field visibility
- PRD for admin requirements and scope

## Frontend admin boundary

- **Must use admin-safe views and RPCs** for all admin data access and mutations.
- **UI guards are NOT security** — route-level guards prevent accidental navigation but do not replace database authorization.
- **Do not expose**: admin notes, private trainer contact data, audit logs, full user records, or privileged operations to non-admin users.
- **Do not directly mutate** bookings, profiles, or admin tables from the client.
- Business Settings editing must go through admin RPCs.

## Backend admin boundary

- **Admin RPCs must validate** `public.is_admin()` and use `security definer` where documented.
- **Admin actions must create logs** where documented (approvals, rejections, cancellations, override bookings).
- **Admin override capacity**: requires a reason parameter and must be logged.
- **Preserve public/private trainer field separation**: private contact data stays admin-only.

## Common boundary violations

- Admin UI fetches all user records via a broad `select(*) from profiles` instead of an admin-safe view.
- Admin cancels a class through direct mutation instead of the admin RPC.
- A route guard is treated as sufficient authorization for privileged data.
- Admin and public features are built in the same task scope.
