import { Check, Circle } from "lucide-react";
import type { NormalizationStage } from "../../api/types";

interface PipelineProps {
  stages: NormalizationStage[];
  currentStageId?: string;
  onSelect: (stage: NormalizationStage) => void;
}

export function Pipeline({ stages, currentStageId, onSelect }: PipelineProps) {
  if (stages.length === 0) {
    return <div className="unavailable-value">Not provided by backend</div>;
  }
  const currentIndex = stages.findIndex((stage) => stage.id === currentStageId);
  return (
    <div className="pipeline-view">
      <div className="pipeline-track" role="tablist" aria-label="Normalization stages">
        {stages.map((stage, index) => {
          const active = stage.id === currentStageId;
          const complete = currentIndex >= 0 && index < currentIndex;
          return (
            <button
              type="button"
              role="tab"
              aria-selected={active}
              className={`pipeline-stage ${active ? "is-active" : ""} ${complete ? "is-complete" : ""}`}
              key={stage.id}
              onClick={() => onSelect(stage)}
              title={stage.description ?? stage.name}
            >
              <span className="stage-marker">{complete ? <Check size={11} /> : <Circle size={9} fill={active ? "currentColor" : "none"} />}</span>
              <span>{stage.name}</span>
            </button>
          );
        })}
      </div>
      {stages.find((stage) => stage.id === currentStageId)?.text && (
        <pre className="stage-text">{stages.find((stage) => stage.id === currentStageId)?.text}</pre>
      )}
    </div>
  );
}

