# Alloy E-Graph Explorer

`frontend/` is a standalone React and TypeScript explorer for the Alloy typed slotted e-graph artifact. It accepts Alloy source, discovers every source predicate and function through an HTTP service, validates the service's EGraph Visualization IR, and presents normalization stages, e-classes, e-nodes, slots, support, provenance, traces, invariants, and certificates.

The browser is deliberately not another canonicalizer. Parsing, typing, normalization, saturation, slot semantics, support computation, and proof production remain backend responsibilities.

## Architecture

```text
Static React application                 Analysis service
----------------------------------       -------------------------------
Monaco Alloy editor                 POST /api/v1/model/inspect
Callable and stage navigation       POST /api/v1/egraph/analyze
React Flow e-class graph            GET  /api/v1/health
Inspector and virtualized trace          Alloy/Java semantic pipeline
Zod boundary validation             <--- JSON Visualization IR v1.x
```

Server state is managed by TanStack Query. Interaction state, such as graph filters, selected entities, selected slots, stages, and trace filters, is held in Zustand. The complete backend response has one owner and is not copied into UI stores.

Graph construction is bounded before React Flow receives any nodes. The default view follows references from the selected callable root to depth 5, collapses large classes, and caps the rendered neighborhood. A deterministic layered layout keeps the root above its children.

## Requirements

- Node.js 18 or newer for development and builds
- npm 9 or newer
- Java 17 or newer for live Alloy parsing and certified e-graph analysis
- A current Chromium, Firefox, or Edge browser
- No Node.js runtime on the production web server

## Development

```bash
./scripts/run_visualization_server.sh \
  --bind 127.0.0.1 --port 8080 \
  --allow-origin http://localhost:5173
```

In a second terminal:

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

The Java adapter compiles against the repository libraries, parses the submitted model with the existing Alloy parser, builds the selected callable's Fast Rewrite IR, and exports the Certificate-Integrated e-graph as Visualization IR 1.1. Vite prints the local development URL.

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

When provided, `VITE_ANALYSIS_API_BASE_URL` must be an absolute backend base URL. Do not include `/api/v1`; the client appends the endpoint paths. A trailing slash is accepted and normalized. When it is omitted, live mode targets the page origin and expects `/api/v1` to reach the analysis service.

Production builds also load `runtime-config.js` before the application bundle. This lets an IIS deployment change API mode and location without rebuilding:

```js
window.__ALLOY_EGRAPH_CONFIG__ = {
  useMockApi: false,
  analysisApiBaseUrl: "https://analysis.example.org",
};
```

Runtime values override `VITE_*` build values. With neither setting present, the application uses live mode and the page origin, so IIS may reverse-proxy `/api/v1` to the Java service. Mock mode is enabled only by setting `useMockApi: true` or `VITE_USE_MOCK_API=true` explicitly.

`analysisApiBaseUrl` is resolved by each visitor's browser. For a remotely accessed IIS site, use a public HTTPS API origin or a same-origin IIS reverse proxy; `127.0.0.1` would refer to the visitor's computer rather than the web server.

Environment variables are compiled into Vite's static JavaScript. Rebuild `dist/` when changing the production backend URL. Do not place credentials in `VITE_*` variables because browser users can inspect them.

Set `VITE_USE_MOCK_API=true` for deterministic demo mode without Java. It uses the same typed client functions and Zod schemas as live mode. Deep-linkable predicate fixtures are available at:

```text
?example=simple
?example=alpha
?example=aci
?example=prenex
?example=slots
?example=callables
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
  "callables": [
    {
      "name": "inv1",
      "kind": "predicate",
      "sourceRange": {
        "start": { "line": 1, "column": 13 },
        "end": { "line": 1, "column": 36 }
      }
    },
    {
      "name": "items",
      "kind": "function",
      "returnType": "set Item"
    }
  ],
  "predicates": [{ "name": "inv1" }],
  "parseDiagnostics": []
}
```

`predicates` is retained for Visualization IR 1.0 clients. New clients use `callables`; parser-internal declarations are not exposed.

### Analyze callable

```http
POST /api/v1/egraph/analyze
Content-Type: application/json
```

```json
{
  "model": "sig User {} pred inv1 { some User }",
  "callable": { "name": "inv1", "kind": "predicate" },
  "predicate": "inv1",
  "options": {
    "includeStages": true,
    "includeTrace": true,
    "includeCertificates": true,
    "includeSourceMappings": true
  }
}
```

