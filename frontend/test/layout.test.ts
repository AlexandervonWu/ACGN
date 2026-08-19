import { describe, expect, it } from "vitest";
import type { EClass, GraphEdge } from "../src/api/types";
import { layoutEClasses } from "../src/graph/layout";

const eclasses: EClass[] = ["root", "left", "right", "a", "b"].map((id) => ({
  id,
  nodes: [{ id: `node-${id}`, kind: id, children: [] }],
}));
const edges: GraphEdge[] = [
  { sourceEClassId: "root", targetEClassId: "left" },
  { sourceEClassId: "root", targetEClassId: "right" },
  { sourceEClassId: "left", targetEClassId: "a" },
  { sourceEClassId: "left", targetEClassId: "b" },
  { sourceEClassId: "right", targetEClassId: "b" },
];
const depths = new Map([
  ["root", 0],
  ["left", 1],
  ["right", 1],
  ["a", 2],
  ["b", 2],
]);

describe("hierarchical e-class layout", () => {
  it("centers parents over their primary descendant spans", () => {
    const layout = layoutEClasses(eclasses, depths, edges, "root");
    const x = new Map(layout.positioned.map(({ eclass, position }) => [eclass.id, position.x]));
    expect(x.get("root")).toBe(-143);
    expect(((x.get("a") ?? 0) + (x.get("b") ?? 0)) / 2).toBe(x.get("left"));
    expect((x.get("left") ?? 0)).toBeLessThan(x.get("right") ?? 0);
  });

  it("uses one deterministic primary parent for a shared DAG child", () => {
    const layout = layoutEClasses(eclasses, depths, edges, "root");
    expect(layout.parentByEClass.get("b")).toBe("left");
  });

  it("selects exactly one tree edge among parallel structural references", () => {
    const parallel: GraphEdge[] = [
      { id: "left", sourceEClassId: "root", targetEClassId: "child", role: "left" },
      { id: "right", sourceEClassId: "root", targetEClassId: "child", role: "right" },
    ];
    const layout = layoutEClasses(
      [
        { id: "root", nodes: [{ id: "nr", kind: "Pair", children: [] }] },
        { id: "child", nodes: [{ id: "nc", kind: "Leaf", children: [] }] },
      ],
      new Map([["root", 0], ["child", 1]]),
      parallel,
      "root",
    );

    expect([...layout.treeEdgeIds]).toHaveLength(1);
    expect(["left", "right"]).toContain([...layout.treeEdgeIds][0]);
  });
});
