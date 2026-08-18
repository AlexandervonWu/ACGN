import type { EClass } from "../api/types";

export interface PositionedEClass {
  eclass: EClass;
  position: { x: number; y: number };
}

const X_GAP = 340;
const Y_GAP = 230;

export function layoutEClasses(
  eclasses: EClass[],
  depthByEClass: Map<string, number>,
): PositionedEClass[] {
  const fallbackDepth = Math.max(0, ...depthByEClass.values()) + 1;
  const levels = new Map<number, EClass[]>();
  for (const eclass of eclasses) {
    const depth = depthByEClass.get(eclass.id) ?? fallbackDepth;
    const level = levels.get(depth) ?? [];
    level.push(eclass);
    levels.set(depth, level);
  }
  const positioned: PositionedEClass[] = [];
  for (const [depth, level] of [...levels.entries()].sort(([a], [b]) => a - b)) {
    level.sort((left, right) => left.id.localeCompare(right.id));
    const totalWidth = Math.max(0, level.length - 1) * X_GAP;
    level.forEach((eclass, index) => positioned.push({
      eclass,
      position: { x: index * X_GAP - totalWidth / 2, y: depth * Y_GAP },
    }));
  }
  return positioned;
}

