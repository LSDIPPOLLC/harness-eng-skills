---
name: deployment
description: Vercel deployment -- preview deploys on PRs, production on pushes to main
type: project
---

Deployment is automated through Vercel's GitHub integration.

- Every PR gets a preview deployment with a unique URL
- Merges to `main` trigger production deployment
- Environment variables configured in Vercel dashboard (not in repo)

**How to apply:** When making changes, note that preview deploys happen automatically on PRs. No manual deploy steps needed.
