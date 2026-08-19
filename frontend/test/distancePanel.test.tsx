import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import type { CallableComparison } from "../src/api/types";
import { DistancePanel } from "../src/components/Distance/DistancePanel";

const comparison: CallableComparison = {
  schemaVersion: "1.0",
  model: { name: "test.als" },
  left: {
    name: "before",
    kind: "predicate",
    originalText: "some User",
    normalizedText: "some User",
    canonicalText: "SOME(User)",
    certifiedStableForm: "certified-before",
    digest: "left",
    representationSize: 2,
  },
  right: {
    name: "after",
    kind: "predicate",
    originalText: "no User",
    normalizedText: "no User",
    canonicalText: "NO(User)",
    certifiedStableForm: "certified-after",
    digest: "right",
    representationSize: 2,
  },
  metricVersion: "certified-repair-v1",
  certifiedEquivalent: false,
  operationDetail: "unit",
  distance: {
    total: 1,
    temporal: 0,
    quantifier: 1,
    matrix: 0,
    exactForStoredOrbits: true,
    binderAlignments: 2,
  },
  operations: [{
    id: "op-0",
    index: 0,
    component: "quantifier",
    kind: "modify",
    path: "AFTER.quantifier[0]",
    summary: "modify SOME -> NO",
    source: "SOME User",
    target: "NO User",
    cost: 1,
    detail: "unit",
  }],
};

describe("distance panel", () => {
  it("visualizes component costs and source-to-target repair operations", async () => {
    const close = vi.fn();
    render(<DistancePanel comparison={comparison} onClose={close} />);

    expect(screen.getByRole("region", { name: "Edit distance comparison" })).toBeInTheDocument();
    expect(screen.getByText("before")).toBeInTheDocument();
    expect(screen.getByText("after")).toBeInTheDocument();
    expect(screen.getByText("SOME User")).toBeInTheDocument();
    expect(screen.getByText("NO User")).toBeInTheDocument();
    expect(screen.getByText("AFTER.quantifier[0]")).toBeInTheDocument();

    await userEvent.click(screen.getByRole("button", { name: "Close comparison" }));
    expect(close).toHaveBeenCalledOnce();
  });
});
