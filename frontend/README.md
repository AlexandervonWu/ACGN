# Alloy E-Graph Explorer

`frontend/` is a standalone React and TypeScript explorer for the Alloy typed slotted e-graph artifact. It accepts Alloy source, discovers predicates through an HTTP service, validates the service's EGraph Visualization IR, and presents source mappings, normalization stages, e-classes, e-nodes, slots, support, provenance, traces, invariants, and certificates.

The browser is deliberately not another canonicalizer. Parsing, typing, normalization, saturation, slot semantics, support computation, and proof production remain backend responsibilities.

## Architecture

```text
Static React application                 Analysis service
----------------------------------       -------------------------------
Monaco Alloy editor                 POST /api/v1/model/inspect
Predicate and stage navigation      POST /api/v1/egraph/analyze
React Flow e-class graph            GET  /api/v1/health
Inspector and virtualized trace          Alloy/Java semantic pipeline
Zod boundary validation             <--- JSON Visualization IR v1.x
```

Server state is managed by TanStack Query. Interaction state, such as graph filters, selected entities, selected slots, stages, and trace filters, is held in Zustand. The complete backend response has one owner and is not copied into UI stores.

Graph construction is bounded before React Flow receives any nodes. The default view follows references from the predicate root to depth 5, collapses large classes, and caps the rendered neighborhood. A deterministic layered layout keeps the root above its children.

## Requirements

- Node.js 18 or newer for development and builds
- npm 9 or newer
- A current Chromium, Firefox, or Edge browser
- No Node.js runtime on the production web server

## Development

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

The default `.env.example` enables deterministic mock mode, so the full explorer works without a Java backend. Vite prints the local development URL.

Useful commands:

```bash
npm test
npm run test:watch
npm run build
```

## Configuration

Vite reads these values at build or development-server startup:

```env
VITE_ANALYSIS_API_BASE_URL=https://analysis.example.org
VITE_USE_MOCK_API=false
```

`VITE_ANALYSIS_API_BASE_URL` must be an absolute backend origin when mock mode is disabled. A trailing slash is accepted and normalized. No `/api` origin or same-host proxy is assumed.

Environment variables are compiled into Vite's static JavaScript. Rebuild `dist/` when changing the production backend URL. Do not place credentials in `VITE_*` variables because browser users can inspect them.

Mock mode is active unless `VITE_USE_MOCK_API` is exactly `false`. It uses the same typed client functions and Zod schemas as live mode. Deep-linkable fixtures are available at:

```text
?example=simple
?example=alpha
?example=aci
?example=prenex
?example=slots
```

The `slots` fixture contains the `inv7` acceptance model. Opening an example populates the editor but does not automatically analyze it.

## HTTP API

All requests send and accept `application/json`. Lines and columns in source ranges are **1-based**, including end positions. Entity identifiers are opaque strings.

### Health

```http
GET /api/v1/health
```

```json
{
  "status": "ok",
  "version": "backend-version",
  "visualizationSchemaVersion": "1.0"
}
```

### Inspect model

```http
POST /api/v1/model/inspect
Content-Type: application/json
```

```json
{
  "model": "sig User {} pred inv1 { some User }"
}
```

```json
{
  "predicates": [
    {
      "name": "inv1",
      "sourceRange": {
        "start": { "line": 1, "column": 13 },
        "end": { "line": 1, "column": 36 }
      }
    }
  ],
  "parseDiagnostics": []
}
```

### Analyze predicate

```http
POST /api/v1/egraph/analyze
Content-Type: application/json
```

```json
{
  "model": "sig User {} pred inv1 { some User }",
  "predicate": "inv1",
  "options": {
    "includeStages": true,
    "includeTrace": true,
    "includeCertificates": true,
    "includeSourceMappings": true
  }
}
```

The response is an EGraph Visualization IR object with this top-level shape:

```text
schemaVersion: "1.x"
model
predicate
stages[]
graph { rootEClassId, eclasses[], edges?, saturation? }
sourceMappings?
trace?
certificates?
diagnostics?
statistics?
```

The detailed executable contract is in [`src/api/schema.ts`](src/api/schema.ts). Optional diagnostic fields may be omitted. Every successful response is validated before it enters React state. Invalid JSON, malformed IR, and unsupported schema major versions produce developer-oriented error messages while retaining the last successful graph.

