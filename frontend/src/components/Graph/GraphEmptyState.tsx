import { Braces, Network } from "lucide-react";
import { PanelHeader } from "../Common/PanelHeader";

export function GraphEmptyState() {
  return (
    <section className="workspace-panel graph-panel" aria-label="E-graph">
      <PanelHeader title="Graph" />
      <div className="graph-empty-state">
        <div className="empty-graph-visual" aria-hidden="true">
          <span><Braces size={19} /></span>
          <i /><span><Network size={19} /></span><i /><span>E</span>
        </div>
        <strong>No analysis loaded</strong>
        <span>Select a predicate and run analysis.</span>
      </div>
    </section>
  );
}

