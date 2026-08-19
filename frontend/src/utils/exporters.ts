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
  const width = positioned.length
    ? Math.max(...positioned.map((item) => item.position.x + offsetX + 270)) + 40
    : 480;
  const height = positioned.length
    ? Math.max(...positioned.map((item) => item.position.y)) + 150
    : 320;
  const centers = new Map(positioned.map((item) => [
    item.eclass.id,
    { x: item.position.x + offsetX + 135, y: item.position.y + 55 },
  ]));
  const lines = visible.edges.flatMap((edge, index) => {
    const primary = hierarchy.treeEdgeIds.has(graphEdgeKey(edge, index));
    if (!primary && !filters.showCrossLinks) return [];
    const source = centers.get(edge.sourceEClassId);
    const target = centers.get(edge.targetEClassId);
    if (!source || !target) return [];
    const style = primary
      ? 'stroke="#687781" stroke-width="1.5"'
      : 'stroke="#a7b0b7" stroke-width="1" stroke-dasharray="5 5"';
    return [`<line x1="${source.x}" y1="${source.y + 55}" x2="${target.x}" y2="${target.y - 55}" ${style} marker-end="url(#arrow)" />`];
  }).join("");
  const nodes = positioned.map(({ eclass, position }) => {
    const x = position.x + offsetX;
    const y = position.y;
    const label = eclass.nodes.find((node) => node.id === eclass.canonicalNodeId)
      ?.displayName ?? eclass.nodes[0]?.displayName ?? eclass.nodes[0]?.kind ?? "empty";
    return `<g transform="translate(${x},${y})"><rect width="270" height="110" rx="4" fill="#ffffff" stroke="#53616f"/><rect width="270" height="34" rx="4" fill="#edf2f3"/><text x="12" y="22" font-family="Segoe UI,Arial" font-size="13" font-weight="700" fill="#17202a">${escapeXml(eclass.id)}</text><text x="258" y="22" text-anchor="end" font-family="Segoe UI,Arial" font-size="11" fill="#53616f">${escapeXml(formatType(eclass.type))}</text><text x="12" y="60" font-family="Consolas,monospace" font-size="12" fill="#17202a">${escapeXml(label)}</text><text x="12" y="88" font-family="Segoe UI,Arial" font-size="10" fill="#6f7884">${eclass.nodes.length} e-node${eclass.nodes.length === 1 ? "" : "s"}</text></g>`;
  }).join("");
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}"><defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#6f7884"/></marker></defs><rect width="100%" height="100%" fill="#f4f6f8"/>${lines}${nodes}</svg>`;
  download(`${analysisCallable(analysis).name}-visible-egraph.svg`, svg, "image/svg+xml");
}

export async function copyCanonicalRepresentation(analysis: EGraphAnalysis): Promise<void> {
  const callable = analysisCallable(analysis);
  if (!callable.canonicalText) return;
  await navigator.clipboard.writeText(callable.canonicalText);
}
