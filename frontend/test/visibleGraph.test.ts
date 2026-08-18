import { describe, expect, it } from "vitest";
import type { EClass, EGraph } from "../src/api/types";
import {
  buildVisibleGraph,
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
});