For a function, send `{"name":"items","kind":"function"}`. The legacy `predicate` string remains in requests during the 1.x compatibility window.

The response is an EGraph Visualization IR object with this top-level shape:

```text
schemaVersion: "1.x"
model
callable
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

The included Java analysis service translates typed e-classes, typed ports, slots, and sequence/bag/set container laws into this IR. The frontend does not accept serialized Java objects and does not infer Alloy semantics.

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

The deployable application is written to `dist/`. It contains only static HTML, CSS, JavaScript, the Monaco worker, source maps, `runtime-config.js`, and `web.config`.

Vite uses a relative asset base, so the output works at an IIS site root or virtual-directory path without rebuilding asset URLs.

## IIS 10 Deployment

IIS serves the compiled browser application; it does not run the Alloy parser or e-graph implementation. A live installation therefore has two processes:

```text
Browser -> IIS static frontend -> Java visualization API
```

Node.js is needed only on the build machine. Java 17 is required wherever the visualization API runs.

### 1. Choose a topology

**Same-origin reverse proxy (recommended)**

```text
https://egraph.example.org/                 IIS static files
https://egraph.example.org/api/v1/*         IIS -> http://127.0.0.1:8080/api/v1/*
```

The browser sees one HTTPS origin, so CORS and mixed-content restrictions do not cross the frontend/API boundary. Keep the Java service bound to loopback. This topology requires the IIS URL Rewrite module and Application Request Routing (ARR).

**Separate API origin**

```text
https://egraph.example.org/                 IIS static files
https://analysis.example.org/api/v1/*       Java service or an API reverse proxy
```

Use this when the API already has its own HTTPS endpoint. The API must return `Access-Control-Allow-Origin` for the exact frontend origin. Do not expose a plain-HTTP API to an HTTPS page.

### 2. Install prerequisites

On the IIS host, enable:

- **Web Server (IIS) > Common HTTP Features > Static Content**
- **Web Server (IIS) > Management Tools > IIS Management Console**
- An HTTPS certificate and site binding
- URL Rewrite and ARR only for the recommended reverse-proxy topology

For ARR, open the server node in IIS Manager, select **Application Request Routing Cache > Server Proxy Settings**, enable **Proxy**, and apply the change. A rewrite rule without ARR proxying enabled commonly produces HTTP 502 responses.

Install a Java 17 JDK on the API host and confirm:

```powershell
java -version
javac -version
```

### 3. Build and test the frontend

From the repository on a development or build machine:

```powershell
Set-Location C:\src\ACGN\frontend
npm ci
npm test
npm run build
```

A plain `npm run build` now produces a **live**, same-origin bundle. Mock mode is not the production default. The deployable files are placed directly under `frontend\dist`:

```text
index.html
runtime-config.js
web.config
assets\...
```

Copy the contents of `dist`, not the `dist` directory itself. For example:

```powershell
$Destination = "C:\inetpub\alloy-egraph"
New-Item -ItemType Directory -Force $Destination | Out-Null
Copy-Item .\dist\* $Destination -Recurse -Force
```

Keep `web.config`, `runtime-config.js`, and `index.html` at the same level. The generated asset URLs are relative, so the static application can be hosted at a site root or beneath an IIS application path.

### 4. Create the IIS application

1. Create an application pool such as `AlloyEGraphFrontend`.
2. Set **.NET CLR version** to **No Managed Code** and use the integrated pipeline.
3. Create an IIS site or application whose physical path is `C:\inetpub\alloy-egraph`.
4. Add an HTTPS binding for the public hostname.
5. Grant the application-pool identity read and execute access to the directory. The frontend requires no write permission.
6. Confirm that `https://egraph.example.org/runtime-config.js` and the page itself return HTTP 200.

The included [`public/web.config`](public/web.config) is copied into every build. It configures `index.html` as the default document, JSON/SVG/WASM/source-map MIME types, static compression, and basic response headers. The UI uses query parameters rather than path-based client routes, so URL Rewrite is unnecessary unless IIS is also proxying the API.

### 5. Configure the browser-facing API URL

Edit the deployed `runtime-config.js`; no frontend rebuild is required.

For a frontend at the IIS site root with a same-origin `/api/v1` proxy:

```js
window.__ALLOY_EGRAPH_CONFIG__ = {
  useMockApi: false,
  analysisApiBaseUrl: "",
};
```

An empty base URL means the page origin. The client appends `/api/v1/health`, `/api/v1/model/inspect`, and `/api/v1/egraph/analyze`.

