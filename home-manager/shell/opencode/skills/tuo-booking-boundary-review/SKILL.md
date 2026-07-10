---
name: tuo-booking-boundary-review
description: Use when implementing or reviewing booking, waitlist, cancellation, or recurring booking code. Verifies that frontend tasks do not duplicate documented RPC authority and backend tasks preserve transactional semantics.
---

# TUO Booking boundary review

Booking logic lives server-side in RPCs. Frontend orchestrates, never owns business rules.

## Pre-flight

Before implementing booking-related features, read the canonical docs at `@tuo-docs`:

- PRD for booking rules
- booking RPC SQL for exact RPC contracts
- database views SQL for read models

## Frontend boundary

- **Must use RPCs** for booking, waitlist, cancellation, and recurring booking mutations.
- **Must NOT** calculate eligibility, capacity, conflicts, or cutoff logic in frontend code.
- **Must NOT** directly insert/update bookings, waitlist_entries, or class_occurrences from the client.
- Waitlist, late cancellation, and recurring booking flows must follow what the RPC returns — do not reimplement backend decisions in the UI.

## Backend boundary

- **Preserve transactional integrity**: row locks for capacity, atomic booking + waitlist behavior.
- **No RPC changes without human review**: booking, waitlist, cancellation, and attendance RPCs.
- **Return stable result codes**: frontend needs consistent error/success codes for state handling.

## Common boundary violations

- Frontend checks capacity before allowing "Book" click — let the RPC reject and surface the error.
- Waitlist entries inserted directly instead of via the join_waitlist RPC.
- Late cancellation cutoff logic duplicated in frontend and backend.
- Recurring booking implemented as a frontend loop creating individual bookings.
