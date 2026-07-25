# DTE — Factura Electrónica de El Salvador (seed design)

Status: **seed**. This documents the target architecture so the schema and module boundaries
exist before the full build (PLAN F3). Nothing here is certified or production-ready.

## Context

Ministerio de Hacienda (MH) mandates Documentos Tributarios Electrónicos for the whole
business park by end of 2026, including MYPEs and personas naturales con actividad económica
(individual notification, 3-4 months lead). MH's free tool covers <100 invoices/month and
sales ≤$10,000 with no inventory/receivables — Pisto's wedge is DTE + operations in one place.

## What emitting a DTE requires (MH ecosystem)

1. **Registration** as electronic issuer with MH (NIT, activity, test environment first).
2. **Firma electrónica:** each DTE JSON is signed with the taxpayer's certificate through
   MH's `firmador` component (a service MH distributes; typically self-hosted as a container).
3. **Transmission:** signed JSON POSTed to MH's reception API → returns `sello de recepción`
   (acceptance stamp) or rejection with observations.
4. **Contingency:** if MH or connectivity is down, documents are issued in contingency mode
   and transmitted within the legal window (72h), with a contingency event report.
5. **Delivery:** the receiver gets the JSON + a human-readable representation (PDF) by email
   or link; QR code links to MH's consultation portal.
6. **Invalidation:** cancelling an accepted DTE is itself an event transmitted to MH.

Document types Pisto cares about (v3 JSON schemas published by MH):

| Código | Tipo | Pisto entity |
|--------|------|--------------|
| 01 | Factura (consumidor final) | sales invoice |
| 03 | Comprobante de Crédito Fiscal (CCF) | sales invoice to contribuyente |
| 05 | Nota de Crédito | credit note |
| 14 | Factura de Sujeto Excluido | purchases from informal suppliers |

## Target architecture in Pisto

Vertical slice `modules/dte/`, isolated so nothing else depends on MH availability:

```
modules/dte/
  dte.routes.ts        emit, status, invalidate, contingency endpoints
  dte.service.ts       orchestration: build → sign → transmit → persist result
  dte-builder.ts       Pisto invoice → MH JSON (per document type, versioned)
  dte-signer.ts        client for the firmador service
  dte-transmitter.ts   client for MH reception API (test/prod base URLs)
  dte.schemas.ts       Valibot schemas for our endpoints
```

### State machine (dte_document.status)

```
draft → signed → transmitted → accepted
                     ↘ rejected (terminal, with MH observations)
draft → contingency → transmitted → …
accepted → invalidated
```

Rules:
- A Pisto invoice is the source of truth for business data; `dte_document` stores the exact
  JSON sent, the signature, and MH's response (`sello`, observations) — immutable audit trail.
- Transmission is idempotent by `codigoGeneracion` (UUID, generated once at draft).
- The invoice flow works with DTE disabled (feature flag per business): informal businesses
  use Pisto without MH; flipping the flag adds emission, changing nothing else.

### Schema seed (db/schema/dte.ts)

`dte_document`: id, business_id, invoice_id/credit_note_id, tipo_dte, codigo_generacion
(uuid), numero_control, status, mh_environment (test|prod), json_payload (jsonb),
sello_recepcion, mh_observations (jsonb), signed_at, transmitted_at, resolved_at,
created_at.

`dte_business_config` (or columns on business settings): nit, nrc, actividad económica,
certificate reference, ambiente, correlative ranges per tipo_dte.

## Not in scope for the seed

- Firmador deployment, certificate management UX, MH enrollment paperwork.
- PDF representation + QR (reuse exports module when built).
- Contingency batch jobs.

## Next concrete steps (when F3 starts)

1. Register a test taxpayer in MH's test environment; get schemas + firmador.
2. Implement builder for tipo 01 only, golden-file tests against MH's JSON schema.
3. Emit against test environment; then CCF (03), then credit note (05).
