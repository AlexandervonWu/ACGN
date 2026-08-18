/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_ANALYSIS_API_BASE_URL?: string;
  readonly VITE_USE_MOCK_API?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

interface Window {
  __ALLOY_EGRAPH_CONFIG__?: {
    analysisApiBaseUrl?: string;
    useMockApi?: boolean;
  };
}
