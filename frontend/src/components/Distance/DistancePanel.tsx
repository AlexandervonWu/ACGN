import {
  ArrowRight,
  Check,
  Layers3,
  Minus,
  Pencil,
  Plus,
  RefreshCw,
  X,
} from "lucide-react";
import type {
  CallableComparison,
  DistanceOperation,
} from "../../api/types";
import { IconButton } from "../Common/IconButton";
import { PanelHeader } from "../Common/PanelHeader";

interface DistancePanelProps {
  comparison: CallableComparison;
  onClose: () => void;
}

const componentLabels = {
  temporal: "Temporal",
  quantifier: "Quantifier",
  matrix: "Matrix",
} as const;

function OperationIcon({ operation }: { operation: DistanceOperation }) {
  switch (operation.kind) {
    case "insert": return <Plus size={14} />;
    case "delete": return <Minus size={14} />;
    case "modify": return <Pencil size={14} />;
    case "replace": return <RefreshCw size={14} />;
    case "aggregate": return <Layers3 size={14} />;
    case "no-op": return <Check size={14} />;
  }
}

function Operand({ value, empty }: { value?: string; empty: string }) {
  return value
    ? <code title={value}>{value}</code>
    : <span className="distance-empty">{empty}</span>;
}

export function DistancePanel({ comparison, onClose }: DistancePanelProps) {
  const { distance } = comparison;
  return (
    <section className="workspace-panel trace-panel distance-panel" aria-label="Edit distance comparison">
      <PanelHeader
        title="Edit Distance"
        count={distance.total}
        actions={<IconButton label="Close comparison" onClick={onClose}><X size={15} /></IconButton>}
      />
      <div className="distance-scroll">
        <div className="distance-callables">
          <div>
            <span>{comparison.left.kind}</span>
            <strong>{comparison.left.name}</strong>
          </div>
          <ArrowRight size={17} aria-hidden="true" />
          <div>
            <span>{comparison.right.kind}</span>
            <strong>{comparison.right.name}</strong>
          </div>
        </div>

        <div className={`distance-total ${comparison.certifiedEquivalent ? "is-zero" : ""}`}>
          <span>Total repair distance</span>
          <strong>{distance.total}</strong>
          <small>{comparison.certifiedEquivalent ? "Certified equivalent" : "Minimum certified repair"}</small>
        </div>

        <div className="distance-components" aria-label="Distance breakdown">
          {(Object.keys(componentLabels) as Array<keyof typeof componentLabels>).map((component) => {
            const value = distance[component];
            const width = distance.total === 0 ? 0 : (value / distance.total) * 100;
            return (
              <div className={`distance-component component-${component}`} key={component}>
                <span>{componentLabels[component]}</span>
                <strong>{value}</strong>
                <div aria-hidden="true"><i style={{ width: `${width}%` }} /></div>
              </div>
            );
          })}
        </div>

        <div className="distance-operation-heading">
          <strong>Repair operations</strong>
          <span>{comparison.operations.length} shown</span>
        </div>
        <ol className="distance-operations">
          {comparison.operations.map((operation) => (
            <li className={`distance-operation component-${operation.component}`} key={operation.id}>
              <div className="distance-operation-icon"><OperationIcon operation={operation} /></div>
              <div className="distance-operation-main">
                <div className="distance-operation-meta">
                  <span>{operation.component}</span>
                  <code>{operation.path}</code>
                  {operation.detail === "aggregate" && <em>aggregate</em>}
                </div>
                <p>{operation.summary}</p>
                {(operation.source !== undefined || operation.target !== undefined) && (
                  <div className="distance-operation-flow">
                    <Operand value={operation.source} empty="insert" />
                    <ArrowRight size={13} aria-hidden="true" />
                    <Operand value={operation.target} empty="delete" />
                  </div>
                )}
              </div>
              <strong className="distance-operation-cost">+{operation.cost}</strong>
            </li>
          ))}
        </ol>
      </div>
      <div className="distance-footer">
        <span title={comparison.metricVersion}>{comparison.metricVersion}</span>
        <span>{distance.binderAlignments.toLocaleString()} binder alignments</span>
        <span>{distance.exactForStoredOrbits ? "Exact stored-orbit search" : "Bounded orbit search"}</span>
      </div>
    </section>
  );
}
