import type { EClass, EGraph, ENode, GraphEdge } from "../api/types";
import type { GraphFilters } from "../state/uiStore";

export const LARGE_GRAPH_THRESHOLD = 500;
export const MAX_RENDERED_ECLASSES = 250;
export const LARGE_ECLASS_THRESHOLD = 4;

export interface VisibleGraph {
  eclasses: EClass[];
  edges: GraphEdge[];
  depthByEClass: Map<string, number>;
  reachableCount: number;
  restricted: boolean;
  omittedCount: number;
}

export function displayNodes(eclass: EClass, filters: GraphFilters, expanded: boolean): ENode[] {
  if (expanded) return eclass.nodes;
  const eligible = eclass.nodes.filter((node) => {
    if (!filters.showHistorical && node.attributes?.historical === true) return false;
    if (!filters.showRebuildDetails && node.attributes?.rebuildDetail === true) return false;
    return true;
  });
  if (filters.showAllAlternatives) return eligible;
  const preferred = eclass.canonicalNodeId ?? eclass.representativeNodeId;
  return [eligible.find((node) => node.id === preferred) ?? eligible[0]].filter(Boolean);
}

function adjacency(
  graph: EGraph,
  filters: GraphFilters,
  expandedClasses: Set<string>,
): Map<string, Set<string>> {
  const result = new Map<string, Set<string>>();
  for (const eclass of graph.eclasses) {
    const children = result.get(eclass.id) ?? new Set<string>();
    const displayed = displayNodes(eclass, filters, expandedClasses.has(eclass.id));
    const displayedIds = new Set(displayed.map((node) => node.id));
    for (const node of displayed) {
      for (const child of node.children) children.add(child.eclassId);
    }
    for (const edge of graph.edges ?? []) {
      if (edge.sourceEClassId === eclass.id
        && (!edge.enodeId || displayedIds.has(edge.enodeId))) {
        children.add(edge.targetEClassId);
      }
    }
    result.set(eclass.id, children);
  }
  return result;
}

function rootDistances(
  graph: EGraph,
  filters: GraphFilters,
  expandedClasses: Set<string>,
): Map<string, number> {
  const links = adjacency(graph, filters, expandedClasses);
  const depths = new Map<string, number>([[graph.rootEClassId, 0]]);
  const queue = [graph.rootEClassId];
  for (let cursor = 0; cursor < queue.length; cursor += 1) {
    const current = queue[cursor];
    if (!current) continue;
    const depth = depths.get(current) ?? 0;
    for (const child of links.get(current) ?? []) {
      if (!depths.has(child)) {
        depths.set(child, depth + 1);
        queue.push(child);
      }
    }
  }
  return depths;
}

function inferredEdges(
  eclasses: EClass[],
  filters: GraphFilters,
  expandedClasses: Set<string>,
): GraphEdge[] {
  const edges: GraphEdge[] = [];
  for (const eclass of eclasses) {
    for (const node of displayNodes(eclass, filters, expandedClasses.has(eclass.id))) {
      node.children.forEach((child, index) => {
        edges.push({
          id: `${eclass.id}:${node.id}:${child.eclassId}:${child.role ?? index}`,
          sourceEClassId: eclass.id,
          targetEClassId: child.eclassId,
          role: child.role,
          enodeId: node.id,
        });
      });
    }
  }
  return edges;
}

export function shouldCollapseEClass(
  eclass: EClass,
  filters: GraphFilters,
  expandedClasses: Set<string>,
): boolean {
  if (expandedClasses.has(eclass.id)) return false;
  if (filters.collapseSingleton && eclass.nodes.length === 1) return true;
  return filters.collapseLarge && eclass.nodes.length >= LARGE_ECLASS_THRESHOLD;
}

export function buildVisibleGraph(
  graph: EGraph,
  filters: GraphFilters,
  expandedClasses: Set<string>,
  maxRendered = MAX_RENDERED_ECLASSES,
): VisibleGraph {
  const depths = rootDistances(graph, filters, expandedClasses);
  const requestedDepth = filters.depth === "all" ? Number.POSITIVE_INFINITY : filters.depth;
  const forceBounded = graph.eclasses.length > LARGE_GRAPH_THRESHOLD;
  const candidates = graph.eclasses.filter((eclass) => {
    const depth = depths.get(eclass.id);
    if ((filters.reachableOnly || forceBounded) && depth === undefined) return false;
    return depth === undefined || depth <= requestedDepth;
  });
  candidates.sort((left, right) => {
    const depthDelta = (depths.get(left.id) ?? Number.MAX_SAFE_INTEGER)
      - (depths.get(right.id) ?? Number.MAX_SAFE_INTEGER);
    return depthDelta || left.id.localeCompare(right.id);
  });
  const visibleClasses = candidates.slice(0, maxRendered);
  const visibleIds = new Set(visibleClasses.map((eclass) => eclass.id));
  const visibleNodeIds = new Set(visibleClasses.flatMap((eclass) => displayNodes(
    eclass,
    filters,
    expandedClasses.has(eclass.id),
  ).map((node) => node.id)));

  const edges = (graph.edges
    ? graph.edges
    : inferredEdges(visibleClasses, filters, expandedClasses))
    .filter((edge) => visibleIds.has(edge.sourceEClassId)
      && visibleIds.has(edge.targetEClassId)
      && (!edge.enodeId || visibleNodeIds.has(edge.enodeId)));

  return {
    eclasses: visibleClasses,
    edges,
    depthByEClass: depths,
    reachableCount: depths.size,
    restricted: forceBounded
      || candidates.length > maxRendered
      || visibleClasses.length < graph.eclasses.length,
    omittedCount: graph.eclasses.length - visibleClasses.length,
  };
}
