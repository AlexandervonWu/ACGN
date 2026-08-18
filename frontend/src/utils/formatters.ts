import type { ProvenanceRef, TypeDescriptor } from "../api/types";

export function formatType(type?: TypeDescriptor): string {
  if (!type) return "Not provided by backend";
  switch (type.kind) {
    case "formula": return "Formula";
    case "atom": return type.signature;
    case "relation": return type.columns.join(" → ");
    case "unknown": return type.display;
  }
}

export function formatProvenance(value: ProvenanceRef): string {
  if (typeof value === "string") return value;
  return value.label ?? value.summary ?? value.kind ?? value.id ?? "Unlabeled provenance";
}

export function formatMilliseconds(value?: number): string {
  if (value === undefined) return "Not provided";
  return `${value.toLocaleString(undefined, { maximumFractionDigits: 2 })} ms`;
}
