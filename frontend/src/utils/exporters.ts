import type { EGraphAnalysis } from "../api/types";
import { analysisCallable } from "../api/callables";
import { buildVisibleGraph } from "../graph/buildVisibleGraph";
import { graphEdgeKey, layoutEClasses } from "../graph/layout";
import type { GraphFilters } from "../state/uiStore";
import { formatType } from "./formatters";

function download(name: string, body: BlobPart, type: string): void {
  const url = URL.createObjectURL(new Blob([body], { type }));
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = name;
  anchor.click();
  URL.revokeObjectURL(url);
}

export function exportAnalysisJson(analysis: EGraphAnalysis): void {
  download(
    `${analysisCallable(analysis).name}-egraph.json`,
    JSON.stringify(analysis, null, 2),
    "application/json",
  );
}

function escapeXml(value: string): string {
  return value.replace(/[<>&"']/g, (character) => ({
    "<": "&lt;",
    ">": "&gt;",
    "&": "&amp;",
    "\"": "&quot;",
    "'": "&apos;",
  }[character] ?? character));
}

export function exportVisibleGraphSvg(
  analysis: EGraphAnalysis,
  filters: GraphFilters,
  expandedClasses: Set<string>,
): void {
  const svg = buildVisibleGraphSvg(analysis, filters, expandedClasses);
  download(`${analysisCallable(analysis).name}-visible-egraph.svg`, svg, "image/svg+xml");
}

