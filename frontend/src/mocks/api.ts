import {
  CallableComparisonSchema,
  EGraphAnalysisSchema,
  ModelInspectionSchema,
} from "../api/schema";
import type {
  AnalysisOptions,
  CallableComparison,
  CallableReference,
  EGraphAnalysis,
  HealthStatus,
  ModelInspection,
} from "../api/types";
import { examples } from "../examples";
import { analysisCallable } from "../api/callables";
import aciFixture from "./aci.json";
import alphaFixture from "./alpha.json";
import prenexFixture from "./prenex.json";
import simpleFixture from "./simple.json";
import slotsFixture from "./slots.json";
import callablesFixture from "./callables.json";

const fixtureEntries = [
  [examples.simple, simpleFixture],
  [examples.alpha, alphaFixture],
  [examples.aci, aciFixture],
  [examples.prenex, prenexFixture],
  [examples.slots, slotsFixture],
  [examples.callables, callablesFixture],
] as const;

function normalizeModel(model: string): string {
  return model.replace(/\r\n/g, "\n").trim();
}

function findFixture(model: string): EGraphAnalysis | undefined {
  const normalized = normalizeModel(model);
  const entry = fixtureEntries.find(([source]) => normalizeModel(source) === normalized);
  return entry ? EGraphAnalysisSchema.parse(entry[1]) : undefined;
}

async function mockDelay(signal?: AbortSignal): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    const timeout = window.setTimeout(resolve, 180);
    signal?.addEventListener("abort", () => {
      window.clearTimeout(timeout);
      reject(new DOMException("The operation was aborted", "AbortError"));
    }, { once: true });
  });
}

export async function mockHealthCheck(signal?: AbortSignal): Promise<HealthStatus> {
  await mockDelay(signal);
  return { status: "ok", version: "mock-1.0", visualizationSchemaVersion: "1.0" };
}

export async function mockInspectModel(
  model: string,
  signal?: AbortSignal,
): Promise<ModelInspection> {
  await mockDelay(signal);
  const fixture = findFixture(model);
  if (!fixture) {
    return ModelInspectionSchema.parse({
      callables: [],
      predicates: [],
      parseDiagnostics: [{
        severity: "warning",
        message: "Mock mode recognizes the bundled examples only.",
      }],
    });
  }
  const callable = analysisCallable(fixture);
  return ModelInspectionSchema.parse({
    callables: [{
      name: callable.name,
      kind: callable.kind,
      sourceRange: callable.sourceRange,
      returnType: callable.returnType,
    }],
    predicates: callable.kind === "predicate" ? [{
      name: callable.name,
      sourceRange: callable.sourceRange,
    }] : [],
    parseDiagnostics: [],
  });
}

export async function mockAnalyzePredicate(
  model: string,
  predicate: string,
  _options?: AnalysisOptions,
  signal?: AbortSignal,
): Promise<EGraphAnalysis> {
  await mockDelay(signal);
  const fixture = findFixture(model);
  if (!fixture || analysisCallable(fixture).name !== predicate) {
    throw new Error(`Mock analysis has no fixture for callable ${predicate}.`);
  }
  return EGraphAnalysisSchema.parse(fixture);
}

export async function mockCompareCallables(
  model: string,
  left: CallableReference,
  right: CallableReference,
  signal?: AbortSignal,
): Promise<CallableComparison> {
  await mockDelay(signal);
  const fixture = findFixture(model);
  const callable = fixture ? analysisCallable(fixture) : undefined;
  if (!fixture || !callable
      || callable.name !== left.name || callable.kind !== left.kind
      || callable.name !== right.name || callable.kind !== right.kind) {
    throw new Error(
      "Mock comparison supports a bundled callable compared with itself. "
      + "Configure the Java analysis API to compare arbitrary predicates or functions.",
    );
  }
  const representationSize = fixture.graph.eclasses.reduce(
    (size, eclass) => size + 1 + eclass.nodes.length,
    0,
  );
  const operand = {
    name: callable.name,
    kind: callable.kind,
    returnType: callable.returnType,
    originalText: callable.originalText ?? "",
    normalizedText: callable.normalizedText ?? "",
    canonicalText: callable.canonicalText ?? callable.normalizedText ?? "",
    digest: fixture.model.digest ?? `${callable.kind}:${callable.name}`,
    representationSize,
  };
  return CallableComparisonSchema.parse({
    schemaVersion: "1.0",
    model: fixture.model,
    left: operand,
    right: operand,
    metricVersion: "mock-certified-repair-v1",
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
      summary: "Certified semantic equality; no repair is required.",
      cost: 0,
      detail: "unit",
    }],
    statistics: { totalMs: 180 },
  });
}
