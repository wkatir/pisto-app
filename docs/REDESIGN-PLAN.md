# Pisto — De-slop redesign plan (execution plan for Sonnet subagents)

Goal: the app must look like a **custom, professionally finished product** — not a generic
AI-generated MVP. Same warm palette, same identity (the login split-screen is the quality
bar — it stays). Every work package below is sized for one Claude Sonnet subagent.

Normative context every agent MUST read first: `docs/DESIGN.md`, `docs/CONVENTIONS.md`,
`docs/ARCHITECTURE.md`. Rules in §1 override anything that contradicts them.

---

## 1. Hard design rules (the "custom app" bar)

These extend DESIGN.md. Violations are defects.

### Surfaces & cards
- **Cards are quiet**: `surfaceContainerLow`/`surface` fill + 1px `outlineVariant` border +
  radius 18. That's it. **BANNED: full-card pastel fills** (mintContainer/peachContainer as
  the background of a whole card), tinted "glow" boxes, any `withValues(alpha:)` wash used
  as a card background, gradients of any kind, drop shadows.
- Pastel/semantic color appears ONLY as: (a) a small icon chip (28-36px, radius 12, tinted
  container + dark icon), (b) a `StatusChip`/badge, (c) a thin 3px left accent bar on a card
  when state matters (overdue, warning), (d) chart marks. Color is an accent, never a room.
- One card style per screen region. No mixing bordered + borderless + tinted variants.

### Density & information design
- **Info first**: a list row is 52-64px tall and carries 3-5 aligned data points (name,
  meta, status chip, amount right-aligned in mono). The current 90px 3-datum cards are the
  #1 "generic MVP" tell — kill them everywhere.
- Wide screens: operational lists render as **data tables** (aligned columns, 44-52px rows,
  sticky header row styled `labelMedium` + `onSurfaceVariant`, subtle row hover
  `surfaceContainerHigh`, zebra optional OFF). Narrow: same data as compact rows.
- Numbers: always Spline Sans Mono, right-aligned in tables, thousands separators, integer
  quantities without ".00".
- Pagination: "Mostrando X de Y" + «Cargar más» or compact ‹ › — never "Página 1 de 2"
  centered alone.

### Page anatomy
- **Compact page header**: single-line title (`titleLarge`, 22px), inline metric chips to
  the right (count · total), primary action button far right. Max header height ~64px.
  BANNED: kicker labels ("OPERACIÓN"), 40px display titles, mono subtitles that eat 140px.
- Section titles inside a page: `titleMedium` + optional trailing action, 24px top gap.
- Forms: dialogs only for ≤5 fields; larger forms use a right-side panel (480px drawer)
  with sticky footer actions. Field spacing 16, grouped with section labels.

### Motion & polish
- Transitions: 120-150ms fade or fade-through only. BANNED: lateral slides between tabs,
  stagger cascades, scale bounces.
- Every interactive element: hover state (web), focus ring (`primary` 2px outside), pressed
  state. No dead zones — whole rows clickable.
- Empty states: existing flat illustrations at ≤160px + one sentence + one CTA. Loading:
  skeletons that mirror the real layout (never fake zeros). Errors: inline, human Spanish
  (voseo), retry affordance.

### Code quality (no repeated logic)
- Shared primitives (§2) are the ONLY way to build lists/tables/headers/cards. If a screen
  hand-rolls a row/card/header variant that a primitive covers, the work is wrong.
- No logic duplicated across screens: formatting through `core/utils/formatters.dart`,
  status labels through model getters, colors through tokens.

---

## 2. Wave 0 — shared primitives (ONE agent, blocks everything else)

Build in `lib/shared/widgets/` (extending, not duplicating, what exists):

