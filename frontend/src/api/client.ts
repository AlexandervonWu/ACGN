import type { ZodType } from "zod";
import {
  EGraphAnalysisSchema,
  HealthStatusSchema,
  ModelInspectionSchema,
} from "./schema";
import type {
  AnalysisOptions,
  ApiErrorKind,
  EGraphAnalysis,
  HealthStatus,
  ModelInspection,
} from "./types";
import {
  mockAnalyzePredicate,
  mockHealthCheck,
  mockInspectModel,
} from "../mocks/api";

const configuredBaseUrl = import.meta.env.VITE_ANALYSIS_API_BASE_URL?.trim();
export const useMockApi = import.meta.env.VITE_USE_MOCK_API !== "false";
export const analysisApiBaseUrl = configuredBaseUrl?.replace(/\/$/, "") ?? "";

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
      "VITE_ANALYSIS_API_BASE_URL is required when mock mode is disabled.",
    );
  }
  return analysisApiBaseUrl;
}

function timedSignal(source: AbortSignal | undefined, timeoutMs: number) {
  const controller = new AbortController();
  const timeout = window.setTimeout(() => controller.abort("timeout"), timeoutMs);
  const abort = () => controller.abort(source?.reason ?? "cancelled");
  source?.addEventListener("abort", abort, { once: true });
  return {
    signal: controller.signal,
    cleanup: () => {
      window.clearTimeout(timeout);
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
  if (code.includes("predicate")) return "predicate-not-found";
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

async function decodeResponse<T>(response: Response, schema: ZodType<T>): Promise<T> {
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

async function request<T>(
  path: string,
  schema: ZodType<T>,
  init: RequestInit,
  sourceSignal?: AbortSignal,
  timeoutMs = 120_000,
): Promise<T> {
  const timer = timedSignal(sourceSignal, timeoutMs);
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
    if (error instanceof AnalysisApiError) throw error;
    if (timer.signal.aborted) {
      const timedOut = !sourceSignal?.aborted;
      throw new AnalysisApiError(
        timedOut ? "timeout" : "cancelled",
        timedOut ? "The analysis request timed out." : "The analysis request was cancelled.",
      );
    }
    throw new AnalysisApiError(
      "network",
      error instanceof Error ? error.message : "The analysis backend is unreachable.",
    );
  } finally {
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
  return request(
    "/api/v1/model/inspect",
    ModelInspectionSchema,
    { method: "POST", body: JSON.stringify({ model }) },
    signal,
    30_000,
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

export async function analyzePredicate(
  model: string,
  predicate: string,
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
      analysis = await mockAnalyzePredicate(model, predicate, requestedOptions, signal);
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
    analysis = await request(
        "/api/v1/egraph/analyze",
        EGraphAnalysisSchema,
        {
          method: "POST",
          body: JSON.stringify({ model, predicate, options: requestedOptions }),
        },
        signal,
      );
  }
  return requireSupportedSchema(analysis);
}
