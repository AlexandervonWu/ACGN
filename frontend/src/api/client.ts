import type { TypeOf, ZodTypeAny } from "zod";
import {
  CallableComparisonSchema,
  EGraphAnalysisSchema,
  HealthStatusSchema,
  ModelInspectionSchema,
} from "./schema";
import type {
  AnalysisOptions,
  ApiErrorKind,
  CallableReference,
  CallableComparison,
  EGraphAnalysis,
  HealthStatus,
  ModelInspection,
} from "./types";
import {
  mockAnalyzePredicate,
  mockCompareCallables,
  mockHealthCheck,
  mockInspectModel,
} from "../mocks/api";
import { analysisApiBaseUrl, useMockApi } from "./config";

export { analysisApiBaseUrl, useMockApi } from "./config";

export class AnalysisApiError extends Error {
  readonly kind: ApiErrorKind;
  readonly status?: number;
  readonly details?: unknown;

  constructor(kind: ApiErrorKind, message: string, status?: number, details?: unknown) {
    super(message);
    this.name = "AnalysisApiError";
    this.kind = kind;
    this.status = status;
    this.details = details;
  }
}

function requireBaseUrl(): string {
  if (!analysisApiBaseUrl) {
    throw new AnalysisApiError(
      "configuration",
      "Configure analysisApiBaseUrl in runtime-config.js or provide VITE_ANALYSIS_API_BASE_URL.",
    );
  }
  return analysisApiBaseUrl;
}