The analysis service must translate its internal Java representation into this IR. The frontend does not accept serialized Java objects.

## CORS

For a frontend at `https://egraph.example.org` and a backend at `https://analysis.example.org`, the backend should allow:

```text
Origin: https://egraph.example.org
Methods: GET, POST, OPTIONS
Headers: Accept, Content-Type
```

Return `Access-Control-Allow-Origin` for the exact frontend origin and answer preflight `OPTIONS` requests. The current client does not send cookies or authorization credentials. If authentication is added later, configure allowed credentials and origins explicitly rather than using a wildcard origin.

## Production Build

```bash
cd frontend
VITE_USE_MOCK_API=false \
VITE_ANALYSIS_API_BASE_URL=https://analysis.example.org \
npm run build
```

The deployable application is written to `dist/`. It contains only static HTML, CSS, JavaScript, the Monaco worker, source maps, and `web.config`.

Vite uses a relative asset base, so the output works at an IIS site root or virtual-directory path without rebuilding asset URLs.

## IIS 10 Deployment

1. Install the IIS **Static Content** role service.
2. Build the application with the production backend URL as shown above.
3. Copy the **contents** of `frontend/dist/` into the IIS site's physical directory.
4. Keep the generated `web.config` beside `index.html`.
5. Give the application pool identity read access to the deployed directory.
6. Browse to the site over HTTPS and confirm that the status indicator reaches the configured backend.

The included [`public/web.config`](public/web.config) is copied into every build. It configures `index.html` as the default document, required static MIME types, compression, and basic response headers. The application currently uses query parameters rather than client-side path routes, so the IIS URL Rewrite module is not required.

JavaScript must be permitted by the site's content-security policy. Monaco creates a web worker from a same-origin built asset. If IIS adds a custom CSP, at minimum account for the application's same-origin scripts, styles, worker, and the configured backend in `connect-src`.

## Interaction Model

- Select a discovered predicate and use **Analyze** or `Ctrl/Cmd+Enter`.
- Click an e-class to inspect class-level type, support, alternatives, provenance, and invariants.
- Click an e-node row for exact children, slots, container semantics, source, and certificates.
- Shift-click two members of one e-class to request the included equivalence explanation.
- Click a slot chip to retain cross-panel slot highlighting; use the clear-slot control to remove it.
- Click mapped Alloy source to focus associated graph objects. Ambiguous spans expose every mapping.
- Use graph depth and collapse controls before expanding large neighborhoods.
- Search by class/node ID, kind, type, slot, source identifier, or trace rule.
- Export the validated IR as JSON, the currently bounded graph as SVG, or copy the backend-provided canonical representation.

## Schema Versioning

Analysis responses must include `schemaVersion`. This frontend supports visualization schema major version `1` and explicitly rejects other major versions. Additive optional fields within `1.x` are tolerated because schema records preserve unknown fields where forward-compatible rendering is useful.

Certificate `kind` values are intentionally open. Unknown certificates render as structured evidence plus raw JSON instead of failing or inventing a proof.

## Testing

```bash
npm test
```

The suite covers schema fixtures and corrupt data, root reachability, depth bounding, class collapsing, source-range conversion, persistent slot selection, unknown certificate fallback, and a complete mock workflow from model inspection through source-to-graph navigation.

```bash
npm run build
```

The build runs TypeScript project checking before Vite emits production assets.

## Known Limitations

- The repository defines the browser contract but does not add the Java HTTP adapter. Connecting the artifact requires one backend translation layer into Visualization IR v1.x.
- Stage text and mappings are selectable. Stage-specific graph switching remains unavailable unless the backend supplies addressable snapshots.
- SVG export is a deterministic representation of the currently bounded graph, not a capture of React Flow's viewport. PNG export is deferred.
- Pane resizing and predicate-to-predicate comparison are deferred. The responsive layout uses tabs below desktop width.
- Search only uses information explicitly present in the IR. It does not derive semantic aliases, support, proofs, or equivalence.
- The mock inspector recognizes the bundled examples. It is a deterministic demo service, not an Alloy parser.

These limits preserve the boundary that all Alloy semantics and evidence originate from the analysis backend.
