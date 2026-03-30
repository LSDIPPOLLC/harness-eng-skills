---
name: vercel-deployment
description: Vercel platform used for hosting and deployment, preview URLs generated per PR
type: reference
---

Deployment platform: Vercel
- Production URL: configured in Vercel project settings
- Preview deploys: auto-generated on every PR push
- Build command: `npm run build` (Vite)
- Output directory: `dist/`

Environment variables are managed in the Vercel dashboard, not committed to the repo. Local development uses `.env.local`.
