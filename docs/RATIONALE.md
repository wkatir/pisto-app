# Pisto: Rationale

Why the rules in `CONVENTIONS.md` and `ARCHITECTURE.md` are what they are. Every rule here
is backed by a primary source: official documentation, a linter rule, or a published style
guide. Nothing in this file rests on "because we said so".

Each claim is tagged:

- **[DOC]**: stated explicitly in official documentation. Quoted verbatim.
- **[SOURCE]**: verified in the official source repository, but not written in the prose docs.
- **[ISSUE]**: official issue/PR tracker of the project. Not documentation.
- **[INFERENCE]**: our reasoning from a **[DOC]** fact. Sound, but not something the vendor
  wrote down. Treated as weaker evidence on purpose.

If a future maintainer disagrees with a rule, argue with the source, not with the author.

---

## 1. No `bool _loading` + `setState` for async data

`CONVENTIONS.md`: *"No `setState` for async data. Riverpod `AsyncNotifier` + `AsyncValueWidget`."*

**[DOC]** Riverpod states the goal directly, in its own tutorial:

> "Notice how we never had to write a `try/catch` or write code such as `isLoading = true/false`."
> (<https://riverpod.dev/docs/tutorials/first_app>)

**[DOC]** Providers handle errors natively, which is why service calls are not wrapped in
`try/catch`:

> "We did not catch errors. This is voluntary, as providers natively handle errors."
> (<https://docs-v2.riverpod.dev/docs/essentials/first_request>)

**[DOC]** The manual pattern has a documented failure mode. `setState` after the widget is
gone throws:

> "It is an error to call this method after the framework calls dispose()."

and the Flutter API docs explicitly prefer cancellation over an `mounted` guard:

> "it is better practice to cancel whatever work might trigger the setState() rather than
> merely checking for mounted before calling setState()"
> (<https://api.flutter.dev/flutter/widgets/State/setState.html>)

**[DOC]** The same pattern drags `BuildContext` across an `await`, which the Dart linter
forbids:

> "Do not use `BuildContext` across asynchronous gaps."

The rule notes these gaps "are some of the easiest to overlook when writing code" and lead to
"difficult-to-diagnose crashes".
(<https://dart.dev/tools/linter-rules/use_build_context_synchronously>)

**[DOC]** When rendering `AsyncValue`, order matters, this is a real bug if ignored:

> "The order of operation matters! If using the syntax used above, it is important to check
> for values *before* checking for errors and to handle the loading state last."
> (<https://riverpod.dev/docs/tutorials/first_app>)

**[INFERENCE]** Two further arguments are commonly made for this rule and are **not** in any
official doc, we state them as reasoning, not authority:

- Out-of-order responses. Riverpod disposes and cancels work that is no longer used
  (<https://riverpod.dev/docs/how_to/cancel>), so a stale response cannot overwrite a fresh
  one; with manual flags you must handle that yourself. The docs describe the cancellation,
  not this consequence.
- Impossible states. `AsyncValue` is a sealed class with three variants, so the compiler
  forces exhaustive handling; two independent booleans permit `loading == true` together with
  a non-null error. The sealed-class design is documented
  (<https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html>); this
  conclusion is ours.

---

## 2. Prefer `MediaQuery.sizeOf(context)` over `MediaQuery.of(context).size`

**[DOC]** The Flutter API docs make the recommendation and the reason explicit:

> "Querying using `MediaQuery.of` will cause your widget to rebuild automatically whenever
> *any* field of the `MediaQueryData` changes"

> "Therefore, unless you are concerned with the entire `MediaQueryData` object changing,
> prefer using the specific methods (for example: `MediaQuery.sizeOf` and
> `MediaQuery.paddingOf`), as it will rebuild more efficiently."
> (<https://api.flutter.dev/flutter/widgets/MediaQuery-class.html>)

Concretely: opening the keyboard changes `viewInsets`, which rebuilds every widget using
`MediaQuery.of(context).size` and none of those using `sizeOf`.

---

## 3. Extract shared widgets; prefer widgets over helper functions; use `const`

**[DOC]** Flutter's performance guide:

> "Use `const` constructors on widgets as much as possible, since they allow Flutter to
> short-circuit most of the rebuild work."

> "Avoid overly large single widgets with a large `build()` function. Split them into
> different widgets based on encapsulation but also on how they change"

> "To create reusable pieces of UIs, prefer using a `StatelessWidget` rather than a function."

> "When `setState()` is called on a `State` object, all descendent widgets rebuild. Therefore,
> localize the `setState()` call to the part of the subtree whose UI actually needs to change."
> (<https://docs.flutter.dev/perf/best-practices>)

Note the honest limit: Flutter justifies extraction by **encapsulation and rebuild cost**. It
says nothing about DRY as an architectural virtue. Removing a copy-pasted widget is good
engineering judgement; only the performance half is vendor-backed.

---

## 4. `app.onError` must re-raise `HTTPException` with its own status

**[DOC]** Hono's documented pattern:

```ts
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    // Get the custom response
    return err.getResponse()
  }
  //...
})
```
(<https://hono.dev/docs/api/exception>)

**[DOC]** Without that branch every thrown exception collapses into the generic fallback,
because that is exactly what the documented default handler does: `return c.text('Custom
Error Message', 500)` (<https://hono.dev/docs/api/hono>). And middleware throws do reach
`onError`:

> "if the handler or any middleware throws, hono will catch it and either pass it to your
> app.onError() callback or automatically convert it to a 500 response"
> (<https://hono.dev/docs/guides/middleware>)

**[SOURCE]** A malformed JSON body is one of these cases. Hono's validator throws
`HTTPException(400, { message: 'Malformed JSON in request body' })` (`src/validator/validator.ts`
in `honojs/hono`). This is in the source, not in the prose docs, so without the `instanceof`
branch, a client typo returns 500 and looks like a server bug.

**[DOC]** One caveat drove our implementation choice:

> "HTTPException.getResponse is not aware of Context."
> (<https://hono.dev/docs/api/exception>)

Because this app sets CORS and security headers through context middleware, we return
`c.json({ error: err.message }, err.status)` instead of `err.getResponse()`. That preserves the
headers **and** keeps the API-wide `{ error: string }` error shape. The `instanceof` check is
the doctrine; `getResponse()` is not mandatory.

---

## 5. Mounted sub-app paths concatenate: never repeat the prefix

**[DOC]** Hono's routing guide shows grouping with relative paths inside the sub-app:

```ts
const book = new Hono()
book.get('/', (c) => c.text('List Books')) // GET /book
app.route('/book', book)
```

and the alternative, absolute paths mounted at the root:

```ts
book.get('/book', (c) => c.text('List Books')) // GET /book
app.route('/', book) // Handle /book
```
(<https://hono.dev/docs/api/routing>)

Mixing the two (absolute paths inside a sub-app mounted under a prefix) produces
`/prefix/prefix/...`. That was a real bug in this codebase: uploads were served at
`/api/v1/uploads/uploads/:folder/:filename` while the API handed clients
`/uploads/:folder/:filename`. Every uploaded image 404'd.

**[DOC]** Middleware and route ordering is by registration, and a matching handler stops the
chain:

> "Handlers or middleware will be executed in registration order." … "When a handler is
> executed, the process will be stopped."
> (<https://hono.dev/docs/api/routing>)

**[INFERENCE]** Hono documents no official recipe for exempting one route from a wildcard
middleware. Registration order can be exploited to do it, but that is implicit and fragile;
applying the guard per-route is explicit and survives reordering. Neither is written down by
Hono as a recommendation.

---

## 6. One response envelope: `{ data }` on success, `{ error }` on failure

**[DOC]** Hono publishes **no** recommendation about response shape: `hono.dev/docs/guides/best-practices`
covers controllers, `app.route()` and `factory.createHandlers()`, nothing about envelopes. Do
not claim a "Hono convention"; there isn't one.

The rule comes from industry style guides that are citable:

**[DOC]** Google JSON Style Guide:

> "Container for all the data from a response. […] A JSON response should contain either a
> `data` object or an `error` object, but not both."
> (<https://google.github.io/styleguide/jsoncstyleguide.xml>)

**[DOC]** JSON:API: a document must contain at least one of `data`, `errors`, `meta`, and:

> "The members `data` and `errors` **MUST NOT** coexist in the same document."
> (<https://jsonapi.org/format/>)

This API already returns `{ error: "..." }` on failure, so `{ data: ... }` on success is the
consistent half of the same convention. Three inventory list endpoints returned bare arrays and
were brought in line.

---

## 7. Model JSON: structured outputs, and what to do when the provider lacks them

`CLAUDE.md`: *"JSON del modelo SIEMPRE con structured outputs."* The reason is a documented
capability difference, not taste.

**[DOC]** OpenAI, on JSON mode vs Structured Outputs:

> "Structured Outputs is the evolution of JSON mode. While both ensure valid JSON is produced,
> only Structured Outputs ensure schema adherence."

> "We recommend always using Structured Outputs instead of JSON mode when possible."
> (<https://developers.openai.com/api/docs/guides/structured-outputs>)

So `json_object` guarantees **syntax** (it parses), never **shape** (the fields you asked for,
typed as you asked). Downgrading to it silently converts a provider error into malformed
business data.

**[DOC]** DeepSeek does not support `response_format: { type: "json_schema" }` at all. Its API
reference lists the only permitted values:

> **Possible values:** [`text`, `json_object`]
> (<https://api-docs.deepseek.com/api/create-chat-completion/>)

**[DOC]** But it *does* offer strict schema adherence through tool calling, against the beta
base URL:

> "the model strictly adheres to the format requirements of the Function's JSON schema when
> outputting a tool call"
> (<https://api-docs.deepseek.com/guides/tool_calls>)

Documented constraints of that strict mode: every property must be listed in `required`,
`"additionalProperties": false` is mandatory, and `minLength`/`maxLength`/`minItems`/`maxItems`
are unsupported. These match OpenAI's strict-function constraints closely, so one schema serves
both providers.

**Rule.** Prefer, in order: `response_format: json_schema` where supported → a strict tool call
→ and only as a last resort `json_object`, which then **requires** validating the payload
ourselves before use. Never degrade silently between levels.

**[SOURCE]** One practical constraint we hit implementing this, not found in the prose docs:
DeepSeek rejects a forced `tool_choice` while thinking mode is active, with
`"Thinking mode does not support this tool_choice"`. Strict-tool structured output therefore
requires `thinking: { type: 'disabled' }` on DeepSeek models. That field is provider-specific,
so it is gated by model name and never sent to OpenAI. Discovered empirically against the live
API; treat it as a fact about the current API, not a stable contract.

**[DOC]** If level three is ever used, DeepSeek's JSON mode has three hard requirements, the
second is the one everyone forgets:

> "Include the word 'json' in the system or user prompt, and provide an example"
> "Set the `max_tokens` parameter reasonably to prevent the JSON string from being truncated midway"

and a warning worth knowing:

> "When using the JSON Output feature, the API may occasionally return empty content."
> (<https://api-docs.deepseek.com/guides/json_mode>)

---

## 8. Vision is a provider capability, not a code problem

**[DOC]** DeepSeek V4 cannot read images:

> "DeepSeek V4 is text-only"
> (<https://api-docs.deepseek.com/quick_start/agent_integrations/github_copilot/>)

Its message schema accepts a plain content string in all four roles: there is no content-parts
array and no `image_url` variant
(<https://api-docs.deepseek.com/api/create-chat-completion/>).

Receipt scanning therefore cannot work on this provider, and no amount of code changes it. The
correct engineering response is a clear, actionable error: not a mock, not a silent fallback,
not a degraded "best effort" parse. Swapping the provider for a vision-capable model is a
configuration decision, and belongs in `.dev.vars`, not in a `try/catch`.

---

## 9. Tenant-owned files: never a public bucket

**[DOC]** R2 gives no per-object ACL. Cloudflare puts authorization in your code:

> "This logic lives within your Worker's code, as it is your application's job to determine
> user privileges."
> (<https://developers.cloudflare.com/r2/api/workers/workers-api-usage/>)

**[DOC]** A public bucket is all-or-nothing, and overrides your other controls:

> "Disable public access to your [r2.dev] subdomain when using products like WAF or Cloudflare
> Access. If you do not disable public access, your bucket will remain publicly available."

> "Public access through `r2.dev` subdomains is rate-limited and should only be used for
> development purposes."
> (<https://developers.cloudflare.com/r2/buckets/public-buckets/>)

**[DOC]** Two supported ways to serve protected objects:

1. **Worker with the R2 binding**: validate the JWT and the tenant, then stream the object.
   Documented in `workers-api-usage` above. This is what Pisto does today.
2. **Presigned URLs**: *"an S3 concept for granting temporary access to objects without
   exposing your API credentials"*, expiry from 1 second to 7 days, with the explicit warning:
   *"Treat presigned URLs as bearer tokens—anyone possessing the URL can perform the specified
   operation until expiration."*
   (<https://developers.cloudflare.com/r2/api/s3/presigned-urls/>)

**[DOC]** Cloudflare Access does **not** apply here: it is scoped to "specific users, groups or
applications within your organization", and its own R2 tutorial redirects anonymous end-user
access to presigned URLs
(<https://developers.cloudflare.com/r2/tutorials/cloudflare-access/>).

**[INFERENCE]** Presigned URLs are the better long-term fit for this app: the client receives a
plain URL with no headers, so the same link works in Flutter web, Android and iOS, in
`Image.network`, in `cached_network_image`, and in a browser download link for PDFs: no CORS
preflight, no reliance on header support. This conclusion is ours; Cloudflare documents the
mechanism, not this comparison. It requires R2 S3 credentials and does not work against the
simulated bucket in `wrangler dev`, which is why option 1 is in place today.

### Client-side consequences of option 1

**[DOC]** Headers are supported by both image widgets:

> "An optional `headers` argument can be used to send custom HTTP headers with the image request."
> (<https://api.flutter.dev/flutter/widgets/Image/Image.network.html>)

`CachedNetworkImage.httpHeaders`: "Optional headers for the http request of the image url."
(<https://pub.dev/documentation/cached_network_image/latest/cached_network_image/CachedNetworkImage/httpHeaders.html>)

**[ISSUE]** On web this only works because of flutter/flutter#57187, fixed by PR #85954
("Flutter web add support for NetworkImage headers"). Before that, the docs literally said
headers were unused on web. This is issue-tracker evidence, not documentation.

**[DOC]** Two constraints follow, and they are the price of option 1:

> "Flutter on the Web platform can not fetch images from other origins […] unless the image
> hosting origin explicitly allows so."

and the HTML-element fallback for cross-origin images is incompatible with auth: *"The
`headers` argument must be null or empty."*
(<https://api.flutter.dev/flutter/widgets/Image/Image.network.html>)

Plus: `cached_network_image` has "minimal support for web. It currently doesn't include
caching" (<https://pub.dev/packages/cached_network_image>).

---

## 10. Visual hierarchy: one element wins, the rest defer

The "generic AI dashboard" look is a hierarchy failure, and Material names the symptom:

**[DOC]** > "An oversaturated look can result in using only the base color roles of primary,
> secondary, or tertiary. To help with your color hierarchy, apply color schemes to include
> less vibrant container colors and outline roles."

> "To ensure a better user experience, use more vibrant primary colors to signify actions of
> greater prominence in your app's visual hierarchy."

> "you can select a color to represent interactive components, allowing your brand colors to be
> used more sparingly."
> (<https://developer.android.com/design/ui/mobile/guides/styles/color>)

**[DOC]** Size is an explicit hierarchy mechanism, and sameness is an explicit grouping
mechanism, which is why a row of identical stat cards reads as "one undifferentiated group":

> "Attention is drawn to elements by making them larger than nearby elements."
> "Content groups are created by making elements the same size and positioning them together."
> "When defining grid items, adjust column spans to emphasize some items over others."
> (<https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts>)

**Rule.** Every screen has exactly one dominant element, normally *the* number the owner opens
the screen for. Everything else steps down. Repeated equal-weight blocks are the failure mode,
not the layout.

**[INFERENCE]** That a large solid colour area (rather than many small accents) is what makes
the login work is our reading of the "used more sparingly" / "oversaturated" guidance. Material
does not describe that composition.

## 11. Type scale: display is for the hero number, never for section headings

**[DOC]** > "As the largest text on the screen, large display styles are reserved for short,
> important text passages, or numerals."

> "They can be used for the main heading of the screen. **Don't use large display styles for
> section or cluster headings.**"

> "Headlines are best-suited for short, high-emphasis text."
> "Use titles for brief, medium-emphasis text… Use titles for UI elements like cards or lists."
> "Label styles are smaller, utilitarian styles, used for things like the text inside components"
> (<https://developer.android.com/design/ui/tv/guides/styles/typography>)

**[DOC]** Canonical sizes (sp): Display 57/45/36 · Headline 32/28/24 · Title 22/16/14 ·
Body 16/14/12 · Label 14/12/11. And you are not obliged to use them all:

> "Your product will likely not need all 15 default styles from the Material Design type scale."
> (<https://developer.android.com/develop/ui/compose/designsystems/material3>)

**[DOC]** > "Hierarchy is communicated through differences in font weight, size, line height, and
> letter spacing." (same source).

**Rule.** One display-scale element per screen, and it is a figure, not a heading. Section
headings are `titleMedium`. A screen whose largest text is 22px has no anchor.

**[NO SOURCE]** "Use big display sizes to break visual monotony" is *not* documented anywhere.
Display is justified by the importance of the content, not by the boredom of the layout.

## 12. Cards are for coherent single items, not for wrapping every datum

**[DOC]** > "It is the focus on portraying a single piece of content that distinguishes `Card`
> from other containers." (<https://developer.android.com/develop/ui/compose/components/card>)

**[DOC]** The only explicit cards-vs-lists rule Google publishes is in archived Material 1:

> "Lists present multiple line items vertically as a single continuous element."
> "If more than three lines of text need to be shown in list tiles, use cards instead."
> (<https://m1.material.io/components/lists.html>) *(archived M1, cite as such)*

**[NO SOURCE]** Material 3 publishes **no** warning against card overuse and **no** cards-vs-lists
guidance. Our "≤4 bordered boxes per screen" limit in `DESIGN-VOICE.md` is a product decision,
not a standard. Say so when defending it.

**[DOC]** For wide layouts, the canonical pattern for a list of records is list-detail, not a
grid of cards:

> "Expanded-width displays accommodate both the list and detail at the same time."
> "For expanded width, give 70% of the space to the main content, 30% to the supporting content."
> (<https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts>)

## 13. Decorative icons: a product decision, not a standard

This is the rule the owner cares most about, and honesty matters more than a borrowed citation.

**[NO SOURCE]** Neither Material 3 nor Apple's HIG prohibits decorative icons. There is no
official sentence saying "don't put an icon in a tinted box next to every title". **Pisto bans
it as a product decision**: because it is the visual signature of generated dashboards, and
because our own audit found the same 36×36 tinted-icon tile repeated 13 times in one view.

What *is* documented, and is the closest support:

**[DOC]** > "A system icon, or UI icon, symbolizes a command, file, device, or directory."
> "Each icon is reduced to its minimal form, with every idea edited to its essence."
> (<https://m1.material.io/style/icons.html>) *(archived M1)*

**[DOC]** WCAG normatively recognises "pure decoration" as a category exempt from contrast
requirements (SC 1.4.3, Incidental). An element exempt from contrast because it conveys nothing
is, by the standard's own definition, conveying nothing.

**[INFERENCE]** An icon with no referent (no command, no object, no type identity) falls
outside the documented purpose of an icon. Ours, not Google's.

**Rule.** An icon must identify a type in a feed, mark a state, or label an action. A row of
identical icons down a list identifies nothing (the column already does). Prefer the login's
form: bare inline icon at ~17px, no container.

## 14. Contrast, target size, spacing, motion

**[DOC]** SC 1.4.3 Contrast (Minimum), AA:
> "The visual presentation of text and images of text has a contrast ratio of at least 4.5:1"
with large text (18pt, or 14pt bold) at 3:1, and "pure decoration" exempt.
(<https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html>)

**[DOC]** SC 1.4.11 Non-text Contrast, AA: **3:1** for "Visual information required to identify
user interface components and states" and for "Parts of graphics required to understand the
content". (<https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html>)

This is the criterion that chart labels and status chips must meet, and the one violated by
white text over the yellow/green entries of `chartPalette`.

**[DOC]** SC 2.5.8 Target Size (Minimum), AA: "at least 24 by 24 CSS pixels", with spacing,
equivalent, inline, user-agent and essential exceptions.
(<https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html>)

**[DOC]** Material is stricter and is what we follow: "Touch targets should be at least
48 x 48 dp. In most cases, there should be 8dp or more space between them."
(<https://m1.material.io/layout/metrics-keylines.html>) *(archived M1)*

**[DOC]** Spacing grid: "Android UI utilizes an 8 dp grid for layout, components, and spacing."
and "a 4 dp grid is better for smaller elements such as icons".
(<https://developer.android.com/design/ui/mobile/guides/layout-and-content/grids-and-units>)

Our 4/8/12/16/20/24/32 scale is consistent with that; the exact steps are our choice, the
"multiples of 4" constraint is documented.

**[DOC]** Breakpoints are Material's window size classes, Flutter publishes none of its own:
compact `< 600dp` · medium `600–839` · expanded `840–1199` · large `1200–1599` · extra-large
`≥ 1600`. (<https://developer.android.com/develop/ui/compose/layouts/adaptive/window-size-classes>)

**[DOC]** Motion duration tokens exist as a documented set (short1 50ms → extralong4 1000ms):
(<https://api.flutter.dev/flutter/material/Durations-class.html>)

**[INFERENCE]** Reading the `short` band (50–200ms) as "the range for UI transitions" is our
interpretation; the tokens are documented, the rule is not.

**[DOC]** The strongest source for treating decorative motion differently from meaningful motion
is Apple's Reduced Motion criteria:

> "Is the animation included purely for stylistic or decorative effect? If so, consider stopping
> it entirely when the user's system setting indicates a need or preference for reduced motion."

> "If the motion itself conveys some meaning… don't remove the animation entirely. Instead,
> consider providing a new animation that avoids motion… such as a dissolve, highlight fade, or
> color shift."
> (<https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria/>)

**[DOC]** WCAG 2.2 SC 2.3.3 (AAA): "Motion animation triggered by interaction can be disabled,
unless the animation is essential". (<https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html>)

Flutter exposes `MediaQueryData.disableAnimations`: "Whether the platform is requesting that
animations be disabled or reduced as much as possible"
(<https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html>). Honouring it
is our rule, supported by those two sources.

### Method note

`m3.material.io` and `developer.apple.com/design/...` are client-rendered and could not be
quoted verbatim. Citations above come from official Google mirrors of the same material
(`developer.android.com`), from `api.flutter.dev`, or from archived Material 1
(`m1.material.io`), marked as such at each use. Where a claim could not be verified against a
fetchable source, it is labelled `[NO SOURCE]` rather than dressed up.

---

## Sources

Flutter / Dart
- <https://docs.flutter.dev/perf/best-practices>
- <https://api.flutter.dev/flutter/widgets/MediaQuery-class.html>
- <https://api.flutter.dev/flutter/widgets/State/setState.html>
- <https://api.flutter.dev/flutter/widgets/Image/Image.network.html>
- <https://dart.dev/tools/linter-rules/use_build_context_synchronously>

Riverpod
- <https://riverpod.dev/docs/tutorials/first_app>
- <https://riverpod.dev/docs/how_to/cancel>
- <https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html>

Hono
- <https://hono.dev/docs/api/exception>
- <https://hono.dev/docs/api/routing>
- <https://hono.dev/docs/guides/middleware>
- <https://hono.dev/docs/guides/validation>

Cloudflare R2
- <https://developers.cloudflare.com/r2/api/workers/workers-api-usage/>
- <https://developers.cloudflare.com/r2/buckets/public-buckets/>
- <https://developers.cloudflare.com/r2/api/s3/presigned-urls/>

Model providers
- <https://developers.openai.com/api/docs/guides/structured-outputs>
- <https://api-docs.deepseek.com/api/create-chat-completion/>
- <https://api-docs.deepseek.com/guides/tool_calls>
- <https://api-docs.deepseek.com/guides/json_mode>

API shape
- <https://google.github.io/styleguide/jsoncstyleguide.xml>
- <https://jsonapi.org/format/>

Design
- <https://developer.android.com/design/ui/mobile/guides/styles/color>
- <https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts>
- <https://developer.android.com/develop/ui/compose/layouts/adaptive/window-size-classes>
- <https://developer.android.com/design/ui/tv/guides/styles/typography>
- <https://developer.android.com/develop/ui/compose/designsystems/material3>
- <https://developer.android.com/develop/ui/compose/components/card>
- <https://developer.android.com/design/ui/mobile/guides/layout-and-content/grids-and-units>
- <https://m1.material.io/components/lists.html> *(archived)*
- <https://m1.material.io/style/icons.html> *(archived)*
- <https://m1.material.io/layout/metrics-keylines.html> *(archived)*
- <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html>
- <https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html>
- <https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html>
- <https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html>
- <https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria/>
- <https://api.flutter.dev/flutter/material/Durations-class.html>
- <https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html>
- <https://docs.flutter.dev/ui/adaptive-responsive>
