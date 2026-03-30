---
name: deployment-vercel
description: Vercel deployment -- preview on PRs, production from main, env vars prefixed VITE_
type: reference
---

Deployment platform: Vercel

- Preview deployments: Automatic on every PR branch push
- Production deployments: Automatic from `main` branch
- Environment variables: Managed in Vercel dashboard
- Client-side env vars: Must be prefixed with `VITE_` to be exposed to the browser
- Config: `vercel.json` in project root

**How to apply:** When working on features that depend on env vars, remind about the `VITE_` prefix. Never hardcode environment-specific values.
