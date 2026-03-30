# Harness Documentation Site

Static single-page docs site for the Harness framework. Pure CSS + vanilla JS, deployed on GitHub Pages from `docs/` on `master`.

## Critical Rules

- NEVER add external CSS frameworks (Tailwind, Bootstrap) — pure CSS only
- NEVER change design tokens without consulting Stitch mockups first
- ALWAYS preview in browser (Playwright MCP) before considering done
- Keep all code in `docs/index.html` — no file splitting
- Do not remove `scroll-padding-top: 80px` on `html` — fixes nav clipping
- Use Material Symbols Outlined for icons, never emoji
- Use inline SVGs for diagrams, not AI-generated images

## Stack

- `docs/index.html` (~2400 lines) — single file, all CSS inline in `<style>`
- Fonts: Inter (body), Space Grotesk (labels), JetBrains Mono (code)
- Icons: Material Symbols Outlined
- Design system: Stitch MCP project `3512505028902662223` ("Harness Dark")
- Deploy: push to `master` → GitHub Pages at https://lsdippollc.github.io/harness-eng-skills/

## Workflow & Orchestration

Design change loop:
1. Generate Stitch screen(s) — can parallelize multiple sections
2. Download HTML via WebFetch, extract tokens
3. Implement changes to `docs/index.html`
4. Preview: `python3 -m http.server` → Playwright navigate → trigger `.fade-in` → screenshot
5. Responsive check: resize to 375px, 768px, 1440px
6. Clean up temp files and kill server

When to parallelize:
- Multiple Stitch screens: fire all `generate_screen_from_text` calls concurrently
- Independent section work: use background agents for research while editing
- Responsive testing: screenshot all breakpoints in sequence (dependent on resize)

When NOT to parallelize:
- Changes that touch the same CSS block — serialize to avoid conflicts
- Stitch extraction → implementation — sequential (need the tokens first)

Use Explore agents for fuzzy searches across the HTML (class names, section boundaries).

## Quality Gates

Before any PR or deploy:
- [ ] Playwright preview at desktop (1440px) — all sections render correctly
- [ ] Playwright preview at mobile (375px) — no overflow, text readable
- [ ] All `.fade-in` elements trigger properly
- [ ] Expandable skill cards open/close smoothly
- [ ] Workflow tabs switch between Bootstrap/Audit/Improve
- [ ] No horizontal scroll at any breakpoint
- [ ] SVG diagrams render (not just empty space)

Post-edit hooks (automatic via settings.json):
- `harness-validate.sh` runs on every Edit/Write to check harness consistency
- `harness-drift.sh` runs at conversation end for staleness check

## Interaction Style

- Be terse — the diff speaks for itself
- Don't summarize completed work unless asked
- Parallelize independent changes with subagents
- When the user corrects an approach, save a feedback memory immediately
- When the user confirms a non-obvious choice worked, save that too

## On-Demand Context

Run these commands for detailed reference when needed:
- `/design-tokens` — Full Stitch color palette, typography, spacing, pillar colors
- `/site-map` — Section-by-section layout guide with CSS classes and responsive breakpoints