export function buildVisibleGraphSvg(
  analysis: EGraphAnalysis,
  filters: GraphFilters,
  expandedClasses: Set<string>,
): string {
  const visible = buildVisibleGraph(analysis.graph, filters, expandedClasses);
  const hierarchy = layoutEClasses(
    visible.eclasses,
    visible.depthByEClass,
    visible.edges,
    analysis.graph.rootEClassId,
  );
  const positioned = hierarchy.positioned;
  const offsetX = positioned.length
    ? 40 - Math.min(...positioned.map((item) => item.position.x))
    : 0;
  const boxes = new Map(positioned.map((item) => [
    item.eclass.id,
    {
      x: item.position.x + offsetX,
      y: item.position.y,
      width: 270,
      height: 110,
    },
  ]));
  const renderableEdges = visible.edges.flatMap((edge, index) => {
    const primary = hierarchy.treeEdgeIds.has(graphEdgeKey(edge, index));
    if (!primary && !filters.showCrossLinks) return [];
    const source = boxes.get(edge.sourceEClassId);
    const target = boxes.get(edge.targetEClassId);
    if (!source || !target) return [];
    return [{ edge, index, primary, source, target }];
  });
  const parallelGroups = new Map<string, typeof renderableEdges>();
  for (const rendered of renderableEdges) {
    const key = `${rendered.edge.sourceEClassId}\u0000${rendered.edge.targetEClassId}`;
    const group = parallelGroups.get(key) ?? [];
    group.push(rendered);
    parallelGroups.set(key, group);
  }
  const routeBounds: Array<{ x: number; y: number }> = [];
  const lines = renderableEdges.map((rendered) => {
    const { edge, index, primary, source, target } = rendered;
    const style = primary
      ? 'stroke="#687781" stroke-width="1.5"'
      : 'stroke="#a7b0b7" stroke-width="1" stroke-dasharray="5 5"';
    const groupKey = `${edge.sourceEClassId}\u0000${edge.targetEClassId}`;
    const group = parallelGroups.get(groupKey) ?? [rendered];
    const ordinal = group.indexOf(rendered);
    const offset = (ordinal - (group.length - 1) / 2) * 24;
    let path: string;
    let labelX: number;
    let labelY: number;
    if (edge.sourceEClassId === edge.targetEClassId) {
      const startX = source.x + source.width;
      const startY = source.y + 34;
      const endX = source.x + source.width;
      const endY = source.y + 78;
      const outerX = source.x + source.width + 58 + ordinal * 30;
      const upperY = source.y + 8 - ordinal * 8;
      const lowerY = source.y + source.height - 8 + ordinal * 8;
      path = `M ${startX} ${startY} C ${outerX} ${upperY} ${outerX} ${lowerY} ${endX} ${endY}`;
      labelX = outerX + 5;
      labelY = source.y + source.height / 2;
      routeBounds.push(
        { x: startX, y: startY },
        { x: outerX, y: upperY },
        { x: outerX, y: lowerY },
        { x: endX, y: endY },
      );
    } else if (target.y > source.y + source.height / 2) {
      const startX = source.x + source.width / 2;
      const startY = source.y + source.height;
      const endX = target.x + target.width / 2;
      const endY = target.y;
      const deltaX = endX - startX;
      const deltaY = endY - startY;
      const length = Math.hypot(deltaX, deltaY) || 1;
      const controlX = (startX + endX) / 2 - (deltaY / length) * offset;
      const controlY = (startY + endY) / 2 + (deltaX / length) * offset;
      path = `M ${startX} ${startY} Q ${controlX} ${controlY} ${endX} ${endY}`;
      labelX = (startX + 2 * controlX + endX) / 4;
      labelY = (startY + 2 * controlY + endY) / 4 - 5;
      routeBounds.push(
        { x: startX, y: startY },
        { x: controlX, y: controlY },
        { x: endX, y: endY },
      );
    } else {
      const startX = source.x + source.width;
      const startY = source.y + source.height / 2;
      const endX = target.x + target.width;
      const endY = target.y + target.height / 2;
      const outerX = Math.max(startX, endX) + 55 + ordinal * 30;
      path = `M ${startX} ${startY} C ${outerX} ${startY} ${outerX} ${endY} ${endX} ${endY}`;
      labelX = outerX + 5;
      labelY = (startY + endY) / 2 - 5;
      routeBounds.push(
        { x: startX, y: startY },
        { x: outerX, y: startY },
        { x: outerX, y: endY },
        { x: endX, y: endY },
      );
    }
    const role = edge.role ?? "";
    const labelHalfWidth = Math.max(6, role.length * 3.2);
    routeBounds.push(
      { x: labelX - labelHalfWidth, y: labelY - 12 },
      { x: labelX + labelHalfWidth, y: labelY + 5 },
    );
    const edgeId = graphEdgeKey(edge, index);
    const label = role
      ? `<text x="${labelX}" y="${labelY}" text-anchor="middle" font-family="Segoe UI,Arial" font-size="10" fill="#46525d" paint-order="stroke" stroke="#f4f6f8" stroke-width="3">${escapeXml(role)}</text>`
      : "";
    return `<g data-edge-id="${escapeXml(edgeId)}" data-edge-role="${escapeXml(role)}" class="${primary ? "tree-edge" : "cross-edge"}"><path d="${path}" fill="none" ${style} marker-end="url(#arrow)"/>${label}</g>`;
  }).join("");
  const nodes = positioned.map(({ eclass, position }) => {
    const x = position.x + offsetX;
    const y = position.y;
    const label = eclass.nodes.find((node) => node.id === eclass.canonicalNodeId)
      ?.displayName ?? eclass.nodes[0]?.displayName ?? eclass.nodes[0]?.kind ?? "empty";
    return `<g transform="translate(${x},${y})"><rect width="270" height="110" rx="4" fill="#ffffff" stroke="#53616f"/><rect width="270" height="34" rx="4" fill="#edf2f3"/><text x="12" y="22" font-family="Segoe UI,Arial" font-size="13" font-weight="700" fill="#17202a">${escapeXml(eclass.id)}</text><text x="258" y="22" text-anchor="end" font-family="Segoe UI,Arial" font-size="11" fill="#53616f">${escapeXml(formatType(eclass.type))}</text><text x="12" y="60" font-family="Consolas,monospace" font-size="12" fill="#17202a">${escapeXml(label)}</text><text x="12" y="88" font-family="Segoe UI,Arial" font-size="10" fill="#6f7884">${eclass.nodes.length} e-node${eclass.nodes.length === 1 ? "" : "s"}</text></g>`;
  }).join("");
  const nodeBounds = positioned.flatMap(({ position }) => [
    { x: position.x + offsetX, y: position.y },
    { x: position.x + offsetX + 270, y: position.y + 110 },
  ]);
  const allBounds = [...nodeBounds, ...routeBounds];
  const margin = 40;
  const minimumX = allBounds.length ? Math.min(...allBounds.map((point) => point.x)) : 0;
  const minimumY = allBounds.length ? Math.min(...allBounds.map((point) => point.y)) : 0;
  const maximumX = allBounds.length ? Math.max(...allBounds.map((point) => point.x)) : 400;
  const maximumY = allBounds.length ? Math.max(...allBounds.map((point) => point.y)) : 240;
  const viewX = Math.floor(minimumX - margin);
  const viewY = Math.floor(minimumY - margin);
  const viewWidth = Math.max(480, Math.ceil(maximumX - minimumX + margin * 2));
  const viewHeight = Math.max(320, Math.ceil(maximumY - minimumY + margin * 2));
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${viewWidth}" height="${viewHeight}" viewBox="${viewX} ${viewY} ${viewWidth} ${viewHeight}"><defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#6f7884"/></marker></defs><rect x="${viewX}" y="${viewY}" width="${viewWidth}" height="${viewHeight}" fill="#f4f6f8"/>${lines}${nodes}</svg>`;
  return svg;
}

export async function copyCanonicalRepresentation(analysis: EGraphAnalysis): Promise<void> {
  const callable = analysisCallable(analysis);
  if (!callable.canonicalText) return;
  await navigator.clipboard.writeText(callable.canonicalText);
}
