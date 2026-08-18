export interface RuntimeApiConfig {
  analysisApiBaseUrl?: string;
  useMockApi?: boolean;
}

interface BuildApiConfig {
  VITE_ANALYSIS_API_BASE_URL?: string;
  VITE_USE_MOCK_API?: string;
}

export interface ResolvedApiConfig {
  analysisApiBaseUrl: string;
  useMockApi: boolean;
}

function buildMockMode(value: string | undefined): boolean | undefined {
  if (value === undefined || value.trim() === "") return undefined;
  return value.trim().toLowerCase() === "true";
}

function normalizedBaseUrl(value: string): string {
  return value.trim().replace(/\/$/, "");
}

export function resolveApiConfig(
  runtime: RuntimeApiConfig | undefined,
  build: BuildApiConfig,
  origin: string,
): ResolvedApiConfig {
  const runtimeBase = runtime?.analysisApiBaseUrl;
  const buildBase = build.VITE_ANALYSIS_API_BASE_URL;
  const selectedBase = runtimeBase !== undefined
    ? runtimeBase
    : buildBase ?? origin;

  return {
    analysisApiBaseUrl: normalizedBaseUrl(selectedBase || origin),
    useMockApi: runtime?.useMockApi
      ?? buildMockMode(build.VITE_USE_MOCK_API)
      ?? false,
  };
}

const resolved = resolveApiConfig(
  window.__ALLOY_EGRAPH_CONFIG__,
  import.meta.env,
  window.location.origin,
);

export const analysisApiBaseUrl = resolved.analysisApiBaseUrl;
export const useMockApi = resolved.useMockApi;
