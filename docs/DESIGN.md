# Pisto — Design system

Normative, like ARCHITECTURE.md. The single source of truth in code is
`pisto_app/lib/config/app_theme.dart` + `lib/config/tokens.dart` (`PistoTokens`).
If a screen contradicts this doc, the screen is wrong.

**Why these rules: `docs/RATIONALE.md` §10-14** — hierarchy, type scale, cards, decorative
icons, contrast, target size, spacing and motion, each quoted from Material, WCAG, Apple or
Flutter. It also states plainly which of our rules have **no** official backing and stand as
product decisions (the decorative-icon ban and the ≤4-boxes limit among them). Argue with the
source, not the author — and when you add a rule here, add its source there.

Identity: warm cream/pastel, friendly and trustworthy — Shopify admin + Notion,
for salvadoran SME owners. Not a fintech dashboard, not a toy.

## Palette

### Brand + accents

| Token | Hex | Role | Contrast notes |
|---|---|---|---|
| `primary` (light) | `#237059` | Filled buttons, FAB, active states, links | 4.5:1+ with white text — AA. |
| `AppTheme.brandGreen` | `#2D8F6F` | Large accents: icons, illustration green, strokes, chart fills | **3.98:1 with white — never a button fill with white text.** |
| `primary` (dark) | `#3BA57F` | Same roles on `#1C1916` base | 4.5:1+ on dark surface. |
| `AppTheme.accent` (peach) | `#E8835A` | **Container fills only** (chips, badges, illustration) | Text on it must be `#1C1916` (6.52:1). Never white text on peach; never peach as text on cream. |
| `AppTheme.accentText` | `#B4542E` | Peach as a *foreground* (aging buckets, accent icons/text) | 4.7:1 on cream — AA. |
| `secondary` (light) | `#E8835A` | Decorative secondary | `onSecondary` forced to `#1C1916`. |
| `tertiary` (light) | `#8B7EC8` lavender | Decorative tertiary | `onTertiary` forced to `#1C1916` (white fails at 3.6:1). |

### Pastel containers (light mode; in dark use `cs.surfaceContainer`)

| Token | Hex | Text on it |
|---|---|---|
| `mintContainer` | `#E8F5ED` | `onSurface` / dark ink only |
| `peachContainer` | `#FFF0E6` | `onSurface` / dark ink only |
| `lavenderContainer` | `#F0EDFB` | `onSurface` / dark ink only |

Mint, peach and lavender are **container-only** colors. They never carry
meaning alone and never appear as text.

### Semantic intent (`PistoTokens` — theme-aware)

| Role | Light | Light container | Dark | Dark container |
|---|---|---|---|---|
| success | `#34A853` | `#E8F5ED` | `#5BBF7E` | `#1A3D2A` |
| warning | `#F5A623` | `#FDF1DC` | `#F5B94F` | `#3A2E1A` |
| danger | `#E35D5D` | `#FEE2E2` | `#F87171` | `#3B0A0A` |
| info | `#5B8DEF` | `#E4EDFD` | `#7FA6F2` | `#1E2A44` |

The intents above are tuned to sit on their own tinted containers. **On bare cream
they fail WCAG**: `warning` is 1.92:1 and `success` 2.90:1 — below even the 3:1
floor for large text. Use them for fills, for icons on tint, and for chart marks.

### Semantic intent as foreground text

| Token | Light | on cream | Dark | on `#1C1916` |
|---|---|---|---|---|
| `successText` | `#1E7A3C` | 5.11:1 | `#5BBF7E` | 7.67:1 |
| `warningText` | `#96610A` | 4.97:1 | `#F5B94F` | 9.95:1 |
| `dangerText` | `#C0392B` | 5.16:1 | `#F87171` | 6.33:1 |
| `infoText` | `#2E5FBF` | 5.69:1 | `#7FA6F2` | 6.60:1 |

**Whenever an intent colours text, use these** — `BigFigure` values, money cells,
deltas, destructive labels. Same trap `AppTheme.accentText` already exists for.
Icons keep the plain intents: WCAG asks 3:1 of graphics, which they clear.

### Chart palette (`tokens.chartPalette`, decorative, cycle `i % length`)

Light: `#237059`, `#6FCF9A`, `#A78BDB`, `#F5C563`, `#F0A07C`, `#5B8DEF`.
Dark: same, first entry `#3BA57F`, last `#7FA6F2`.

### Borders and outlines

Sand `#F0E6D9` is 1.15:1 on cream — it can decorate, it cannot delimit.
Form fields are therefore **filled** and additionally get a real outline:
`cs.outline` = `#8B7E6B` (light, 3.7:1) / `#857664` (dark, 3.8:1). Decorative
hairlines use `AppTheme.borderSubtle` / `borderStrong`.

## Typography

Body/UI: **Figtree** (400–800). Money/numbers: **Spline Sans Mono**
(400/500/600). Why: Figtree keeps the friendly geometry of Nunito with a more
contemporary, tighter rhythm; Spline Sans Mono has tabular-feeling digits with
warmth, so money reads as data without looking like a terminal.

