import { GitBranch, LoaderCircle } from "lucide-react";
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
  const callables = inspection?.callables ?? [];
  const predicates = callables.filter((callable) => callable.kind === "predicate");
  const functions = callables.filter((callable) => callable.kind === "function");
  const diagnostics: Diagnostic[] = [
    ...(inspection?.parseDiagnostics ?? []),
    ...(analysis?.diagnostics ?? []),
  ];
  return (
    <section className="workspace-panel lower-left-panel" aria-label="Callables and pipeline">
      <PanelHeader title="Callables / Pipeline" />
      <div className="predicate-tools">
        <label>
          <span>Example</span>
          <select value={exampleName} onChange={(event) => onSelectExample(event.target.value as ExampleName)}>
            <option value="simple">Simple</option>
            <option value="alpha">Alpha equivalence</option>
            <option value="aci">ACI container</option>
            <option value="prenex">Prenex</option>
            <option value="slots">Typed slots</option>
            <option value="callables">Function callable</option>
          </select>
        </label>
        <label>
          <span>Target</span>
          <select
            aria-label="Callable to visualize"
            disabled={inspecting || callables.length === 0}
            value={selectedPredicate ?? ""}
            onChange={(event) => onSelectPredicate(event.target.value)}
          >
            <option value="">Choose a predicate or function</option>
            {predicates.length > 0 && (
              <optgroup label="Predicates">
                {predicates.map((callable) => (
                  <option key={`predicate:${callable.name}`} value={callable.name}>
                    {callable.name} - pred
                  </option>
                ))}
              </optgroup>
            )}
            {functions.length > 0 && (
              <optgroup label="Functions">
                {functions.map((callable) => (
                  <option key={`function:${callable.name}`} value={callable.name}>
                    {callable.name} - {"returnType" in callable ? callable.returnType ?? "fun" : "fun"}
                  </option>
                ))}
              </optgroup>
            )}
          </select>
        </label>
        {inspecting && <LoaderCircle className="spin" size={15} aria-label="Inspecting model" />}
      </div>
      {!inspecting && !inspectionError && inspection?.callables.length === 0 && (
        <div className="empty-inline">No predicates or functions returned</div>
      )}
      {inspectionError && <div className="inline-error">{inspectionError}</div>}
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
