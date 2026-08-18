import { describe, expect, it } from "vitest";
import { EGraphAnalysisSchema } from "../src/api/schema";
import aci from "../src/mocks/aci.json";
import alpha from "../src/mocks/alpha.json";
import prenex from "../src/mocks/prenex.json";
import simple from "../src/mocks/simple.json";
import slots from "../src/mocks/slots.json";

describe("Visualization IR schema", () => {
  it.each([
    ["simple", simple],
    ["alpha", alpha],
    ["aci", aci],
    ["prenex", prenex],
    ["slots", slots],
  ])("validates the %s production-shaped fixture", (_name, fixture) => {
    expect(EGraphAnalysisSchema.safeParse(fixture).success).toBe(true);
  });

  it("rejects corrupt child references encoded with a non-string identifier", () => {
    const corrupt = structuredClone(simple) as Record<string, unknown>;
    const graph = corrupt.graph as { eclasses: Array<{ nodes: Array<{ children: unknown[] }> }> };
    graph.eclasses[0]!.nodes[0]!.children = [{ eclassId: 42 }];
    expect(EGraphAnalysisSchema.safeParse(corrupt).success).toBe(false);
  });

  it("rejects dangling child e-class references", () => {
    const corrupt = structuredClone(simple);
    corrupt.graph.eclasses[0]!.nodes[0]!.children[0]!.eclassId = "missing-class";
    const parsed = EGraphAnalysisSchema.safeParse(corrupt);
    expect(parsed.success).toBe(false);
    if (!parsed.success) {
      expect(parsed.error.issues.some((issue) => issue.message.includes("missing-class"))).toBe(true);
    }
  });
});