For a separate API hostname:

```js
window.__ALLOY_EGRAPH_CONFIG__ = {
  useMockApi: false,
  analysisApiBaseUrl: "https://analysis.example.org",
};
```

For a frontend installed as the IIS application `/alloy`, either proxy `/api/v1` at the site root or use an application-relative proxy and set:

```js
window.__ALLOY_EGRAPH_CONFIG__ = {
  useMockApi: false,
  analysisApiBaseUrl: "https://egraph.example.org/alloy",
};
```

That configuration sends API requests to `/alloy/api/v1/*`. The API URL is evaluated in each visitor's browser. Never configure `127.0.0.1` unless every visitor runs the API on their own computer.

After changing `runtime-config.js`, hard-refresh the browser or clear the site's cached files. The header should report **Connected**, not **Mock API** or **Unreachable**.

### 6. Run the Java visualization API

On Linux, the repository helper compiles and starts the service:

```bash
./scripts/run_visualization_server.sh \
  --bind 127.0.0.1 \
  --port 8080 \
  --allow-origin https://egraph.example.org \
  --workers 8
```

On Windows PowerShell, compile with a Java argument file to avoid command-line length limits:

```powershell
$Repo = (Resolve-Path "C:\src\ACGN").Path
$Build = Join-Path $Repo "build\visualization-server"
$Sources = Join-Path $Build "sources.txt"

Remove-Item $Build -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $Build | Out-Null
Get-ChildItem (Join-Path $Repo "src") -Recurse -Filter *.java |
  ForEach-Object { '"' + $_.FullName + '"' } |
  Set-Content -Encoding ascii $Sources

& javac --release 17 -cp "${Repo}\lib\*" -d $Build "@$Sources"
& java --add-modules jdk.httpserver `
  -cp "${Build};${Repo}\lib\*" `
  is.fivefivefive.CanDis.VisualizationServer `
  --bind 127.0.0.1 `
  --port 8080 `
  --allow-origin https://egraph.example.org `
  --workers 8
```

Run the Java command under a Windows service wrapper or another supervised service mechanism for production. Capture standard output and error for diagnostics, configure automatic restart, and use an account with read access to the compiled classes and `lib` directory. Keep `--bind 127.0.0.1` when IIS proxies locally. If the API is on another host, place it behind HTTPS and restrict its listening port with the firewall.

`--allow-origin` accepts one exact browser origin, including scheme and non-default port but no path or trailing slash. For example, `https://egraph.example.org` and `http://egraph.example.org` are different origins.

### 7. Configure the same-origin IIS proxy

For the recommended topology, add this block inside `<system.webServer>` in the deployed site-root `web.config`:

```xml
<rewrite>
  <rules>
    <rule name="Alloy visualization API" stopProcessing="true">
      <match url="^api/v1/(.*)$" />
      <action type="Rewrite"
              url="http://127.0.0.1:8080/api/v1/{R:1}"
              appendQueryString="true" />
    </rule>
  </rules>
</rewrite>
```

The match URL is relative to the IIS application containing the rule. If the frontend is under `/alloy` and `runtime-config.js` targets `https://egraph.example.org/alloy`, put the rule in that application and it will receive `/alloy/api/v1/*`. If the runtime configuration uses the page origin, put the rule at the site root because requests go to `/api/v1/*`.

Preserve this locally added rewrite block when replacing `web.config` during a later frontend deployment. ARR's proxy timeout should be at least the client's 120-second analysis timeout.

### 8. Configure a separate API origin

Start the Java service with the exact public frontend origin:

```text
--allow-origin https://egraph.example.org
```

Terminate TLS in front of the Java process, set `analysisApiBaseUrl` to that public HTTPS base URL, and allow `GET`, `POST`, and `OPTIONS`. The service already emits:

