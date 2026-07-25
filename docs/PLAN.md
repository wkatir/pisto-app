# Pisto — Plan estratégico y técnico (julio 2026)

Basado en: auditoría completa del monorepo, investigación del dataset
[nvidia/Nemotron-Personas-El-Salvador](https://huggingface.co/datasets/nvidia/Nemotron-Personas-El-Salvador),
datos de mercado MYPE de El Salvador 2024-2026, y mejores prácticas AI-native mid-2026.

---

## 1. Validación del painpoint (la parte honesta)

**El painpoint es real. El formato propuesto (desktop) no encaja con el segmento que lo sufre.**

Evidencia del mercado salvadoreño:

- MYPEs = ~42.9% del PIB y >70% del empleo; **~76% operan informalmente**, 69% de las
  microempresas están en subsistencia (CONAMYPE / Estado de la MYPE 2024).
- ~97% de tiendas llevan cuentas en **cuaderno de papel o "en la cabeza"**. Cerrar cuentas
  del día toma 2-3 horas; con herramienta digital baja a <30 min (BID).
- Acceso a internet: **abrumadoramente móvil** (76.9% penetración, casi todo vía smartphone;
  banda fija/PC es minoría urbana formal). Una tiendera no se sienta frente a una PC.
- Pagos: Chivo/Bitcoin está muerto como canal; ganaron **Transfer365** (91% de transferencias
  inmediatas) y **Wompi**. Efectivo sigue dominando el punto de venta.
- **Fiado** es la práctica definitoria de la tienda de barrio y su #1 fuente de pérdidas
  silenciosas — hoy se lleva en el cuaderno.
- **Lección Treinta (Colombia, ~$60M levantados, mismo segmento)**: el libro contable gratis
  no monetiza. Pivotaron a marketplace → compliance de facturación (DIAN) → POS → se fueron
  del segmento. Lo que monetiza: **compliance, pagos y crédito**, no el cuaderno digital.

**La cuña regulatoria real: Factura Electrónica (DTE).** Para **fines de 2026** todo el parque
empresarial —incluyendo MYPEs y personas naturales con actividad económica— debe emitir DTE.
Hacienda ofrece un sistema web gratuito pero mínimo (<100 facturas/mes, sin inventario, sin
fiado, sin reportes). Ahí está el espacio: DTE + lo que Hacienda no da.

### Dos mercados, dos productos

| | Tier A: microcomercio informal | Tier B: PYME formal pequeña |
|---|---|---|
| Persona (dataset) | Rosa (39, puesto de mercado), María (66, tienda), Ana (23, puesto minorista) | Perfil urbano, educación secundaria/universitaria, ocupación administrativa/comercial |
| Dispositivo | **Solo celular** (y WhatsApp) | PC/laptop en el negocio |
| Painpoint | Fiado, ventas del día, no saber si gana o pierde, DTE que se les viene encima | Inventario, CxC/CxP, compras, reportes, DTE |
| Interacción | **Voz en móvil**: "Fié $3 a la niña Carmen" | Back-office + copiloto AI |
| Lo que ya tiene Pisto | Casi nada (la app actual es demasiado compleja para este tier) | **Todos los módulos actuales encajan aquí** |

**Decisión recomendada:** Pisto hoy es un producto Tier B — y eso está bien como punto de
partida. El enfoque desktop es válido **para Tier B** (la PYME formal con empleado admin).
El "contable AI por voz" para la tiendera (Tier A) es un producto móvil/WhatsApp-first que
se construye después, sobre el mismo backend. No intentar servir a ambos con una sola UI.

El dataset Nemotron-Personas (148K personas, CC-BY-4.0, 26 campos: ocupación, educación,
área rural/urbana, municipio) sirve como **panel sintético de user research y población de
evals**: probar prompts del agente contra personas tipo Rosa/María/Ana, y validar que el
lenguaje del producto funciona para cada nivel educativo.

---

## 2. Arquitectura AI-native: el contable AI

### Estado actual (ya hay base)

- `pisto-api/src/modules/ai/` ya tiene: chat con function-calling (5 tools de **lectura**:
  ventas, gastos, CxC, inventario, cash flow), scan de recibos con visión, forecast y
  anomalías. Cliente OpenAI-compatible.
- `pisto_app` ya tiene `speech_to_text` en el chat AI.
- Falta: tools de **escritura** (registrar venta, gasto, abono), confirmación, idempotencia,
  audit log, memoria de conversación durable (hoy es un `Map` en memoria del Worker).

### Patrón objetivo (consenso 2026 en copilots fintech: Puzzle, Digits, Ramp)

**Draft-then-confirm en todo write. Voz entra, confirmación visual sale.**

1. **Autonomía por niveles:**
   - Lecturas ("¿quién me debe?", "¿cuánto vendí en junio?") → autónomas, respuesta
     inmediata con datos/gráficas.
   - Escrituras de bajo riesgo (registrar gasto pequeño) → el agente crea un registro
     `draft`, el usuario confirma con un tap.
   - Acciones financieras/irreversibles (anular factura, montos altos) → confirmación
     obligatoria, umbral por monto. **No gatear todo** (confirmation fatigue = el usuario
     aprueba sin leer).
2. **Cada tool de escritura recibe idempotency key** generada por el cliente — un tool call
   duplicado no puede registrar una venta dos veces.
3. **Audit log de cada tool call** (quién, qué tool, qué parámetros, qué escribió) en tabla
   propia — no solo el transcript.
4. **Inbox de sugerencias AI** en vez de prompts interruptivos: "3 recibos categorizados,
   1 anomalía — revisar".
5. **Evals en CI**: suite de comandos de voz transcritos → tool calls esperados. Usar
   personas del dataset Nemotron para generar variaciones de fraseo salvadoreño.

### Voz: pipeline en cascada, no speech-to-speech

Recomendación firme para un producto a precio LatAm ($5-15/mes, presupuesto AI ≤$1-2/usuario/mes):

- **STT:** Deepgram Nova-3 `es-419` streaming (~$0.008/min). El español salvadoreño está
  cerca del registro "LatAm estándar" que los modelos manejan bien — validar con audios
  propios grabados, no confiar en claims del vendor.
- **LLM:** modelo flash/mini-class con tool calling (Gemini Flash, GPT-mini, DeepSeek V3.2).
  Ya que `ai-client.ts` es OpenAI-compatible, cambiar de modelo es cambiar env vars.
- **TTS:** Deepgram Aura-2 ($30/M chars) o Cartesia Sonic. En una app de negocio, muchas
  respuestas pueden ser visuales (card + texto) — TTS opcional, no cada turno.
- **Modo push-to-talk**, no open-mic: turnos cortos en una app cuestan centavos; sesiones
  de micrófono abierto multiplican el costo 10-50x.
- Cascada ≈ $0.01-0.03/min all-in. OpenAI Realtime ($0.18-0.46/min real) no cierra a precio
  LatAm; si algún día se quiere full-duplex, **Gemini Live** es el único S2S cuya economía
  funciona (~10-50x más barato que OpenAI Realtime).
- Orquestación: para push-to-talk basta **audio por WebSocket/HTTP al backend Hono** (simple);
  si luego se quiere conversación continua, Pipecat o LiveKit Agents (`livekit_client`
  soporta Windows desktop).

### Costos AI (tiering)

- Scan de recibos: modelo nano/flash con visión → fracción de centavo por recibo.
- Prompt caching en system prompt + tool schemas (90-98% descuento).
- Recortar outputs de tools (no meter 50 filas de JSON al contexto por turno).
- Meta: **≤$1-2/usuario activo/mes** de costo AI → margen ≥80% a $10/mes. Cap de fair-use
  en minutos de voz.

---

## 3. Infraestructura: de serverless a instancia

Decisión del usuario: salir de serverless. Estado real: **Postgres ya está hecho** (schema
100% `pg-core`, cero artefactos mssql). Lo que cambia es el runtime.

### Plan de migración Workers → Bun en instancia

1. **Runtime:** volver a `Bun.serve` con Hono (el código Hono es portable; los cambios son
   de bordes, no de rutas).
2. **Eliminar workarounds de Workers:**
   - `runWithDb()` + AsyncLocalStorage + Proxy en `src/config/database.ts` → un pool
     `postgres()` global normal (en instancia los sockets sí se comparten).
   - Hyperdrive → conexión directa al pooler de Supabase (o Postgres local en el VPS).
   - PBKDF2/WebCrypto → se puede quedar (funciona en Bun) o migrar a `Bun.password`
     (argon2id) para nuevos hashes con re-hash on login.
   - R2 → se puede seguir usando R2 vía S3 API (barato, sin egress) o disco del VPS.
   - Memoria de conversación AI: del `Map` en memoria → tabla `ai_conversation` en Postgres
     (necesario de todos modos para el agente).
3. **Hosting:** **Railway** ($5-15/mes, Postgres gestionado, cero ops) mientras se valida;
   **Hetzner + Coolify** (~€5-10/mes flat) cuando haya ingresos. El tiempo de administrar
   un VPS pre-revenue vale más que el ahorro.
4. **Base de datos:** decidir entre quedarse en Supabase (RLS, auth, storage listos) o
   Postgres en el VPS. Recomendación: **quedarse en Supabase por ahora** — RLS multi-tenant
   (`tenant_id` + policies) es la última línea de defensa contra un tool del agente con un
   WHERE buggy. Activar **pgvector** para matching difuso (resolver "la niña Carmen" →
   customer_id desde voz); para preguntas numéricas, text-to-SQL sobre el schema propio
   gana a RAG con embeddings.
5. **Docker Compose** en el repo: api + (opcional) postgres local para dev.

### Frontend y desktop

- **Agregar target Windows** (`flutter create --platforms=windows .`) — hoy solo hay
  android/ios/web. Flutter Windows es maduro para CRUD/dashboards; el punto débil es el
  ecosistema de plugins de audio (probar mic/`speech_to_text`/streaming temprano).
- **Sacar la landing de la app**: `landing_screen.dart` (1,405 LOC) sale del bundle Flutter.
  La marketing page será un sitio aparte (Astro o Next en Cloudflare Pages/Vercel). La app
  arranca en `/login`.
- Mantener Flutter (no reescribir a web): la inversión existente + un solo codebase para
  desktop Tier B hoy y móvil Tier A mañana.

---

## 4. Reducción de duplicación (auditoría concreta)

### Frontend (mayor ROI primero)

1. **Tipar el service layer** — el problema #1. Los 10 services devuelven
   `Map<String,dynamic>`; las pantallas indexan con strings (`meta?['totalPages']`).
   Acción: modelos **Freezed** por entidad + `PaginatedResponse<T>` genérico + repositorio
   base. Elimina cientos de líneas y toda una clase de bugs.
2. **Migrar pantallas a Riverpod AsyncNotifier** — el patrón `bool _loading` + `setState` +
   `try/catch` + snackbar aparece 89 veces en 19 archivos. Un `AsyncValueWidget` compartido
   (data/loading/error) borra ese scaffolding en las ~15 pantallas.
3. **Form builder compartido** — 60 dialogs de formulario copy-paste (inventory 18,
   purchases 12...), 115 usos de TextEditingController a mano. Un `FormDialog` schema-driven
   (lista de campos + validators) colapsa la mayor parte de inventory (1,099 LOC),
   purchases, sales y collections. Evaluar `flutter_form_builder` antes de hacerlo a mano.
4. **`PaginatedListView<T>` genérico** — tabs + search + paginación + lista se reimplementa
   en 5 pantallas; ya existen piezas (`list_row`, `search_field`, `page_header`).

### Backend

5. **Factory `crudModule(table, opts)`** — cada módulo repite list/get/create/update:
   `buildConditions` + `Promise.all([select, count])` + `paginatedResponse` + throw 404.
   Un factory genérico sobre Drizzle recorta gran parte de las ~4,500 LOC de módulos.
6. **Merge de los dos schemas de paginación** (`shared/schemas/pagination.ts` vs
   `shared/utils/pagination.ts`) y helper `activeLookup(table)` para los endpoints de
   lookups copy-paste en `sales.routes.ts:97-116`.
7. **Robustecer JSON del LLM**: `forecast.service.ts` y `ai.service.ts` hacen
   `JSON.parse` tras quitar fences (frágil). Usar structured outputs / `response_format`
   json_schema del SDK.

### Librerías a adoptar (ahorran código)

| Área | Librería | Reemplaza |
|---|---|---|
| Forms Flutter | `flutter_form_builder` + validators | 60 dialogs a mano |
| Data classes | Freezed (ya instalado, subusado) | Maps sin tipo |
| Agente AI (TS) | **Vercel AI SDK** (`streamText` + tools + needsApproval) o loop propio de ~200 líneas | LangGraph = overkill para un agente de ~15 tools; SDKs de un solo provider = lock-in |
| Validación | Valibot (ya está) — compartir schemas entre rutas y tools del agente | — |
| Audio Flutter | `record` (streaming PCM) / `livekit_client` si se va a tiempo real | — |

---

## 5. Roadmap por fases

### Fase 0 — Fundaciones (1-2 semanas)
- Migrar Workers → Bun + Railway (§3). Actualizar CLAUDE.md (está obsoleto: describe
  Bun+SQL Server; la realidad era Workers+Supabase).
- Extraer landing a sitio aparte.
- Merge de paginación, structured outputs en AI services, conversaciones AI a Postgres.

### Fase 1 — Deuda técnica frontend (2-3 semanas, en paralelo parcial)
- Modelos Freezed + services tipados (módulo por módulo, empezando por sales).
- AsyncNotifier + AsyncValueWidget.
- Form builder compartido.
- Target Windows + prueba temprana de mic en desktop.

### Fase 2 — Contable AI v1: agente con manos (3-4 semanas)
- Tools de escritura: `create_sale_draft`, `create_expense_draft`, `register_payment_draft`,
  `create_customer` — todas draft-then-confirm, con idempotency key y audit log.
- Push-to-talk (Deepgram streaming) → agente → card de confirmación visual.
- Inbox de sugerencias AI (recibos categorizados, anomalías, cobros vencidos).
- pgvector para resolver nombres de clientes/productos desde voz.
- Suite de evals: comandos de voz salvadoreños (generados con personas Nemotron) → tool
  calls esperados, corriendo en CI.

### Fase 3 — DTE (la cuña de negocio, apuntando a la deadline fines de 2026)
- Investigar certificación como emisor DTE ante Hacienda (API de recepción MH, firma
  electrónica, contingencia). Este es el módulo que **monetiza**: DTE + inventario + fiado
  + reportes en un solo lugar, vs la herramienta gratis y mínima de Hacienda.
- Emisión de DTE desde factura Pisto; el agente puede prepararla por voz.

### Fase 4 — Tier A móvil (validar antes de construir)
- Prototipo móvil ultra-simple (o WhatsApp bot): ventas del día + fiado por voz.
- Validar con 10-20 tienderas reales (CONAMYPE puede ser canal). Solo escalar si retiene.
- Conciliación Transfer365/Wompi como feature de pago.

### Métricas de validación por fase
- F2: % de comandos de voz que terminan en draft correcto sin edición (>85% objetivo);
  costo AI/usuario/mes (≤$2).
- F3: # de DTEs emitidos/mes por usuario; conversión free→paid.
- F4: retención D30 de tienderas; frecuencia de registros de fiado/día.

---

## 6. Riesgos principales

1. **Desktop para Tier A es un no-go** — no forzarlo; desktop es para Tier B.
2. **DTE requiere certificación con MH** — empezar el trámite temprano; es la mayor barrera
   y el mayor moat.
3. **Plugins de audio en Flutter Windows** — probar en la Fase 1, no descubrirlo en la 2.
4. **Monetización del ledger puro no existe** (caso Treinta) — el plan de ingresos es
   DTE/compliance primero, luego pagos/crédito.
5. **Confirmation fatigue** — gatear por riesgo, no por todo.
