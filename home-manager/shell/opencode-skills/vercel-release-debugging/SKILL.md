---
name: vercel-release-debugging
description: Use when preview or production on Vercel behaves differently from local development. Focus on environment variables, build output, runtime logs, deployment configuration, caching, and edge versus serverless differences.
---

# Vercel release debugging

Treat deployment drift as an environment and runtime problem first.

## Debug order

1. confirm the exact deployment and environment
2. compare env vars and secrets usage
3. inspect build logs for framework or bundling differences
4. inspect runtime logs for request-path-specific failures
5. check cache, routing, middleware, and edge/serverless behavior

## Common causes

- missing or mismatched env vars
- node versus edge runtime assumptions
- build-time data access
- stale cache or ISR expectations
- branch-specific config drift
