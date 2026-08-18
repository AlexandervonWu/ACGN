import { describe, expect, it } from "vitest";
import { resolveApiConfig } from "../src/api/config";

describe("API runtime configuration", () => {
  it("defaults a production bundle to a same-origin live API", () => {
    expect(resolveApiConfig(undefined, {}, "https://explorer.example.test")).toEqual({
      analysisApiBaseUrl: "https://explorer.example.test",
      useMockApi: false,
    });
  });

  it("allows IIS runtime configuration to override build-time values", () => {
    expect(resolveApiConfig({
      analysisApiBaseUrl: "https://analysis.example.test/",
      useMockApi: false,
    }, {
      VITE_ANALYSIS_API_BASE_URL: "https://old.example.test",
      VITE_USE_MOCK_API: "true",
    }, "https://explorer.example.test")).toEqual({
      analysisApiBaseUrl: "https://analysis.example.test",
      useMockApi: false,
    });
  });

  it("retains explicitly requested mock builds", () => {
    expect(resolveApiConfig(undefined, {
      VITE_USE_MOCK_API: "true",
    }, "http://localhost:5173").useMockApi).toBe(true);
  });
});
