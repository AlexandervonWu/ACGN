import { PanelHeader } from "../Common/PanelHeader";

export function InspectorEmptyState() {
  return (
    <section className="workspace-panel inspector-panel" aria-label="Inspector">
      <PanelHeader title="Inspector" />
      <div className="empty-panel">No graph object selected</div>
    </section>
  );
}

