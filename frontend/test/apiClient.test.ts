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
});
