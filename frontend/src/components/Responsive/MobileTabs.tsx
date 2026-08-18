import { Braces, GitBranch, ListTree, Network, PanelRight } from "lucide-react";
import { useUiStore, type MobilePanel } from "../../state/uiStore";

const tabs: Array<{ id: MobilePanel; label: string; icon: typeof Braces }> = [
  { id: "source", label: "Source", icon: Braces },
  { id: "graph", label: "Graph", icon: Network },
  { id: "pipeline", label: "Pipeline", icon: GitBranch },
  { id: "trace", label: "Trace", icon: ListTree },
  { id: "inspector", label: "Inspector", icon: PanelRight },
];

export function MobileTabs() {
  const active = useUiStore((state) => state.mobilePanel);
  const setActive = useUiStore((state) => state.setMobilePanel);
  return (
    <nav className="mobile-tabs" aria-label="Workspace panels">
      {tabs.map(({ id, label, icon: Icon }) => (
        <button type="button" key={id} className={active === id ? "is-active" : ""} onClick={() => setActive(id)}>
          <Icon size={15} /><span>{label}</span>
        </button>
      ))}
    </nav>
  );
}

