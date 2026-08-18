import { AlertCircle, AlertTriangle, Info } from "lucide-react";
import type { Diagnostic } from "../../api/types";

export function DiagnosticsList({ diagnostics }: { diagnostics: Diagnostic[] }) {
  if (diagnostics.length === 0) return null;
  return (
    <div className="diagnostics-list" aria-label="Diagnostics">
      {diagnostics.map((diagnostic, index) => {
        const Icon = diagnostic.severity === "error"
          ? AlertCircle
          : diagnostic.severity === "warning" ? AlertTriangle : Info;
        return (
          <div key={`${diagnostic.code ?? diagnostic.message}-${index}`} className={`diagnostic diagnostic-${diagnostic.severity}`}>
            <Icon size={14} />
            <span>{diagnostic.message}</span>
            {diagnostic.sourceRange && (
              <code>{diagnostic.sourceRange.start.line}:{diagnostic.sourceRange.start.column}</code>
            )}
          </div>
        );
      })}
    </div>
  );
}

