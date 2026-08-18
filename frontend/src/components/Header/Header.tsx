import { useEffect, useRef, useState } from "react";
import {
  Ban,
  ChevronDown,
  ClipboardCopy,
  Download,
  FileJson,
  Focus,
  Play,
  RotateCcw,
  Square,
} from "lucide-react";
import type { EGraphAnalysis } from "../../api/types";
import { useMockApi } from "../../api/client";
import { IconButton } from "../Common/IconButton";

export type BackendState = "checking" | "connected" | "unreachable" | "analyzing";

interface HeaderProps {
  backendState: BackendState;
  canAnalyze: boolean;
  analysis?: EGraphAnalysis;
  onAnalyze: () => void;
  onCancel: () => void;
  onResetView: () => void;
  onExportJson: () => void;
  onExportSvg: () => void;
  onCopyCanonical: () => Promise<void>;
}

function BackendStatus({ state }: { state: BackendState }) {
  const label = state === "checking"
    ? "Checking"
    : state === "connected"
      ? (useMockApi ? "Mock API" : "Connected")
      : state === "analyzing" ? "Analyzing" : "Unreachable";
  return (
    <div className={`backend-status backend-${state}`} title="Analysis backend status">
      <span className="status-dot" aria-hidden="true" />
      <span>{label}</span>
    </div>
  );
}

export function Header({
  backendState,
  canAnalyze,
  analysis,
  onAnalyze,
  onCancel,
  onResetView,
  onExportJson,
  onExportSvg,
  onCopyCanonical,
}: HeaderProps) {
  const [exportOpen, setExportOpen] = useState(false);
  const [copied, setCopied] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const close = (event: MouseEvent) => {
      if (!menuRef.current?.contains(event.target as Node)) setExportOpen(false);
    };
    document.addEventListener("mousedown", close);
    return () => document.removeEventListener("mousedown", close);
  }, []);

  return (
    <header className="app-header">
      <div className="brand-block">
        <div className="brand-mark" aria-hidden="true"><Focus size={18} /></div>
        <div>
          <h1>Alloy E-Graph Explorer</h1>
          <span>Typed slotted representation</span>
        </div>
      </div>
      <div className="header-actions">
        <BackendStatus state={backendState} />
        {backendState === "analyzing" ? (
          <button type="button" className="command-button danger-command" onClick={onCancel}>
            <Square size={15} /> Cancel
          </button>
        ) : (
          <button type="button" className="command-button primary-command" disabled={!canAnalyze} onClick={onAnalyze}>
            <Play size={15} fill="currentColor" /> Analyze
          </button>
        )}
        <IconButton label="Reset graph view" onClick={onResetView} disabled={!analysis}>
          <RotateCcw size={17} />
        </IconButton>
        <div className="export-menu" ref={menuRef}>
          <button
            type="button"
            className="command-button quiet-command"
            disabled={!analysis}
            onClick={() => setExportOpen((open) => !open)}
            aria-expanded={exportOpen}
          >
            <Download size={15} /> Export <ChevronDown size={14} />
          </button>
          {exportOpen && analysis && (
            <div className="menu-popover">
              <button type="button" onClick={() => { onExportJson(); setExportOpen(false); }}>
                <FileJson size={16} /> Visualization IR JSON
              </button>
              <button type="button" onClick={() => { onExportSvg(); setExportOpen(false); }}>
                <Download size={16} /> Visible graph SVG
              </button>
              <button
                type="button"
                disabled={!analysis.predicate.canonicalText}
                onClick={async () => {
                  await onCopyCanonical();
                  setCopied(true);
                  window.setTimeout(() => setCopied(false), 1400);
                }}
              >
                <ClipboardCopy size={16} /> {copied ? "Copied" : "Canonical representation"}
              </button>
            </div>
          )}
        </div>
        {!canAnalyze && backendState !== "analyzing" && (
          <span className="sr-only"><Ban size={14} /> Select a predicate before analysis.</span>
        )}
      </div>
    </header>
  );
}