```text
Access-Control-Allow-Origin: https://egraph.example.org
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

Do not use a comma-separated origin list or append a URL path to `--allow-origin`; the current service accepts one exact origin.

### 9. Validate the deployment

Test the Java process on its host first:

```powershell
Invoke-RestMethod http://127.0.0.1:8080/api/v1/health
```

For a same-origin proxy, test through IIS next:

```powershell
Invoke-RestMethod https://egraph.example.org/api/v1/health
```

The response should contain `status: ok` and visualization schema version `1.1`. Then verify the static runtime configuration:

```powershell
Invoke-WebRequest https://egraph.example.org/runtime-config.js
```

Finally, open the site in a browser:

1. Confirm the header changes to **Connected**.
2. Open a local `.als` file from the Source toolbar.
3. Wait for predicates and functions to populate the **Target** selector.
4. Select a target and click **Analyze**.
5. Confirm that the graph root, e-classes, normalization stages, and inspector appear.

Browser developer tools should show successful requests to all three `/api/v1` endpoints and no CORS, mixed-content, or schema errors.

### 10. Troubleshooting

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| **Mock API** or “Mock mode recognizes the bundled examples only” | Old bundle, cached JavaScript, or `useMockApi: true` | Deploy the current `dist`, set `useMockApi: false`, and hard-refresh. |
| **Unreachable** | API process stopped, wrong browser-facing URL, DNS/firewall failure, mixed HTTP/HTTPS, or CORS rejection | Test `/api/v1/health`, inspect the browser Network/Console panels, and verify `runtime-config.js`. |
| HTTP 404 for `/api/v1/*` | Missing/misplaced rewrite rule or wrong application base URL | Align `analysisApiBaseUrl` with the IIS application containing the proxy rule. |
| HTTP 502/502.3 | ARR proxying disabled or Java is not listening on the configured address/port | Enable ARR Proxy and test the loopback health endpoint on the IIS host. |
| IIS 500.19 after adding `<rewrite>` | URL Rewrite is not installed, the configuration section is locked, or XML is malformed | Install URL Rewrite or move the rule to an allowed server/site configuration level. |
| CORS error despite HTTP 200 | `Access-Control-Allow-Origin` does not exactly equal the page origin | Match scheme, hostname, and port in `--allow-origin`; do not include a path. |
| Browser blocks “mixed content” | HTTPS frontend points to an HTTP API | Publish the API through HTTPS or use the same-origin IIS proxy. |
| Blank page or asset 404s | Incorrect copy layout or missing `assets` directory | Copy the contents of `dist` together and keep `index.html` above `assets`. |
| Monaco worker blocked | A custom CSP excludes same-origin workers/scripts | Permit the site's own scripts, styles, and worker sources; include the API in `connect-src`. |
| Uploaded model cannot resolve `open localModule` | Browser upload supplied only one source file | Make the model self-contained; bundled modules such as `util/ordering` remain supported. |

IIS access logs describe static/proxy status codes. Java standard error contains parser, type-checking, and analysis failures. Correlate both with the failing request in the browser Network panel.

### 11. Updating and rollback

Keep `runtime-config.js` and any locally added IIS rewrite rule outside the immutable hashed asset set. For an update:

1. Run `npm ci`, `npm test`, and `npm run build`.
2. Back up the deployed directory.
3. Replace `index.html`, `assets`, and the standard static files from `dist`.
4. Restore the deployment-specific `runtime-config.js` and proxy rule if necessary.
5. Validate health and one real Alloy analysis before deleting the backup.

Static frontend updates do not require an application-pool recycle. Restart the supervised Java service only when its compiled classes or libraries change.

JavaScript must be permitted by the site's content-security policy. Monaco creates a web worker from a same-origin built asset. If IIS adds a custom CSP, account for the application's same-origin scripts, styles, worker, and the configured backend in `connect-src`. Do not place secrets in `runtime-config.js` or `VITE_*` variables; both are visible to every browser.

## Interaction Model

- Use the file-open icon in **Source** to load a local `.als` file. The browser reads its text locally and sends only that source text to the configured analysis service.
- Choose any discovered predicate or function from the **Target** selector, then use **Analyze** or `Ctrl/Cmd+Enter`.
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

- A single-file upload resolves Alloy's bundled modules such as `util/ordering`. A model that opens project-local sibling modules must currently be made self-contained before upload because browsers do not disclose neighboring files.
- The Java adapter currently exports certified graph structure and pipeline representations; detailed source spans, per-rewrite trace events, and certificate payloads remain optional and may be absent.
- Stage text and mappings are selectable. Stage-specific graph switching remains unavailable unless the backend supplies addressable snapshots.
- SVG export is a deterministic representation of the currently bounded graph, not a capture of React Flow's viewport. PNG export is deferred.
- Pane resizing and callable-to-callable comparison are deferred. The responsive layout uses tabs below desktop width.
- Search only uses information explicitly present in the IR. It does not derive semantic aliases, support, proofs, or equivalence.
- The mock inspector recognizes the bundled examples. It is a deterministic demo service, not an Alloy parser.

These limits preserve the boundary that all Alloy semantics and evidence originate from the analysis backend.
