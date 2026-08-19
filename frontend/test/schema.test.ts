import { describe, expect, it } from "vitest";
import {
  CallableComparisonSchema,
  EGraphAnalysisSchema,
  ModelInspectionSchema,
} from "../src/api/schema";
import aci from "../src/mocks/aci.json";
import alpha from "../src/mocks/alpha.json";
import callables from "../src/mocks/callables.json";
import prenex from "../src/mocks/prenex.json";
import simple from "../src/mocks/simple.json";
import slots from "../src/mocks/slots.json";

describe("Visualization IR schema", () => {
  const zeroComparison = {
    schemaVersion: "1.0",
    model: { name: "test.als" },
    left: {
      name: "p",
      kind: "predicate",
      originalText: "some univ",
      normalizedText: "some univ",
      canonicalText: "SOME(univ)",
      certifiedStableForm: "certified-A",
      digest: "left-digest",
      representationSize: 2,
    },
    right: {
      name: "q",
      kind: "predicate",
      originalText: "some univ",
      normalizedText: "some univ",
      canonicalText: "SOME(univ)",
      certifiedStableForm: "certified-A",
      digest: "right-digest",
      representationSize: 2,
    },
    metricVersion: "certified-repair-v1",
    certifiedEquivalent: true,
    operationDetail: "unit",
    distance: {
      total: 0,
      temporal: 0,
      quantifier: 0,
      matrix: 0,
      exactForStoredOrbits: true,
      binderAlignments: 1,
    },
    operations: [{
      id: "op-0",
      index: 0,
      component: "equivalence",
      kind: "no-op",
      path: "quotient",
      summary: "No repair required",
      cost: 0,
      detail: "unit",
    }],
  };

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

  it("rejects explicit edges with the wrong e-node owner or child target", () => {
    type ExplicitEdgeFixture = typeof simple & {
      graph: typeof simple.graph & {
        edges?: Array<{
          sourceEClassId: string;
          targetEClassId: string;
          enodeId: string;
        }>;
      };
    };

    const wrongOwner = structuredClone(simple) as ExplicitEdgeFixture;
    wrongOwner.graph.edges = [{
      sourceEClassId: "E1",
      targetEClassId: "E1",
      enodeId: "N0",
    }];
    expect(EGraphAnalysisSchema.safeParse(wrongOwner).success).toBe(false);

    const wrongTarget = structuredClone(simple) as ExplicitEdgeFixture;
    wrongTarget.graph.edges = [{
      sourceEClassId: "E0",
      targetEClassId: "E0",
      enodeId: "N0",
    }];
    expect(EGraphAnalysisSchema.safeParse(wrongTarget).success).toBe(false);
  });

  it("validates a certified callable comparison", () => {
    expect(CallableComparisonSchema.safeParse(zeroComparison).success).toBe(true);
  });

  it("rejects blank stable forms without rewriting valid evidence text", () => {
    const blank = structuredClone(zeroComparison);
    blank.left.certifiedStableForm = " \t\n ";
    expect(CallableComparisonSchema.safeParse(blank).success).toBe(false);

    const spaced = structuredClone(zeroComparison);
    spaced.left.certifiedStableForm = " certified-A ";
    spaced.right.certifiedStableForm = " certified-A ";
    const parsed = CallableComparisonSchema.parse(spaced);
    expect(parsed.left.certifiedStableForm).toBe(" certified-A ");
  });

  it("rejects comparison operations that do not witness the distance", () => {
    const corrupt = structuredClone(zeroComparison) as Record<string, unknown>;
    corrupt.distance = {
      ...(corrupt.distance as object),
      total: 1,
      matrix: 1,
    };
    expect(CallableComparisonSchema.safeParse(corrupt).success).toBe(false);
  });

  it("derives certified equality from certified stable forms", () => {
    const nonEquivalent = structuredClone(zeroComparison);
    nonEquivalent.left.canonicalText = "same readable text";
    nonEquivalent.right.canonicalText = "same readable text";
    nonEquivalent.left.certifiedStableForm = "certified-A";
    nonEquivalent.right.certifiedStableForm = "certified-B";
    nonEquivalent.certifiedEquivalent = false;
    nonEquivalent.distance = {
      ...nonEquivalent.distance,
      total: 1,
      matrix: 1,
    };
    nonEquivalent.operations = [{
      id: "op-0",
      index: 0,
      component: "matrix",
      kind: "aggregate",
      path: "matrix",
      summary: "Certified matrix repair",
      cost: 1,
      detail: "aggregate",
    }];

    expect(CallableComparisonSchema.safeParse(nonEquivalent).success).toBe(true);

    const falseEquality = structuredClone(nonEquivalent);
    falseEquality.certifiedEquivalent = true;
    falseEquality.distance.total = 0;
    falseEquality.distance.matrix = 0;
    falseEquality.operations[0]!.cost = 0;
    expect(CallableComparisonSchema.safeParse(falseEquality).success).toBe(false);
  });

  it("rejects a bounded orbit result at the certified comparison boundary", () => {
    const bounded = structuredClone(zeroComparison);
    bounded.distance.exactForStoredOrbits = false;
    expect(CallableComparisonSchema.safeParse(bounded).success).toBe(false);
  });
});
