import { describe, expect, it } from "vitest";
import { EGraphAnalysisSchema, ModelInspectionSchema } from "../src/api/schema";
import aci from "../src/mocks/aci.json";
import alpha from "../src/mocks/alpha.json";
import callables from "../src/mocks/callables.json";
import prenex from "../src/mocks/prenex.json";
import simple from "../src/mocks/simple.json";
import slots from "../src/mocks/slots.json";

describe("Visualization IR schema", () => {
  it("accepts mixed predicates and functions during model inspection", () => {
    const parsed = ModelInspectionSchema.parse({
      callables: [
        { name: "connected", kind: "predicate" },
        { name: "neighbors", kind: "function", returnType: "set User" },
      ],
      parseDiagnostics: [],
    });
    expect(parsed.callables).toEqual([
      { name: "connected", kind: "predicate" },
      { name: "neighbors", kind: "function", returnType: "set User" },
    ]);
    expect(parsed.predicates).toEqual([{ name: "connected", sourceRange: undefined }]);
  });

  it("normalizes a predicate-only 1.0 inspection response into callables", () => {
    const parsed = ModelInspectionSchema.parse({
      predicates: [{ name: "legacyPredicate" }],
      parseDiagnostics: [],
    });
    expect(parsed.callables).toEqual([{ name: "legacyPredicate", kind: "predicate" }]);
  });

  it.each([
    ["simple", simple],
    ["alpha", alpha],
    ["aci", aci],
    ["prenex", prenex],
    ["slots", slots],
    ["callables", callables],
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
