import { cleanup, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import type { EGraph, EGraphAnalysis } from "../src/api/types";
import { GraphCanvas } from "../src/components/Graph/GraphCanvas";
import { defaultGraphFilters, useUiStore } from "../src/state/uiStore";
import { buildVisibleGraphSvg } from "../src/utils/exporters";

function analysisFor(graph: EGraph): EGraphAnalysis {
  return {
    schemaVersion: "1.0",
    model: { name: "graph-test.als" },
    callable: { name: "subject", kind: "predicate", rootEClassId: graph.rootEClassId },
    predicate: { name: "subject", rootEClassId: graph.rootEClassId },
    stages: [],
    graph,
    statistics: {},
  };
}

const parallelGraph: EGraph = {
  rootEClassId: "E0",
  eclasses: [
    {
      id: "E0",
      canonicalNodeId: "N0",
      nodes: [{
        id: "N0",
        kind: "Pair",
        children: [
          { eclassId: "E1", role: "left operand" },
          { eclassId: "E1", role: "right operand" },
        ],
      }],
    },
    { id: "E1", nodes: [{ id: "N1", kind: "Leaf", children: [] }] },
  ],
  edges: [
    {
      id: "edge-left",
      sourceEClassId: "E0",
      targetEClassId: "E1",
      enodeId: "N0",
      role: "left operand",
    },
    {
      id: "edge-right",
      sourceEClassId: "E0",
      targetEClassId: "E1",
      enodeId: "N0",
      role: "right operand",
    },
  ],
};

describe("graph structural references", () => {
  beforeEach(() => {
    useUiStore.setState({
      expandedClasses: new Set(),
      graphFilters: {
        ...defaultGraphFilters,
        collapseSingleton: false,
        collapseLarge: false,
        showCrossLinks: true,
        depth: "all",
      },
      selectedEClassId: undefined,
      selectedENodeId: undefined,
      highlightedEntityIds: [],
    });
  });

  afterEach(cleanup);

  it("renders parallel tree and cross references with both roles", () => {
    render(<GraphCanvas analysis={analysisFor(parallelGraph)} />);

    const edges = screen.getAllByTestId("flow-edge");
    expect(edges).toHaveLength(2);
    expect(edges.map((edge) => edge.textContent)).toEqual(["left operand", "right operand"]);
    expect(edges.filter((edge) => edge.classList.contains("tree-edge"))).toHaveLength(1);
    expect(edges.filter((edge) => edge.classList.contains("cross-edge"))).toHaveLength(1);
  });

  it("exports every parallel reference and role to SVG", () => {
    const svg = buildVisibleGraphSvg(
      analysisFor(parallelGraph),
      { ...defaultGraphFilters, showCrossLinks: true, depth: "all" },
      new Set(),
    );

    expect(svg.match(/data-edge-id=/g)).toHaveLength(2);
    expect(svg).toContain('data-edge-role="left operand"');
    expect(svg).toContain('data-edge-role="right operand"');
    expect(svg).toContain('class="tree-edge"');
    expect(svg).toContain('class="cross-edge"');
    expect(svg).toContain(">left operand</text>");
    expect(svg).toContain(">right operand</text>");
  });

  it("reveals a hidden historical branch, its role, and its reachable target", async () => {
    const graph: EGraph = {
      rootEClassId: "E0",
      eclasses: [
        {
          id: "E0",
          canonicalNodeId: "N0",
          nodes: [
            { id: "N0", kind: "Root", displayName: "Visible root", children: [] },
            {
              id: "N-history",
              kind: "Historical",
              displayName: "Historical bridge",
              attributes: { historical: true },
              children: [{ eclassId: "E1", role: "historical target" }],
            },
          ],
        },
        {
          id: "E1",
          nodes: [{ id: "N1", kind: "Target", displayName: "Reached target", children: [] }],
        },
      ],
    };
    const user = userEvent.setup();
    render(<GraphCanvas analysis={analysisFor(graph)} />);

    expect(screen.getByRole("button", { name: "Show 1 hidden alternative" })).toBeVisible();
    expect(screen.queryByText("Historical bridge")).not.toBeInTheDocument();
    expect(screen.queryByText("Reached target")).not.toBeInTheDocument();
    expect(screen.queryByTestId("flow-edge")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Show 1 hidden alternative" }));

    expect(await screen.findByText("Historical bridge")).toBeVisible();
    expect(screen.getAllByText("Reached target")).not.toHaveLength(0);
    expect(screen.getByTestId("flow-edge")).toHaveTextContent("historical target");
    expect(screen.queryByRole("button", { name: /Show .* hidden alternative/ }))
      .not.toBeInTheDocument();
  });
});
