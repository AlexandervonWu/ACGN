import { EGraphAnalysisSchema, ModelInspectionSchema } from "../api/schema";
import type {
  AnalysisOptions,
  EGraphAnalysis,
  HealthStatus,
  ModelInspection,
} from "../api/types";
import { examples } from "../examples";
import aciFixture from "./aci.json";
import alphaFixture from "./alpha.json";
import prenexFixture from "./prenex.json";
import simpleFixture from "./simple.json";
import slotsFixture from "./slots.json";

const fixtureEntries = [
  [examples.simple, simpleFixture],
  [examples.alpha, alphaFixture],
  [examples.aci, aciFixture],
  [examples.prenex, prenexFixture],
  [examples.slots, slotsFixture],
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
      predicates: [],
      parseDiagnostics: [{
        severity: "warning",
        message: "Mock mode recognizes the bundled examples only.",
      }],
    });
  }
  return ModelInspectionSchema.parse({
    predicates: [{
      name: fixture.predicate.name,
      sourceRange: fixture.predicate.sourceRange,
    }],
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
  if (!fixture || fixture.predicate.name !== predicate) {
    throw new Error(`Mock analysis has no fixture for predicate ${predicate}.`);
  }
  return EGraphAnalysisSchema.parse(fixture);
}

