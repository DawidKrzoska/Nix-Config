---
name: ux-feature-implementation
description: Use when building or refining user-facing UI in web apps. Focus on hierarchy, spacing, accessibility, empty/loading/error states, responsive behavior, and copy clarity instead of only technical completion.
---

# UX feature implementation

Build the full interaction, not just the happy path.

## General UX checklist

- Make the primary action obvious within the first screenful.
- Use clear hierarchy with restrained visual emphasis.
- Design loading, empty, error, and success states with equal care.
- Ensure keyboard access, visible focus, and semantic markup.
- Keep copy short, specific, and action oriented.
- Verify mobile layout before polishing desktop-only details.

## Delivery standard

When proposing UI work, mention:

1. main user goal
2. critical states
3. accessibility considerations
4. responsive behavior
5. any unresolved UX tradeoffs

## TuoStudio-specific UX guidance

When building UI for TuoStudio (boutique fitness booking platform):

- **Mobile-first**: All primary flows must work on mobile viewport first.
- **Premium restrained direction**: clean spacing, restrained color palette, clear typography. Avoid dashboard clutter.
- **Backend-sourced data**: phone, names, types, config values must come from read models — never hardcoded. See `@tuo-docs`.
- **Public vs admin separation**: public and admin surfaces should not feel like the same product area.