function newRequestId(): string {
  if (typeof globalThis.crypto?.randomUUID === "function") {
    return globalThis.crypto.randomUUID();
  }
  return `viz-${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

type RequestTerminalCause = "cancelled" | "timeout";

function cancelRemoteRequest(requestId: string, cause: RequestTerminalCause): void {
  try {
    void fetch(`${requireBaseUrl()}/api/v1/jobs/cancel`, {
      method: "POST",
      keepalive: true,
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ requestId, cause }),
    }).catch(() => undefined);
  } catch {
    // The local abort still succeeds when the backend is already unreachable.
  }
}

function timedSignal(source: AbortSignal | undefined, timeoutMs: number) {
  const controller = new AbortController();
  let terminalCause: RequestTerminalCause | undefined;
  let timeout: number | undefined;
  const settle = (cause: RequestTerminalCause) => {
    if (terminalCause) return;
    terminalCause = cause;
    if (cause === "cancelled" && timeout !== undefined) {
      window.clearTimeout(timeout);
      timeout = undefined;
    }
    controller.abort(cause);
  };
  const abort = () => settle("cancelled");
  timeout = window.setTimeout(() => settle("timeout"), timeoutMs);
  if (source?.aborted) {
    abort();
  } else {
    source?.addEventListener("abort", abort, { once: true });
  }
  return {
    signal: controller.signal,
    terminalCause: () => terminalCause,
    cleanup: () => {
      if (timeout !== undefined) window.clearTimeout(timeout);
      source?.removeEventListener("abort", abort);
    },
  };
}

function classifyStatus(status: number, body: unknown): ApiErrorKind {
  const code = typeof body === "object" && body !== null && "code" in body
    ? String((body as { code?: unknown }).code).toLowerCase()
    : "";
  if (code.includes("parse")) return "parse";
  if (code.includes("type")) return "type";
  if (code.includes("callable") || code.includes("function")) return "callable-not-found";
  if (code.includes("predicate")) return "predicate-not-found";
  if (status === 499 || code.includes("cancel")) return "cancelled";
  if (status === 408 || status === 504) return "timeout";
  return status >= 500 ? "analysis" : "backend";
}

function backendMessage(body: unknown, fallback: string): string {
  if (typeof body === "object" && body !== null && "message" in body) {
    const message = (body as { message?: unknown }).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}

async function decodeResponse<TSchema extends ZodTypeAny>(
  response: Response,
  schema: TSchema,
): Promise<TypeOf<TSchema>> {
  let body: unknown;
  try {
    body = await response.json();
  } catch {
    throw new AnalysisApiError(
      "schema",
      "The backend returned a non-JSON response.",
      response.status,
    );
  }
  if (!response.ok) {
    throw new AnalysisApiError(
      classifyStatus(response.status, body),
      backendMessage(body, `Analysis service returned HTTP ${response.status}.`),
      response.status,
      body,
    );
  }
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    throw new AnalysisApiError(
      "schema",
      "Backend response does not match the E-Graph Visualization IR.",
      response.status,
      parsed.error.flatten(),
    );
  }
  return parsed.data;
}

async function request<TSchema extends ZodTypeAny>(
  path: string,
  schema: TSchema,
  init: RequestInit,
  sourceSignal?: AbortSignal,
  timeoutMs = 120_000,
  requestId?: string,
): Promise<TypeOf<TSchema>> {
  const timer = timedSignal(sourceSignal, timeoutMs);
  let workerCancellationSent = false;
  const cancelWorker = requestId ? () => {
    if (workerCancellationSent) return;
    const cause = timer.terminalCause();
    if (!cause) return;
    workerCancellationSent = true;
    cancelRemoteRequest(requestId, cause);
  } : undefined;
  if (cancelWorker) {
    if (timer.signal.aborted) cancelWorker();
    else timer.signal.addEventListener("abort", cancelWorker, { once: true });
  }
  try {
    const response = await fetch(`${requireBaseUrl()}${path}`, {
      ...init,
      signal: timer.signal,
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        ...init.headers,
      },
    });
    return await decodeResponse(response, schema);
  } catch (error) {
    const terminalCause = timer.terminalCause();
    if (terminalCause) {
      throw new AnalysisApiError(
        terminalCause,
        terminalCause === "timeout"
          ? "The analysis request timed out."
          : "The analysis request was cancelled.",
      );
    }
    if (error instanceof AnalysisApiError) throw error;
    throw new AnalysisApiError(
      "network",
      error instanceof Error ? error.message : "The analysis backend is unreachable.",
    );
  } finally {
    cancelWorker && timer.signal.removeEventListener("abort", cancelWorker);
    timer.cleanup();
  }
}

export async function healthCheck(signal?: AbortSignal): Promise<HealthStatus> {
  if (useMockApi) return mockHealthCheck(signal);
  return request(
    "/api/v1/health",
    HealthStatusSchema,
    { method: "GET" },
    signal,
    5_000,
  );
}

export async function inspectModel(
  model: string,
  signal?: AbortSignal,
): Promise<ModelInspection> {
  if (useMockApi) return mockInspectModel(model, signal);
  const requestId = newRequestId();
  return request(
    "/api/v1/model/inspect",
    ModelInspectionSchema,
    { method: "POST", body: JSON.stringify({ requestId, model }) },
    signal,
    30_000,
    requestId,
  );
}

function requireSupportedSchema(analysis: EGraphAnalysis): EGraphAnalysis {
  const major = Number.parseInt(analysis.schemaVersion.split(".")[0] ?? "", 10);
  if (major !== 1) {
    throw new AnalysisApiError(
      "unsupported-version",
      `Backend visualization schema ${analysis.schemaVersion} is not supported. Supported: 1.x.`,
    );
  }
  return analysis;
}

export async function analyzeCallable(
  model: string,
  callable: CallableReference,
  options: AnalysisOptions = {},
  signal?: AbortSignal,
): Promise<EGraphAnalysis> {
  const requestedOptions: Required<AnalysisOptions> = {
    includeStages: options.includeStages ?? true,
    includeTrace: options.includeTrace ?? true,
    includeCertificates: options.includeCertificates ?? true,
    includeSourceMappings: options.includeSourceMappings ?? true,
  };
  let analysis: EGraphAnalysis;
  if (useMockApi) {
    try {
      analysis = await mockAnalyzePredicate(model, callable.name, requestedOptions, signal);
    } catch (error) {
      if (signal?.aborted || (error instanceof DOMException && error.name === "AbortError")) {
        throw new AnalysisApiError("cancelled", "The analysis request was cancelled.");
      }
      throw new AnalysisApiError(
        "analysis",
        error instanceof Error ? error.message : "Mock analysis failed.",
      );
    }
  } else {
    const requestId = newRequestId();
    analysis = await request(
        "/api/v1/egraph/analyze",
        EGraphAnalysisSchema,
        {
          method: "POST",
          body: JSON.stringify({
            requestId,
            model,
            callable,
            predicate: callable.name,
            options: requestedOptions,
          }),
        },
        signal,
        120_000,
        requestId,
      );
  }
  return requireSupportedSchema(analysis);
}

export async function compareCallables(
  model: string,
  leftCallable: CallableReference,
  rightCallable: CallableReference,
  signal?: AbortSignal,
): Promise<CallableComparison> {
  let comparison: CallableComparison;
  if (useMockApi) {
    try {
      comparison = await mockCompareCallables(
        model,
        leftCallable,
        rightCallable,
        signal,
      );
    } catch (error) {
      if (signal?.aborted || (error instanceof DOMException && error.name === "AbortError")) {
        throw new AnalysisApiError("cancelled", "The comparison request was cancelled.");
      }
      throw new AnalysisApiError(
        "analysis",
        error instanceof Error ? error.message : "Mock comparison failed.",
      );
    }
  } else {
    const requestId = newRequestId();
    comparison = await request(
      "/api/v1/egraph/compare",
      CallableComparisonSchema,
      {
        method: "POST",
        body: JSON.stringify({ requestId, model, leftCallable, rightCallable }),
      },
      signal,
      120_000,
      requestId,
    );
  }
  const major = Number.parseInt(comparison.schemaVersion.split(".")[0] ?? "", 10);
  if (major !== 1) {
    throw new AnalysisApiError(
      "unsupported-version",
      `Backend comparison schema ${comparison.schemaVersion} is not supported. Supported: 1.x.`,
    );
  }
  return comparison;
}

/** Compatibility wrapper for predicate-only integrations. */
export function analyzePredicate(
  model: string,
  predicate: string,
  options: AnalysisOptions = {},
  signal?: AbortSignal,
): Promise<EGraphAnalysis> {
  return analyzeCallable(model, { name: predicate, kind: "predicate" }, options, signal);
}
