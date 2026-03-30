# Harness Documentation Site

Static single-page documentation site for the Harness framework, deployed on GitHub Pages.

## Stack

- Single HTML file: `docs/index.html` (~2100 lines)
- Pure CSS (no framework) with CSS custom properties design system
- Vanilla JS for scroll animations, tab switching, intersection observers
- Google Fonts: Inter (body), Space Grotesk (labels), JetBrains Mono (code)
- Material Symbols Outlined for all iconography
- Deployed from `docs/` folder on `master` branch

## Design System (Stitch-derived)

Tokens are defined in `:root` CSS variables. The design system was generated via Google Stitch MCP (project ID: `3512505028902662223`, design system: "Harness Dark").

Key tokens:
- Backgrounds: `#131313`, `#1c1b1b`, `#201f1f`, `#0e0e0e`
- Primary: `#5c5ffd` (accent), `#c0c1ff` (light)
- Secondary: `#50e1f9` (cyan), `#3cd2eb` (dim)
- Text: `#e5e2e1` (primary), `#adaaaa` (secondary), `#767575` (muted)
- Borders: `#454555` with `rgba(72,72,71,0.15)` ghost variant
- Gradients: `linear-gradient(90deg, #5c5ffd, #3cd2eb)` for hero/CTAs
- Border radius: `--radius-sm` (0.25rem) through `--radius-xl` (1rem)

## Stitch MCP

The site's visual design is driven by Stitch mockups. When making design changes:
1. Generate or reference screens in Stitch project `3512505028902662223`
2. Extract design tokens from the generated HTML
3. Apply to the site's CSS custom properties

Stitch server: `https://stitch.googleapis.com/mcp` (configured in local MCP)

## Conventions

- All styling is inline CSS in the `<style>` block — no external stylesheets
- Use CSS custom properties (`--var-name`) for all design tokens
- Use Material Symbols Outlined for icons, never emoji
- Section labels use Space Grotesk, uppercase, tracked (`letter-spacing: 0.08em+`)
- Pillar labels follow format: `01 // COMPOSITION`
- Cards use ghost borders: `1px solid rgba(72,72,71,0.15)`
- Hover effects: `translateY(-4px)` + `box-shadow: 0 0 20px rgba(92,95,253,0.08)`

## GitHub Pages

- URL: https://lsdippollc.github.io/harness-eng-skills/
- Source: `docs/` folder on `master` branch
- No build step — push to master deploys automatically

## Content Sections

The page has these sections in order:
1. Hero (badge, headline, CTAs, stats row)
2. Problem/Solution comparison ("The Harness Difference")
3. 7 Pillars of Configuration (card grid)
4. 13 Atomic Skills (sidebar nav + card list)
5. How It Works (tabbed 60/40 split with sticky code showcase)
6. Maturity Scoring (33/66 split with progress bars panel)
7. Get Started (bento card grid with full-width CTA)
8. Footer

## Critical Rules

- NEVER add external CSS frameworks (Tailwind, Bootstrap) — this is pure CSS
- NEVER change the design system tokens without first consulting Stitch mockups
- ALWAYS preview changes in browser (Playwright MCP) before considering done
- Keep all code in `docs/index.html` — no file splitting
- Do not remove the `scroll-padding-top: 80px` on `html` — it fixes nav clipping