| Role | Face | Usage |
|---|---|---|
| `display*` | Figtree w700–w800, negative tracking | Hero headings |
| `headline*` / `titleLarge` | Figtree w600–w700 | Screen + card titles |
| `body*` | Figtree w400 | Copy |
| `label*` / buttons | Figtree w600 | Buttons, chips, meta |
| `AppTheme.eyebrow` | Figtree w700 11px, +1.2 tracking, uppercase | Context labels |
| `AppTheme.mono` | Spline Sans Mono | All money and dense numerics. Inline w400–w500; totals/KPIs **SemiBold w600** (see `MoneyValue`). |

Screens use `textTheme` roles or the `AppTheme` helpers — no ad-hoc
`fontFamily:` strings, no `GoogleFonts.*` calls outside `app_theme.dart`.

## Radii & spacing (`PistoTokens` statics)

- Spacing scale: 4 / 8 / 12 / 16 / 20 / 24 / 32 (`PistoTokens.s4`…`s32`).
- Radii: card **18**, chip **20** (pill), buttons/inputs **14**, icon tile **12**
  (single decision — every square icon container is 12).
- Component themes already carry these radii; widgets should not restate them
  except in raw `Container`s, where they use the `PistoTokens.radius*` constants.

## Surfaces

M3 surface ladder over warm cream (light) / warm brown `#1C1916` (dark) via
FlexColorScheme surface blends. Depth = ladder step
(`surfaceContainerLow` → `surfaceContainer` → `surfaceContainerHigh`), never
elevation: `surfaceTint` is transparent, elevations are 0, no shadows.
Cards are solid fills (pastel or ladder step) with at most a subtle warm border.

## Illustration style

Flat vector, editorial, friendly. Formula: exact palette hexes above
(brand green `#2D8F6F`, peach `#E8835A`, mint/lavender containers, cream
background `#FFF8F0`), thick even strokes, rounded geometry, no gradients,
no 3D, no photorealism, no embedded text. Matches `assets/illustrations/`.

## Logo

Direction: coin + leaf mark (see `docs/brand/logo_concept_coin_leaf.png`),
wordmark in Figtree-compatible rounded sans. Green `#237059`/`#2D8F6F` on
cream; single-color variants only — no gradients.

## Primitives

The shared widgets in `lib/shared/widgets/` (+ `lib/shared/forms/side_panel_form.dart`) are
the ONLY way to build headers/lists/cards/forms — see the redesign rules in §1 below. A
screen that hand-rolls a row/card/header variant one of these already covers is wrong.

| Primitive | File | One-line usage |
|---|---|---|
| `PageHeader` | `page_header.dart` | `PageHeader(title: 'Tus ventas', metrics: [MetricChip(...)], actions: [FilledButton(...)])` — single 64px row, title + inline metric chips + actions. No kicker/eyebrow, no display title, no mono subtitle. |
| `DataList<T>` | `data_list.dart` | `DataList(columns: [...], data: page, loading: isLoading, emptyState: EmptyState(...), onTap: (i) => ..., rowAccentColor: (i) => i.overdue ? cs.error : null)` — data table ≥900px / compact rows below, built-in skeleton + "Mostrando X de Y" + «Cargar más» footer. |
| `InfoCard` | `info_card.dart` | `InfoCard(title: 'Vencidas', accentColor: cs.error, child: ...)` — quiet card (surface + border + radius 18), optional 3px left accent bar for state. Never a tinted full-card fill. |
| `MetricChip` | `metric_chip.dart` | `MetricChip(label: 'Facturas', value: '24')` — label + mono value pill, `surfaceContainerHigh` bg. Lives inline in a `PageHeader` or `InfoCard` title row, never as a card background. |
| `IconBadge` | `icon_badge.dart` | `IconBadge(icon: LucideIcons.sparkles, color: cs.primary)` — the ONLY sanctioned pastel accent: 28/32px tinted container + dark icon, radius 12. |
| `SidePanelForm` | `../forms/side_panel_form.dart` | `SidePanelForm.show(context, title: 'Nuevo producto', fields: [...], onSubmit: (values) => ...)` — 480px right drawer with sticky footer, hosts `PForm` fields. Use for forms >~5 fields; `PFormDialog` stays for smaller ones. |

§1 bans are enforced app-wide as of this wave: no `mintContainer`/`peachContainer`/
`lavenderContainer` as a card/container fill outside `IconBadge`/chip contexts; no lateral
`TabBarView` slide transitions in feature screens (use the `AnimatedSwitcher` 150ms
fade-through pattern, e.g. `inventory_screen.dart`); no "Página X de Y" centered pager text
(compact pagers show a mono `page / totalPages` indicator next to the ‹ › buttons, or use
`DataList`'s built-in "Mostrando X de Y" + «Cargar más» footer); no `LinearGradient`/
`BoxShadow` outside chart/dataviz marks (the dashboard sparkline fade is the sole exemption).

## Enforcement

- No `Colors.*`, no hex literals outside `app_theme.dart`/`tokens.dart`.
  Everything through `cs.*`, `context.tokens`, or `AppTheme` tokens.
- Dashboard and collections are the `PistoTokens` exemplars; migrate other
  screens opportunistically when touched — no mass migration.
- Every screen checked in light AND dark.
- Future: a `custom_lint` rule banning `Color(0x…)`/`Colors.*` in `features/`.
