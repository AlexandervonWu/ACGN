import { useMemo, useRef, useState } from "react";
import { Filter, Focus, Search, Table2, X } from "lucide-react";
import type { EGraph, SaturationRound } from "../../api/types";
import type { GraphDepth, GraphFilters } from "../../state/uiStore";
import { formatType } from "../../utils/formatters";
import { IconButton } from "../Common/IconButton";

export interface GraphSearchResult {
  id: string;
  eclassId: string;
  enodeId?: string;
  label: string;
  detail: string;
}

function searchGraph(graph: EGraph, query: string): GraphSearchResult[] {
  const needle = query.trim().toLocaleLowerCase();
  if (!needle) return [];
  const results: GraphSearchResult[] = [];
  for (const eclass of graph.eclasses) {
    const classText = [
      eclass.id,
      formatType(eclass.type),
      ...(eclass.support ?? []).flatMap((slot) => [slot.id, slot.type ?? "", slot.displayName ?? ""]),
      ...eclass.provenance?.map((item) => typeof item === "string" ? item : item.label ?? item.kind ?? "") ?? [],
    ].join(" ").toLocaleLowerCase();
    if (classText.includes(needle)) {
      results.push({ id: eclass.id, eclassId: eclass.id, label: eclass.id, detail: formatType(eclass.type) });
    }
    for (const enode of eclass.nodes) {
      const nodeText = [
        enode.id,
        enode.kind,
        enode.displayName ?? "",
        formatType(enode.type),
        ...enode.slots?.flatMap((slot) => [slot.slotId, slot.type ?? "", slot.sourceBinder ?? ""]) ?? [],
        ...Object.values(enode.attributes ?? {}).map(String),
      ].join(" ").toLocaleLowerCase();
      if (nodeText.includes(needle)) {
        results.push({
          id: enode.id,
          eclassId: eclass.id,
          enodeId: enode.id,
          label: enode.displayName ?? enode.kind,
          detail: `${enode.id} · ${eclass.id}`,
        });
      }
      if (results.length >= 12) return results;
    }
  }
  return results;
}

function SaturationTable({ rounds }: { rounds: SaturationRound[] }) {
  return (
    <table className="saturation-table">
      <thead><tr><th>Round</th><th>Classes</th><th>Nodes</th><th>Merges</th><th>Rebuilds</th></tr></thead>
      <tbody>
        {rounds.map((round) => (
          <tr key={round.index}>
            <td>{round.index}</td><td>{round.eclassCount}</td><td>{round.enodeCount}</td>
            <td>{round.merges}</td><td>{round.rebuilds ?? "Not provided"}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

interface GraphToolbarProps {
  graph: EGraph;
  filters: GraphFilters;
  graphSearch: string;
  selectedEClassId?: string;
  selectedSlotId?: string;
  onSearchChange: (value: string) => void;
  onSelectResult: (result: GraphSearchResult) => void;
  onFilterChange: <K extends keyof GraphFilters>(key: K, value: GraphFilters[K]) => void;
  onCenterSelected: () => void;
  onClearSlot: () => void;
}

export function GraphToolbar({
  graph,
  filters,
  graphSearch,
  selectedEClassId,
  selectedSlotId,
  onSearchChange,
  onSelectResult,
  onFilterChange,
  onCenterSelected,
  onClearSlot,
}: GraphToolbarProps) {
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [roundsOpen, setRoundsOpen] = useState(false);
  const toolbarRef = useRef<HTMLDivElement>(null);
  const results = useMemo(() => searchGraph(graph, graphSearch), [graph, graphSearch]);
  const depths: GraphDepth[] = [3, 5, 10, "all"];
  return (
    <div className="graph-toolbar" ref={toolbarRef}>
      <div className="graph-search-box">
        <Search size={15} />
        <input
          value={graphSearch}
          onChange={(event) => onSearchChange(event.target.value)}
          placeholder="Search graph"
          aria-label="Search e-graph"
        />
        {graphSearch && (
          <button type="button" aria-label="Clear graph search" onClick={() => onSearchChange("")}><X size={13} /></button>
        )}
        {graphSearch && (
          <div className="graph-search-results">
            {results.map((result) => (
              <button type="button" key={result.id} onClick={() => onSelectResult(result)}>
                <span>{result.label}</span><small>{result.detail}</small>
              </button>
            ))}
            {results.length === 0 && <div>No graph matches</div>}
          </div>
        )}
      </div>
      <IconButton label="Center selected" disabled={!selectedEClassId} onClick={onCenterSelected}>
        <Focus size={16} />
      </IconButton>
      {selectedSlotId && (
        <button
          type="button"
          className="slot-selection-control"
          aria-label={`Clear slot selection ${selectedSlotId}`}
          title="Clear slot selection"
          onClick={onClearSlot}
        >
          <code>{selectedSlotId}</code><X size={13} />
        </button>
      )}
      <div className="toolbar-popover-anchor">
        <IconButton label="Graph filters" className={filtersOpen ? "is-active" : ""} onClick={() => setFiltersOpen((open) => !open)}>
          <Filter size={16} />
        </IconButton>
        {filtersOpen && (
          <div className="graph-filter-popover">
            <label><input type="checkbox" checked={filters.reachableOnly} onChange={(event) => onFilterChange("reachableOnly", event.target.checked)} />Reachable from root</label>
            <label><input type="checkbox" checked={filters.collapseSingleton} onChange={(event) => onFilterChange("collapseSingleton", event.target.checked)} />Collapse singleton classes</label>
            <label><input type="checkbox" checked={filters.collapseLarge} onChange={(event) => onFilterChange("collapseLarge", event.target.checked)} />Collapse large e-classes</label>
            <label><input type="checkbox" checked={filters.showAllAlternatives} onChange={(event) => onFilterChange("showAllAlternatives", event.target.checked)} />Show all e-node alternatives</label>
            <label><input type="checkbox" checked={filters.showHistorical} onChange={(event) => onFilterChange("showHistorical", event.target.checked)} />Show historical nodes</label>
            <label><input type="checkbox" checked={filters.showRebuildDetails} onChange={(event) => onFilterChange("showRebuildDetails", event.target.checked)} />Show rebuild details</label>
            <fieldset>
              <legend>Depth</legend>
              <div className="segmented-control">
                {depths.map((depth) => (
                  <button
                    type="button"
                    key={depth}
                    className={filters.depth === depth ? "is-active" : ""}
                    onClick={() => onFilterChange("depth", depth)}
                  >
                    {depth === "all" ? "All" : depth}
                  </button>
                ))}
              </div>
            </fieldset>
          </div>
        )}
      </div>
      {(graph.saturation?.rounds?.length ?? 0) > 0 && (
        <div className="toolbar-popover-anchor">
          <IconButton label="Saturation timeline" className={roundsOpen ? "is-active" : ""} onClick={() => setRoundsOpen((open) => !open)}>
            <Table2 size={16} />
          </IconButton>
          {roundsOpen && <div className="rounds-popover"><SaturationTable rounds={graph.saturation?.rounds ?? []} /></div>}
        </div>
      )}
    </div>
  );
}