| Primitive | Spec |
|---|---|
| `PageScaffold` / rework `PageHeader` | Compact anatomy per §1: title + metric chips + actions in one 64px row. Kills kicker/display titles app-wide. |
| `DataList<T>` | The workhorse: takes column specs + row builder; renders data table ≥900px, compact rows below; sticky header, hover, full-row tap, right-aligned mono money columns, built-in skeleton + empty + "Cargar más" footer. Wraps `Paginated<T>`. |
| `InfoCard` | Quiet card per §1 (surface + border + radius 18), optional title row + trailing action, optional 3px accent edge. Replaces every hand-rolled tinted Container. |
| `MetricChip` | Small header stat: label + mono value, `surfaceContainerHigh` bg, radius 20. |
| `IconBadge` | The only sanctioned pastel: 32px tinted container + dark Lucide icon, radius 12. |
| `SidePanelForm` | Right drawer (480px, full height, sticky footer) hosting the existing `PForm`; dialogs stay for tiny forms. |

Also: purge helpers that fight §1 (`AppTheme.tintBg` full-card uses become accent-bar or
IconBadge uses; keep tintBg for chips only). `flutter analyze` clean. Document each
primitive with a 3-line usage comment.

## 3. Wave 1 — screen packages (parallel Sonnet agents, one per package)

Every package: replace hand-rolled cards/rows/headers with Wave 0 primitives, apply §1,
delete the dead local variants, keep all behavior/providers intact, `flutter analyze`
clean. Do not touch files outside the package.

- **P1 Dashboard** (`features/dashboard/`): hero + KPI grid → quiet InfoCards with
  IconBadges (no pastel-filled stat cards, no glow), "Tu resumen" assistant card restyled
  quiet with sparkles IconBadge, attention list as dense rows, chart card via InfoCard,
  compact header. The sparkline `LinearGradient` fade is allowed (dataviz exemption) but
  verify it reads subtle.
- **P2 Ventas** (`features/sales/screens/`): invoices/customers/credit-notes → `DataList`
  (columns: nº, cliente, fecha, estado, total), compact header with `salesHeaderMeta` as
  MetricChips, invoice detail dialog polished as document (keep), customer form → SidePanelForm.
- **P3 Inventario** (`features/inventory/`): 6 tabs onto `DataList` (productos: sku,
  nombre, categoría, stock, precio; movimientos: fecha, tipo, producto, cantidad),
  product form → SidePanelForm, category/warehouse/unit forms stay dialogs (small),
  low-stock accent via 3px edge not tinted rows.
- **P4 Cobros + Compras** (`features/collections/`, `features/purchases/`): receivables,
  payables, orders, suppliers → `DataList`; aging buckets → quiet InfoCards with mono
  figures; payment/receive flows keep dialogs (small forms).
- **P5 Gastos + Reportes** (`features/expenses/`, `features/reports/`): expenses →
  `DataList` with category chip; total card → InfoCard (neutral at 0); reports tables →
  DataList table styling, full-width, integer stock; export buttons aligned in header.
- **P6 AI + Notificaciones + Perfil/Config** (`features/ai/`, `features/notifications/`,
  `features/profile/`, `features/settings/`): chat container quiet (no tinted panel), scan
  & forecast screens onto InfoCards (forecast risk = accent edge, not colored box),
  notifications rows dense with IconBadge per type, profile/settings sections as InfoCards
  with proper section titles.

## 4. Wave 2 — integration & proof

1. One agent: `dart run build_runner build` + `flutter analyze` + fix all cross-package
   drift; grep-audit that zero `mintContainer/peachContainer/lavenderContainer` full-card
   fills and zero hand-rolled headers remain; update `docs/DESIGN.md` §cards with the final
   primitive list.
2. Browser walkthrough agent (read-only, Chrome MCP): screenshot every screen light+dark,
   desktop+narrow; verdict per screen against §1; file follow-ups for anything still
   reading "generic".
3. Restart `flutter run`; report.

## Execution notes for the orchestrator

- Wave 0 must fully land (analyze clean) before Wave 1 spawns; Wave 1 packages are
  file-disjoint and safe in parallel; only the Wave 2 integration agent runs build_runner.
- Subagent model: Claude Sonnet. Each prompt must inline: §1 rules summary, the package
  file list, "read docs/DESIGN.md + study the Wave 0 primitives before writing", lean-code
  rules, and "do not commit".
- The login/auth screens are OFF-LIMITS (already at bar).
