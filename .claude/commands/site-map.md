# Docs Site Section Map

Single file: `docs/index.html` (~2400 lines)

## Sections (in DOM order)

| # | Section | CSS class / ID | Layout |
|---|---------|---------------|--------|
| 1 | Nav | `nav#nav`, `.nav-inner` | Fixed top, backdrop-blur |
| 2 | Hero | `.hero#hero` | Centered, badge + h1 + CTAs + stats grid |
| 3 | Problem/Solution | `.problem-solution-wrap` | Full-width bg, centered header, 2-col cards with `border-l-4` |
| 4 | 7 Pillars | `section#pillars`, `.pillars-grid` | 3-col card grid, `border-top-4` accent, Material Symbol icons |
| 5 | 13 Skills | `section#skills`, `.skills-layout` | Sidebar nav (desktop) + expandable card list with SVG diagrams |
| 6 | How It Works | `section#how-it-works` | Tabbed (Bootstrap/Audit/Improve), 60/40 split: stepper + sticky code |
| 7 | Maturity | `section#maturity`, `.maturity-split` | 33/66 split: text left (sticky) + progress bars panel right |
| 8 | Get Started | `section#getting-started`, `.getting-started-grid` | 4-col bento grid + full-width card #5 with CTA |
| 9 | Footer | `footer` | Logo + nav links |

## Key CSS patterns
- Ghost borders: `1px solid rgba(72,72,71,0.15)`
- Hover: `translateY(-4px)` + glow shadow
- Fade-in: `.fade-in` class, triggered by IntersectionObserver
- Expandable cards: `.skill-card.expanded` toggles `.skill-body` max-height

## Responsive breakpoints
- `480px`: Stack hero buttons, smaller headline
- `768px`: Hide nav links, stack grids to 1-col, 2x2 stats
- `1024px`: Workflow split activates (60/40)
