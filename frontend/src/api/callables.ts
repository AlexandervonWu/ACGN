import type { CallableMetadata, EGraphAnalysis } from "./types";

export function analysisCallable(analysis: EGraphAnalysis): CallableMetadata {
  return analysis.callable ?? {
    ...analysis.predicate,
    kind: "predicate",
  };
}
