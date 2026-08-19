import type { EClass, GraphEdge } from "../api/types";

export interface PositionedEClass {
  eclass: EClass;
  position: { x: number; y: number };
}

export interface HierarchicalLayout {
  positioned: PositionedEClass[];
  parentByEClass: Map<string, string>;
  treeEdgeIds: Set<string>;
}

const NODE_WIDTH = 286;
const SIBLING_GAP = 54;
const COMPONENT_GAP = 120;
const DEFAULT_NODE_HEIGHT = 110;
const ROW_GAP = 72;

interface LayoutTree {
  childrenById: Map<string, string[]>;
  parentById: Map<string, string>;
  treeEdgeIds: Set<string>;
  roots: string[];
}

export function graphEdgeKey(edge: GraphEdge, index: number): string {
  return edge.id
    ?? `${edge.sourceEClassId}:${edge.targetEClassId}:${edge.enodeId ?? ""}:${edge.role ?? ""}:${index}`;
}

function depthOf(id: string, depths: Map<string, number>, fallback: number): number {
  return depths.get(id) ?? fallback;
}

function primaryTree(
  eclasses: EClass[],
  depths: Map<string, number>,
  edges: GraphEdge[],
  rootId?: string,
): LayoutTree {
  const visibleIds = new Set(eclasses.map((eclass) => eclass.id));
  const fallbackDepth = Math.max(0, ...depths.values()) + 1;
  const incoming = new Map<string, Array<{ source: string; order: number; edgeId: string }>>();

  edges.forEach((edge, order) => {
    if (!visibleIds.has(edge.sourceEClassId) || !visibleIds.has(edge.targetEClassId)) return;
    const sourceDepth = depthOf(edge.sourceEClassId, depths, fallbackDepth);
    const targetDepth = depthOf(edge.targetEClassId, depths, fallbackDepth);
    if (sourceDepth >= targetDepth) return;
    const candidates = incoming.get(edge.targetEClassId) ?? [];
    candidates.push({
      source: edge.sourceEClassId,
      order,
      edgeId: graphEdgeKey(edge, order),
    });
    incoming.set(edge.targetEClassId, candidates);
  });

  const parentById = new Map<string, string>();
  const treeEdgeIds = new Set<string>();
  for (const eclass of eclasses) {
    if (eclass.id === rootId) continue;
    const candidates = incoming.get(eclass.id) ?? [];
    candidates.sort((left, right) => {
      const depthDelta = depthOf(right.source, depths, fallbackDepth)
        - depthOf(left.source, depths, fallbackDepth);
      return depthDelta || left.order - right.order || left.source.localeCompare(right.source);
    });
    const parent = candidates[0];
    if (parent) {
      parentById.set(eclass.id, parent.source);
      treeEdgeIds.add(parent.edgeId);
    }
  }

  const childrenById = new Map<string, string[]>();
  for (const eclass of eclasses) childrenById.set(eclass.id, []);
  for (const edge of edges) {
    if (parentById.get(edge.targetEClassId) !== edge.sourceEClassId) continue;
    const children = childrenById.get(edge.sourceEClassId);
    if (children && !children.includes(edge.targetEClassId)) children.push(edge.targetEClassId);
  }

  const roots = eclasses
    .filter((eclass) => !parentById.has(eclass.id))
    .map((eclass) => eclass.id)
    .sort((left, right) => {
      if (left === rootId) return -1;
      if (right === rootId) return 1;
      const depthDelta = depthOf(left, depths, fallbackDepth) - depthOf(right, depths, fallbackDepth);
      return depthDelta || left.localeCompare(right);
    });
  return { childrenById, parentById, treeEdgeIds, roots };
}

export function layoutEClasses(
  eclasses: EClass[],
  depthByEClass: Map<string, number>,
  edges: GraphEdge[] = [],
  rootEClassId?: string,
  estimatedHeightByEClass: Map<string, number> = new Map(),
): HierarchicalLayout {
  if (eclasses.length === 0) {
    return { positioned: [], parentByEClass: new Map(), treeEdgeIds: new Set() };
  }

  const tree = primaryTree(eclasses, depthByEClass, edges, rootEClassId);
  const widths = new Map<string, number>();
  const subtreeWidth = (id: string): number => {
    const cached = widths.get(id);
    if (cached !== undefined) return cached;
    const children = tree.childrenById.get(id) ?? [];
    const childrenWidth = children.reduce((sum, child) => sum + subtreeWidth(child), 0)
      + Math.max(0, children.length - 1) * SIBLING_GAP;
    const width = Math.max(NODE_WIDTH, childrenWidth);
    widths.set(id, width);
    return width;
  };
  tree.roots.forEach(subtreeWidth);

  const fallbackDepth = Math.max(0, ...depthByEClass.values()) + 1;
  const depths = [...new Set(eclasses.map((eclass) => depthOf(
    eclass.id,
    depthByEClass,
    fallbackDepth,
  )))].sort((left, right) => left - right);
  const yByDepth = new Map<number, number>();
  let nextY = 0;
  for (const depth of depths) {
    yByDepth.set(depth, nextY);
    const levelHeight = Math.max(DEFAULT_NODE_HEIGHT, ...eclasses
      .filter((eclass) => depthOf(eclass.id, depthByEClass, fallbackDepth) === depth)
      .map((eclass) => estimatedHeightByEClass.get(eclass.id) ?? DEFAULT_NODE_HEIGHT));
    nextY += levelHeight + ROW_GAP;
  }
  const positions = new Map<string, { x: number; y: number }>();
  const place = (id: string, left: number): void => {
    const width = subtreeWidth(id);
    positions.set(id, {
      x: left + (width - NODE_WIDTH) / 2,
      y: yByDepth.get(depthOf(id, depthByEClass, fallbackDepth)) ?? 0,
    });
    let childLeft = left;
    for (const child of tree.childrenById.get(id) ?? []) {
      place(child, childLeft);
      childLeft += subtreeWidth(child) + SIBLING_GAP;
    }
  };

  let left = 0;
  for (const root of tree.roots) {
    place(root, left);
    left += subtreeWidth(root) + COMPONENT_GAP;
  }

  const anchorId = rootEClassId && positions.has(rootEClassId) ? rootEClassId : tree.roots[0];
  const anchorCenter = anchorId ? (positions.get(anchorId)?.x ?? 0) + NODE_WIDTH / 2 : 0;
  const positioned = eclasses.map((eclass) => {
    const position = positions.get(eclass.id) ?? {
      x: 0,
      y: yByDepth.get(fallbackDepth) ?? 0,
    };
    return {
      eclass,
      position: { x: position.x - anchorCenter, y: position.y },
    };
  });

  return {
    positioned,
    parentByEClass: tree.parentById,
    treeEdgeIds: tree.treeEdgeIds,
  };
}
