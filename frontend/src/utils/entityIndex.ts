import type { EClass, EGraph, ENode } from "../api/types";

export interface EntityIndex {
  eclasses: Map<string, EClass>;
  enodes: Map<string, { eclass: EClass; enode: ENode }>;
  parents: Map<string, Set<string>>;
}

export function indexGraph(graph: EGraph): EntityIndex {
  const eclasses = new Map(graph.eclasses.map((eclass) => [eclass.id, eclass]));
  const enodes = new Map<string, { eclass: EClass; enode: ENode }>();
  const parents = new Map<string, Set<string>>();
  for (const eclass of graph.eclasses) {
    for (const enode of eclass.nodes) {
      enodes.set(enode.id, { eclass, enode });
      for (const child of enode.children) {
        const values = parents.get(child.eclassId) ?? new Set<string>();
        values.add(eclass.id);
        parents.set(child.eclassId, values);
      }
    }
  }
  return { eclasses, enodes, parents };
}

