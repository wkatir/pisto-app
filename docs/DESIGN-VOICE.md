# Pisto — Design voice plan (de-slop v2: from "correct" to "custom")

Wave 0-2 (REDESIGN-PLAN.md) fixed structure: density, tables, no pastel card fills. The
app STILL reads AI-generated. This plan targets the second-order tells — the things that
make a UI look templated even when every individual rule is followed. Sized for Sonnet
subagents; §1 of REDESIGN-PLAN.md remains in force.

## 0. Diagnosis: why it still reads AI

1. **Template rhythm.** Every screen is the same sandwich: PageHeader → InfoCard →
   InfoCard → InfoCard, each with an IconBadge. Real products vary the register per
   screen: one signature element, then quiet support. Uniformity = generated.
2. **Card-itis.** Everything lives in a bordered box. Notion/Shopify use flat sections
   separated by hairline dividers and whitespace; boxes are reserved for things that need
   containment (a table, a KPI, a warning).
3. **IconBadge-itis.** A pastel icon chip next to every title is itself an AI tell (it's
   what every generated dashboard does). Icons should earn their place.
4. **Default Material chrome.** Stock TabBar indicator, stock dropdowns, stock dialogs,
   ink splashes, default focus/hover — framework smell, not product smell.
5. **Flat type hierarchy.** Titles, labels, body all mid-weight mid-size. No editorial
   confidence. The one thing that already works: big Spline mono figures — that IS the
   brand voice, underused.
6. **Default dataviz.** fl_chart out-of-the-box: default grid lines, default tooltips,
   default legend dots.
7. **Even spacing everywhere.** 16px between everything = no rhythm. Custom apps group
   tight (4-8) and break generous (32-48).

## 1. The Pisto voice (normative)

**"Los números mandan."** Pisto is an editorial, numbers-first interface: quiet warm
paper, confident mono figures, hairline structure, one illustration moment per journey.

- **Numbers are the heroes.** Key figures render BIG in Spline Sans Mono (headline sizes),
  labels small and quiet above them (`labelMedium`, `onSurfaceVariant`, +0.4 tracking).
  Everything else defers to them.
- **Paper, not boxes.** Default composition is FLAT on `surface`: section title +
  hairline divider (`outlineVariant`) + content + generous break (32-40px). `InfoCard`
  is demoted to three uses only: (a) KPI/stat blocks, (b) tables/lists needing a frame,
  (c) alerts with accent edge. If a screen has >4 bordered boxes visible, it's wrong.
- **Icons earn their place.** IconBadge survives ONLY: per-type identity in feeds
  (notifications, movements), emphasized KPI blocks (max 1-2 per screen), nav. Section
  titles, form sections, and plain cards get NO icon.
- **Structure via type, not chrome.** Hierarchy: `labelMedium` tracked-out quiet labels →
  `titleMedium` 600 section titles → big mono figures. Tabs = text-weight change +
  2px underline (custom, not stock TabBar indicator). Remove ink splashes on rows
  (use hover/pressed surface tint only).
- **One brand moment per journey.** The flat illustrations appear at: login (done), true
  empty states (done), and NOWHERE else. No decorative filler.
- **Dataviz dressed.** Charts: no vertical grid, horizontal grid `outlineVariant` 1px,
  axis labels `labelSmall` mono, brand palette from tokens, rounded bar caps 4, tooltip =
  small surface card with mono value. Same spec every chart.
- **Motion**: 120-150ms fades only (already enforced). Hover states subtle
  (`surfaceContainerHigh`), focus ring 2px `primary` offset 2 — visible, consistent.

## 2. Work packages (Sonnet subagents)

### W0 — Voice primitives (ONE agent, blocks the rest)
- `SectionHeading` (label-over-divider pattern: optional tracked quiet label, titleMedium,
  trailing action, hairline divider below, 32px top / 12px bottom rhythm).
- `BigFigure` (label small quiet + Spline mono figure at headlineMedium/Large + optional
  delta chip) — the KPI voice. `MoneyValue` stays for inline amounts.
- `PTabs` — custom tab row: text 600 when active + 2px primary underline (animated
  120ms), no stock TabBar indicator, no splash.
- Row interaction spec applied to `DataList`/`FinancialListRow`: no ink splash; hover
  `surfaceContainerHigh`; pressed slightly deeper; focus ring for keyboard.
- Chart theme helper `chartSpec(context)` (grid/axis/tooltip/palette constants) in
  `config/` for every fl_chart usage.
- Demote InfoCard: doc comment with the 3 sanctioned uses; add `FlatSection` variant?
  NO — flat is just SectionHeading + content, no new wrapper.

### W1 — Screen voice passes (parallel; each de-boxes, de-badges, re-types)
Acceptance per screen: ≤4 bordered boxes visible; ≤2 IconBadges outside feeds/nav; key
figure(s) via BigFigure; sections flat with SectionHeading; custom PTabs; charts via
chartSpec; both themes; analyze clean.
- **V1 Dashboard**: hero = one BigFigure moment (sales this month) + delta; KPI strip =
  3 compact BigFigures in ONE quiet card or flat row; attention list flat under
  SectionHeading; charts dressed; assistant card keeps sparkles as its identity (the one
  allowed non-feed badge) but flat-styled.
- **V2 Ventas + Cobros**: headers with figures as BigFigure-mini chips; tables framed,
  everything else flat; detail dialog: document typography (mono table numbers, hairline
  rules, no boxes inside boxes).
- **V3 Inventario + Compras**: same treatment; product form side panel: form sections via
  SectionHeading, no icon per section.
- **V4 Gastos + Reportes**: month total = BigFigure; report KPIs = BigFigures; every
  chart/table via chartSpec/DataList; flat sections between.
- **V5 AI + Notificaciones + Perfil/Config**: chat stays (at bar) minus any leftover
  stock chrome; forecast numbers as BigFigures with accent edges; notifications keep
  IconBadges (feed exemption); profile/settings fully flat (SectionHeading + rows,
  borders only around grouped rows if needed).
- **V6 Shell**: sidebar refinement — active item = 600 weight + tinted pill (subtle),
  remove any stock hover ink; mobile bottom nav custom heights/weights; bell badge spec.

### W2 — Proof
build_runner/analyze integration agent (box-count + badge-count grep heuristics, stock
TabBar audit, splash audit) → release build → browser walkthrough scoring each screen
against §1 acceptance → follow-ups.

## Execution notes
- Fold in the pending visual-walkthrough findings before W1 prompts are written.
- Login/auth untouched. Illustrations untouched. Palette/fonts untouched (they're right).
- Each agent prompt inlines: §1 voice rules, acceptance criteria, file list, "study W0
  primitives first", lean-code, no commit.
