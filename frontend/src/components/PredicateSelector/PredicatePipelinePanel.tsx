import { Braces, ChevronRight, GitBranch, LoaderCircle } from "lucide-react";
import type {
  Diagnostic,
  EGraphAnalysis,
  ModelInspection,
  NormalizationStage,
} from "../../api/types";
import type { ExampleName } from "../../examples";
import { DiagnosticsList } from "../Diagnostics/DiagnosticsList";
import { PanelHeader } from "../Common/PanelHeader";
import { Pipeline } from "../Pipeline/Pipeline";

interface PredicatePipelinePanelProps {
  inspection?: ModelInspection;
  inspectionError?: string;
  analysis?: EGraphAnalysis;
  selectedPredicate?: string;
  currentStageId?: string;
  exampleName: ExampleName;
  inspecting: boolean;
  onSelectPredicate: (name: string) => void;
  onSelectStage: (stage: NormalizationStage) => void;
  onSelectExample: (name: ExampleName) => void;
}

export function PredicatePipelinePanel({
  inspection,
  inspectionError,
  analysis,
  selectedPredicate,
  currentStageId,
  exampleName,
  inspecting,
  onSelectPredicate,
  onSelectStage,
  onSelectExample,
}: PredicatePipelinePanelProps) {
  const diagnostics: Diagnostic[] = [
    ...(inspection?.parseDiagnostics ?? []),
    ...(analysis?.diagnostics ?? []),
  ];
  return (
    <section className="workspace-panel lower-left-panel" aria-label="Predicates and pipeline">
      <PanelHeader title="Predicates / Pipeline" />
      <div className="predicate-tools">
        <label>
          <span>Example</span>
          <select value={exampleName} onChange={(event) => onSelectExample(event.target.value as ExampleName)}>
            <option value="simple">Simple</option>
            <option value="alpha">Alpha equivalence</option>
            <option value="aci">ACI container</option>
            <option value="prenex">Prenex</option>
            <option value="slots">Typed slots</option>
          </select>
        </label>
        {inspecting && <LoaderCircle className="spin" size={15} aria-label="Inspecting model" />}
      </div>
      <div className="predicate-list" role="listbox" aria-label="Model predicates">
        {(inspection?.predicates ?? []).map((predicate) => (
          <button
            type="button"
            role="option"
            aria-selected={selectedPredicate === predicate.name}
            className={selectedPredicate === predicate.name ? "is-selected" : ""}
            key={predicate.name}
            onClick={() => onSelectPredicate(predicate.name)}
          >
            <Braces size={14} />
            <span>{predicate.name}</span>
            {selectedPredicate === predicate.name && <ChevronRight size={14} />}
          </button>
        ))}
        {!inspecting && !inspectionError && inspection?.predicates.length === 0 && (
          <div className="empty-inline">No predicates returned</div>
        )}
        {inspectionError && <div className="inline-error">{inspectionError}</div>}
      </div>
      <div className="subsection-title"><GitBranch size={13} /> Normalization</div>
      <Pipeline
        stages={analysis?.stages ?? []}
        currentStageId={currentStageId}
        onSelect={onSelectStage}
      />
      <DiagnosticsList diagnostics={diagnostics} />
    </section>
  );
}

