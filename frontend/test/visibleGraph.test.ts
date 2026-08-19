import { describe, expect, it } from "vitest";
import type { EClass, EGraph } from "../src/api/types";
import {
  buildVisibleGraph,
  displayNodes,
  shouldCollapseEClass,
} from "../src/graph/buildVisibleGraph";
import { defaultGraphFilters } from "../src/state/uiStore";

function chainGraph(length: number, disconnected = false): EGraph {
  const eclasses: EClass[] = Array.from({ length }, (_, index) => ({
    id: `E${index}`,
    type: { kind: "formula" },
    nodes: [{
      id: `N${index}`,
      kind: "Node",
      children: index + 1 < length ? [{ eclassId: `E${index + 1}` }] : [],
    }],
  }));
  if (disconnected) eclasses.push({ id: "EX", nodes: [{ id: "NX", kind: "Detached", children: [] }] });
  return { rootEClassId: "E0", eclasses };
}

describe("visible graph extraction", () => {
  it("keeps the root-reachable neighborhood only", () => {
    const visible = buildVisibleGraph(chainGraph(4, true), defaultGraphFilters, new Set());
    expect(visible.eclasses.map((item) => item.id)).toEqual(["E0", "E1", "E2", "E3"]);
    expect(visible.reachableCount).toBe(4);
  });

  it("applies depth before sending nodes to the renderer", () => {
    const visible = buildVisibleGraph(
      chainGraph(8),
      { ...defaultGraphFilters, depth: 3 },
      new Set(),
    );
    expect(visible.eclasses.map((item) => item.id)).toEqual(["E0", "E1", "E2", "E3"]);
  });

  it("bounds a moderately large fixture without a full render", () => {
    const visible = buildVisibleGraph(
      chainGraph(650),
      { ...defaultGraphFilters, depth: "all" },
      new Set(),
    );
    expect(visible.restricted).toBe(true);
    expect(visible.eclasses).toHaveLength(250);
    expect(visible.omittedCount).toBe(400);
  });

  it("honors singleton and large-class collapsing with explicit expansion", () => {
    const singleton = chainGraph(1).eclasses[0]!;
    const large: EClass = {
      id: "EL",
      nodes: Array.from({ length: 5 }, (_, index) => ({ id: `NL${index}`, kind: "Alt", children: [] })),
    };
    expect(shouldCollapseEClass(singleton, defaultGraphFilters, new Set())).toBe(true);
    expect(shouldCollapseEClass(large, defaultGraphFilters, new Set())).toBe(true);
    expect(shouldCollapseEClass(large, defaultGraphFilters, new Set(["EL"]))).toBe(false);
  });

  it("does not draw edges owned by hidden e-node alternatives", () => {
    const graph: EGraph = {
      rootEClassId: "E0",
      eclasses: [
        {
          id: "E0",
          canonicalNodeId: "N0",
          nodes: [
            { id: "N0", kind: "And", children: [{ eclassId: "E1" }] },
            { id: "N-alt", kind: "Or", children: [{ eclassId: "E2" }] },
          ],
        },
        { id: "E1", nodes: [{ id: "N1", kind: "Left", children: [] }] },
        { id: "E2", nodes: [{ id: "N2", kind: "Right", children: [] }] },
      ],
      edges: [
        { sourceEClassId: "E0", targetEClassId: "E1", enodeId: "N0" },
        { sourceEClassId: "E0", targetEClassId: "E2", enodeId: "N-alt" },
      ],
    };
    const visible = buildVisibleGraph(graph, defaultGraphFilters, new Set());
    expect(visible.edges).toEqual([
      { sourceEClassId: "E0", targetEClassId: "E1", enodeId: "N0" },
    ]);
    const displayed = displayNodes(graph.eclasses[0]!, defaultGraphFilters, false);
    expect(displayed.map((node) => node.id)).toEqual(["N0"]);
    expect(new Set(visible.edges.map((edge) => edge.enodeId))).toEqual(new Set(["N0"]));
    expect(displayed.some((node) => node.id === "N-alt")).toBe(false);
  });

  it("uses explicit expansion as a local override for historical alternatives", () => {
    const graph: EGraph = {
      rootEClassId: "E0",
      eclasses: [
        {
          id: "E0",
          canonicalNodeId: "N0",
          nodes: [
            { id: "N0", kind: "Root", children: [] },
            {
              id: "N-history",
              kind: "Historical",
              attributes: { historical: true },
              children: [{ eclassId: "E1", role: "historical target" }],
            },
          ],
        },
        { id: "E1", nodes: [{ id: "N1", kind: "Target", children: [] }] },
      ],
    };

    const hidden = buildVisibleGraph(graph, defaultGraphFilters, new Set());
    expect(hidden.eclasses.map((eclass) => eclass.id)).toEqual(["E0"]);
    expect(hidden.edges).toEqual([]);
    expect(displayNodes(graph.eclasses[0]!, {
      ...defaultGraphFilters,
      showAllAlternatives: true,
    }, false).map((node) => node.id)).toEqual(["N0"]);

    const expanded = buildVisibleGraph(graph, defaultGraphFilters, new Set(["E0"]));
    expect(expanded.eclasses.map((eclass) => eclass.id)).toEqual(["E0", "E1"]);
    expect(displayNodes(graph.eclasses[0]!, defaultGraphFilters, true)
      .map((node) => node.id)).toEqual(["N0", "N-history"]);
    expect(expanded.edges).toMatchObject([{
      sourceEClassId: "E0",
      targetEClassId: "E1",
      enodeId: "N-history",
      role: "historical target",
    }]);
  });
});
