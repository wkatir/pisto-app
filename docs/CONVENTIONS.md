# Pisto: Coding conventions

Normative for humans and AI assistants. If generated code violates this file, regenerate it.

## Language

- Code, comments, identifiers, commits, PRs: **English**.
- UI strings: **Spanish** (El Salvador). Currency USD, `$1,234.56`.
- Commits: conventional format `type(scope): subject`, imperative, no trailing period.

## Lean code (mandatory)

1. **Fail loud: no fallbacks that hide bugs.** Before writing a fallback ask: *if this
   branch runs, is it a normal case or a bug?* If it's a bug, let it crash with a clear
   stack trace.
   - Banned: `catch { return null/[]/{} }`, `res?.data ?? []` on contracts we control,
     `x || default` papering over a value that must exist, optional chaining to dodge a
     crash, `catch` that logs and continues.
   - Fine: defaults for genuinely optional input (`opts.limit ?? 100`), `find(...) ?? null`
     when "not found" is a handled outcome.
2. **Comments: only non-obvious WHY.** No narration (`// create the user`), no restating
   code, no commented-out code, no TODO noise. If a comment explains WHAT, rename instead.
2b. **No em dashes in prose.** Not in docs, comments, commit messages, PR descriptions or
   UI copy. The em dash is the clearest tell of machine-written text; a comma, a colon, a
   full stop or parentheses always work. Applies to `—` and to `--` used as one.
   Exception: `—` as a placeholder for an empty table cell is typography, not prose.
3. **No debug debris.** No `console.log` / `print` / `debugPrint` in committed code.
4. **Small diffs.** Prefer the smallest, most debuggable change. Don't add abstractions for
   one call site; do use the existing shared abstractions (crud factory, form kit) instead
   of copy-pasting.

## Backend specifics

- Validation with Valibot at the route boundary: every body/query/param is validated;
  services trust their typed inputs (no re-checking).
- `businessId` from JWT context only. Any query without a `business_id` filter is a bug.
- Money: `decimal.js`, never float arithmetic.
- New endpoint checklist: schema → service function → route → (if standard CRUD, use the
  factory) → add to module routes file. No inline queries in routes.

## Frontend specifics

- No `Map<String, dynamic>` outside repositories. Freezed model or it doesn't ship.
- No `setState` for async data. Riverpod `AsyncNotifier` + `AsyncValueWidget`.
- Standard forms via the form kit; bespoke layouts may compose kit fields directly.
- Packages via CLI (`flutter pub add`), never hand-edit pubspec.yaml.

## Design ("no AI slop")

Audience: dueños de PYMES salvadoreñas, warm, trustworthy, plain-spoken. Shopify admin +
Notion, not a crypto dashboard. **Full design system: `docs/DESIGN.md` (normative)**:
palette with contrast rules, typography, radii/spacing, surface ladder, illustration style.

- Palette: warm cream/pastel (mint, peach, lavender) from AppTheme/`PistoTokens`.
  **Never** hardcode `Colors.*` or hex in widgets: `cs.*` / `context.tokens` only.
  Dark mode is warm brown-charcoal (#1C1916 base) and must work on every screen.
- Cards: solid pastel fills, subtle warm borders, **no elevation/shadow, no gradients**.
- Radii: cards 18, pill chips 20, buttons/inputs 14, icon tiles 12.
- Type: Figtree body, Spline Sans Mono for numbers/money (SemiBold for totals).
- Banned: stagger/entrance animation chains, glassmorphism, decorative shadows or glows,
  emoji in UI, gradient buttons, uppercase-tracking "HERO" labels, three-adjective
  marketing copy in empty states.
- Microcopy: Spanish, direct, human. "Aún no tienes ventas", not "¡Ups! Parece que…".
- Every screen must be checked in light AND dark before it's done.

## Docs discipline

- `docs/ARCHITECTURE.md`: structure rules (normative).
- `docs/CONVENTIONS.md`: this file (normative).
- `docs/RATIONALE.md`: why these rules exist, with primary sources quoted. Consult it before
  arguing with a rule, and extend it when adding one: a rule without a source is an opinion.
- `docs/PLAN.md`: strategy/roadmap (descriptive, update as decisions change).
- `docs/DTE.md`: electronic invoicing design.
- A change that alters architecture must update the doc in the same PR.
