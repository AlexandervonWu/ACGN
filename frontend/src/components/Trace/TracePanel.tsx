import { useEffect, useMemo, useRef, useState } from "react";
import {
  GitMerge,
  History,
  RefreshCcw,
  Search,
  Shuffle,
  Sparkles,
  X,
} from "lucide-react";
import type { EGraph, TraceEvent } from "../../api/types";
import { useUiStore } from "../../state/uiStore";
import { indexGraph } from "../../utils/entityIndex";
import { PanelHeader } from "../Common/PanelHeader";

const ROW_HEIGHT = 54;
const traceKinds = ["all", "rewrite", "merge", "normalize", "slot-map", "rebuild"] as const;

const kindIcons = {
  rewrite: Shuffle,
  merge: GitMerge,
  rebuild: RefreshCcw,
  normalize: Sparkles,
  "slot-map": GitMerge,
  canonicalize: Sparkles,
  other: History,
};

function relatedToSelection(event: TraceEvent, eclassId?: string, enodeId?: string): boolean {
  const classIds = [...(event.beforeEClassIds ?? []), ...(event.afterEClassIds ?? [])];
  const nodeIds = [...(event.beforeENodeIds ?? []), ...(event.afterENodeIds ?? [])];
  return (eclassId !== undefined && classIds.includes(eclassId))
    || (enodeId !== undefined && nodeIds.includes(enodeId));
}

export function TracePanel({ trace = [], graph }: { trace?: TraceEvent[]; graph?: EGraph }) {
  const traceKind = useUiStore((state) => state.traceKind);
  const traceSearch = useUiStore((state) => state.traceSearch);
  const traceSelectedOnly = useUiStore((state) => state.traceSelectedOnly);
  const selectedEClassId = useUiStore((state) => state.selectedEClassId);
  const selectedENodeId = useUiStore((state) => state.selectedENodeId);
  const setTraceKind = useUiStore((state) => state.setTraceKind);
  const setTraceSearch = useUiStore((state) => state.setTraceSearch);
  const setTraceSelectedOnly = useUiStore((state) => state.setTraceSelectedOnly);
  const setHighlightedEntities = useUiStore((state) => state.setHighlightedEntities);
  const selectEClass = useUiStore((state) => state.selectEClass);
  const selectENode = useUiStore((state) => state.selectENode);
  const setCurrentStage = useUiStore((state) => state.setCurrentStage);
  const requestFocus = useUiStore((state) => state.requestFocus);
  const viewportRef = useRef<HTMLDivElement>(null);
  const [scrollTop, setScrollTop] = useState(0);
  const [viewportHeight, setViewportHeight] = useState(260);
  const graphIndex = useMemo(() => graph ? indexGraph(graph) : undefined, [graph]);

  const filtered = useMemo(() => {
    const needle = traceSearch.trim().toLocaleLowerCase();
    return trace.filter((event) => {
      if (traceKind !== "all" && event.kind !== traceKind) return false;
      if (traceSelectedOnly && !relatedToSelection(event, selectedEClassId, selectedENodeId)) return false;
      if (!needle) return true;
      return [
        event.id,
        event.kind,
        event.rule ?? "",
        event.summary,
        ...(event.beforeEClassIds ?? []),
        ...(event.afterEClassIds ?? []),
        ...(event.beforeENodeIds ?? []),
        ...(event.afterENodeIds ?? []),
      ].join(" ").toLocaleLowerCase().includes(needle);
    });
  }, [selectedEClassId, selectedENodeId, trace, traceKind, traceSearch, traceSelectedOnly]);

  useEffect(() => {
    const element = viewportRef.current;
    if (!element) return;
    const observer = new ResizeObserver(() => setViewportHeight(element.clientHeight));
    observer.observe(element);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    setScrollTop(0);
    if (viewportRef.current) viewportRef.current.scrollTop = 0;
  }, [traceKind, traceSearch, traceSelectedOnly]);

  const start = Math.max(0, Math.floor(scrollTop / ROW_HEIGHT) - 3);
  const count = Math.ceil(viewportHeight / ROW_HEIGHT) + 6;
  const visibleRows = filtered.slice(start, start + count);

  const activate = (event: TraceEvent) => {
    const entityIds = [
      ...(event.afterEClassIds ?? event.beforeEClassIds ?? []),
      ...(event.afterENodeIds ?? event.beforeENodeIds ?? []),
    ];
    const enode = event.afterENodeIds?.[0] ?? event.beforeENodeIds?.[0];
    const eclass = event.afterEClassIds?.[0]
      ?? event.beforeEClassIds?.[0]
      ?? (enode ? graphIndex?.enodes.get(enode)?.eclass.id : undefined);
    if (enode) selectENode(enode, eclass);
    else if (eclass) selectEClass(eclass);
    setHighlightedEntities(entityIds);
    if (event.stageId) setCurrentStage(event.stageId);
    requestFocus();
  };

  return (
    <section className="workspace-panel trace-panel" aria-label="Trace and derivation">
      <PanelHeader title="Trace / Derivation" count={trace.length} />
      <div className="trace-controls">
        <div className="trace-kind-tabs" role="tablist" aria-label="Trace kind">
          {traceKinds.map((kind) => (
            <button
              type="button"
              role="tab"
              aria-selected={traceKind === kind}
              className={traceKind === kind ? "is-active" : ""}
              key={kind}
              onClick={() => setTraceKind(kind)}
            >
              {kind === "all" ? "All" : kind === "slot-map" ? "Slot" : `${kind[0]?.toUpperCase()}${kind.slice(1)}`}
            </button>
          ))}
        </div>
        <div className="trace-search">
          <Search size={14} />
          <input value={traceSearch} onChange={(event) => setTraceSearch(event.target.value)} placeholder="Rule or entity" aria-label="Search trace" />
          {traceSearch && <button type="button" aria-label="Clear trace search" onClick={() => setTraceSearch("")}><X size={12} /></button>}
        </div>
        <label className="selected-only-toggle">
          <input type="checkbox" checked={traceSelectedOnly} onChange={(event) => setTraceSelectedOnly(event.target.checked)} />
          Selected
        </label>
      </div>
      <div
        ref={viewportRef}
        className="virtual-trace"
        onScroll={(event) => setScrollTop(event.currentTarget.scrollTop)}
      >
        <div className="virtual-trace-space" style={{ height: filtered.length * ROW_HEIGHT }}>
          {visibleRows.map((event, visibleIndex) => {
            const Icon = kindIcons[event.kind];
            const top = (start + visibleIndex) * ROW_HEIGHT;
            return (
              <button
                type="button"
                className={`trace-row trace-${event.kind}`}
                style={{ transform: `translateY(${top}px)`, height: ROW_HEIGHT }}
                key={event.id}
                onClick={() => activate(event)}
              >
                <span className="trace-index">#{String(event.index).padStart(3, "0")}</span>
                <Icon size={14} />
                <span className="trace-row-main">
                  <strong>{event.rule ?? event.kind}</strong>
                  <small>{event.summary}</small>
                </span>
              </button>
            );
          })}
          {filtered.length === 0 && <div className="trace-empty">No matching trace events</div>}
        </div>
      </div>
    </section>
  );
}
