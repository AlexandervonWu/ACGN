import slotsFixture from "../src/mocks/slots.json";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

describe("live API response boundary", () => {
  beforeEach(() => {
    vi.stubEnv("VITE_USE_MOCK_API", "false");
    vi.stubEnv("VITE_ANALYSIS_API_BASE_URL", "https://analysis.example.test");
    vi.resetModules();
  });

  afterEach(() => {
    vi.unstubAllEnvs();
    vi.unstubAllGlobals();
  });

  it("turns malformed visualization data into a schema error", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response(JSON.stringify({
      schemaVersion: "1.0",
      graph: { rootEClassId: 12, eclasses: [] },
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })));
    const { analyzePredicate } = await import("../src/api/client");

    await expect(analyzePredicate("pred p {}", "p")).rejects.toMatchObject({
      kind: "schema",
      message: "Backend response does not match the E-Graph Visualization IR.",
    });
  });

  it("rejects an otherwise valid unsupported major schema version", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response(JSON.stringify({
      ...slotsFixture,
      schemaVersion: "2.0",
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })));
    const { analyzePredicate } = await import("../src/api/client");

    await expect(analyzePredicate("pred inv7 {}", "inv7")).rejects.toMatchObject({
      kind: "unsupported-version",
    });
  });

  it("sends a function as a typed callable while retaining the legacy name field", async () => {
    const fetchMock = vi.fn(async (_input: RequestInfo | URL, _init?: RequestInit) => new Response(JSON.stringify(slotsFixture), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    }));
    vi.stubGlobal("fetch", fetchMock);
    const { analyzeCallable } = await import("../src/api/client");

    await analyzeCallable("fun neighbors: univ { univ }", {
      name: "neighbors",
      kind: "function",
    });

    const [, init] = fetchMock.mock.calls[0]!;
    expect(JSON.parse(String(init?.body))).toMatchObject({
      callable: { name: "neighbors", kind: "function" },
      predicate: "neighbors",
    });
  });

  it("sends both typed callables to the certified comparison endpoint", async () => {
    const response = {
      schemaVersion: "1.0",
      model: { name: "submitted.als" },
      left: {
        name: "neighbors", kind: "function", originalText: "User", normalizedText: "User",
        canonicalText: "User", digest: "left", representationSize: 1,
      },
      right: {
        name: "connected", kind: "predicate", originalText: "some User", normalizedText: "some User",
        canonicalText: "SOME(User)", digest: "right", representationSize: 2,
      },
      metricVersion: "certified-repair-v1",
      certifiedEquivalent: false,
      operationDetail: "mixed",
      distance: {
        total: 1, temporal: 0, quantifier: 0, matrix: 1,
        exactForStoredOrbits: true, binderAlignments: 1,
      },
      operations: [{
        id: "op-0", index: 0, component: "matrix", kind: "aggregate", path: "matrix",
        summary: "Minimum certified matrix repair", cost: 1, detail: "aggregate",
      }],
    };
    const fetchMock = vi.fn(async (_input: RequestInfo | URL, _init?: RequestInit) => new Response(JSON.stringify(response), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    }));
    vi.stubGlobal("fetch", fetchMock);
    const { compareCallables } = await import("../src/api/client");

    await compareCallables(
      "fun neighbors: univ { univ } pred connected { some univ }",
      { name: "neighbors", kind: "function" },
      { name: "connected", kind: "predicate" },
    );

    const [url, init] = fetchMock.mock.calls[0]!;
    expect(String(url)).toBe("https://analysis.example.test/api/v1/egraph/compare");
    expect(JSON.parse(String(init?.body))).toMatchObject({
      leftCallable: { name: "neighbors", kind: "function" },
      rightCallable: { name: "connected", kind: "predicate" },
    });
  });

  it("asks the backend to terminate an aborted analysis worker", async () => {
    const fetchMock = vi.fn((input: RequestInfo | URL, init?: RequestInit) => {
      if (String(input).endsWith("/api/v1/jobs/cancel")) {
        return Promise.resolve(new Response(JSON.stringify({ status: "cancelling", cancelled: true }), {
          status: 200,
          headers: { "Content-Type": "application/json" },
        }));
      }
      return new Promise<Response>((_resolve, reject) => {
        init?.signal?.addEventListener("abort", () => {
          reject(new DOMException("aborted", "AbortError"));
        }, { once: true });
      });
    });
    vi.stubGlobal("fetch", fetchMock);
    const { analyzeCallable } = await import("../src/api/client");
    const controller = new AbortController();

    const pending = analyzeCallable(
      "sig Item {} pred simple { some Item }",
      { name: "simple", kind: "predicate" },
      undefined,
      controller.signal,
    );
    await Promise.resolve();
    controller.abort();

    await expect(pending).rejects.toMatchObject({ kind: "cancelled" });
    const analysisBody = JSON.parse(String(fetchMock.mock.calls[0]?.[1]?.body));
    const cancelCall = fetchMock.mock.calls.find(([url]) => String(url).endsWith("/api/v1/jobs/cancel"));
    expect(cancelCall).toBeDefined();
    expect(JSON.parse(String(cancelCall?.[1]?.body))).toEqual({ requestId: analysisBody.requestId });
  });
});
