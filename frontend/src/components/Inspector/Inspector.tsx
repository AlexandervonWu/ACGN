import { useMemo, useState } from "react";
import {
  AlertTriangle,
  CheckCircle2,
  ChevronRight,
  CircleHelp,
  FileCode2,
  GitCompareArrows,
  Link2,
  XCircle,
} from "lucide-react";
import type {
  Certificate,
  EClass,
  EGraphAnalysis,
  ENode,
  InvariantStatus,
  SlotRef,
} from "../../api/types";
import { useUiStore } from "../../state/uiStore";
import { indexGraph, type EntityIndex } from "../../utils/entityIndex";
import { formatProvenance, formatType } from "../../utils/formatters";
import { CertificateView } from "../Certificates/CertificateView";
import { PanelHeader } from "../Common/PanelHeader";
import { SlotChip } from "../Common/SlotChip";

function DataRow({ label, children }: { label: string; children: React.ReactNode }) {
  return <div className="inspector-row"><dt>{label}</dt><dd>{children}</dd></div>;
}

function SlotList({ slots }: { slots?: SlotRef[] }) {
  if (!slots) return <span className="unavailable-value">Not provided by backend</span>;
  if (slots.length === 0) return <span className="empty-set">∅</span>;
  return <div className="slot-list">{slots.map((slot) => <span key={slot.id}><SlotChip id={slot.id} type={slot.type} label={slot.displayName} />{slot.type && <small>{slot.type}</small>}</span>)}</div>;
}

function InvariantList({ invariants, index }: { invariants?: InvariantStatus[]; index: EntityIndex }) {
  const setHighlightedEntities = useUiStore((state) => state.setHighlightedEntities);
  const selectEClass = useUiStore((state) => state.selectEClass);
  const selectENode = useUiStore((state) => state.selectENode);
  const requestFocus = useUiStore((state) => state.requestFocus);
  if (!invariants) return <span className="unavailable-value">Not provided by backend</span>;
  return (
    <div className="invariant-list">
      {invariants.map((invariant) => {
        const Icon = invariant.status === "pass" ? CheckCircle2 : invariant.status === "fail" ? XCircle : CircleHelp;
        return (
          <button
            type="button"
            key={invariant.id}
            className={`invariant invariant-${invariant.status}`}
            onClick={() => {
              const ids = invariant.relatedEntityIds ?? [];
              const enode = ids.map((id) => index.enodes.get(id)).find(Boolean);
              const eclassId = ids.find((id) => index.eclasses.has(id));
              if (enode) selectENode(enode.enode.id, enode.eclass.id);
              else if (eclassId) selectEClass(eclassId);
              setHighlightedEntities(ids);
              if (enode || eclassId) requestFocus();
            }}
          >
            <Icon size={15} />
            <span><strong>{invariant.name}</strong>{invariant.message && <small>{invariant.message}</small>}</span>
          </button>
        );
      })}
    </div>
  );
}

function Navigation({ analysis, eclass, enode }: { analysis: EGraphAnalysis; eclass: EClass; enode?: ENode }) {
  const index = useMemo(() => indexGraph(analysis.graph), [analysis.graph]);
  const selectEClass = useUiStore((state) => state.selectEClass);
  const requestFocus = useUiStore((state) => state.requestFocus);
  const parents = [...(index.parents.get(eclass.id) ?? [])];
  const children = [...new Set((enode ? enode.children : eclass.nodes.flatMap((node) => node.children)).map((child) => child.eclassId))];
  const navigate = (id: string) => { selectEClass(id); requestFocus(); };
  return (
    <div className="navigation-groups">
      <div><span>Parents</span>{parents.length ? parents.map((id) => <button type="button" key={id} onClick={() => navigate(id)}>{id}<ChevronRight size={12} /></button>) : <small>None</small>}</div>
      <div><span>Children</span>{children.length ? children.map((id) => <button type="button" key={id} onClick={() => navigate(id)}>{id}<ChevronRight size={12} /></button>) : <small>None</small>}</div>
    </div>
  );
}

function certificateSelection(
  analysis: EGraphAnalysis,
  eclass: EClass,
  selectedIds: string[],
): Certificate[] {
  if (selectedIds.length !== 2) return [];
  const selectedNodes = selectedIds.map((id) => eclass.nodes.find((node) => node.id === id));
  if (selectedNodes.some((node) => !node)) return [];
  const certificateIds = new Set(selectedNodes.flatMap((node) => node?.certificateIds ?? []));
  return (analysis.certificates ?? []).filter((certificate) => certificateIds.has(certificate.id));
}

export function Inspector({ analysis }: { analysis: EGraphAnalysis }) {
  const selectedEClassId = useUiStore((state) => state.selectedEClassId);
  const selectedENodeId = useUiStore((state) => state.selectedENodeId);
  const equivalenceENodeIds = useUiStore((state) => state.equivalenceENodeIds);
  const [activeCertificateId, setActiveCertificateId] = useState<string>();
  const index = useMemo(() => indexGraph(analysis.graph), [analysis.graph]);
  const nodeEntry = selectedENodeId ? index.enodes.get(selectedENodeId) : undefined;
  const eclass = nodeEntry?.eclass
    ?? index.eclasses.get(selectedEClassId ?? analysis.graph.rootEClassId)
    ?? analysis.graph.eclasses[0];
  const enode = nodeEntry?.enode;
  if (!eclass) {
    return <section className="workspace-panel inspector-panel"><PanelHeader title="Inspector" /><div className="empty-panel">No e-class data</div></section>;
  }
  const entity = enode ?? eclass;
  const directCertificateIds = enode?.certificateIds ?? [];
  const directCertificates = (analysis.certificates ?? []).filter((certificate) => directCertificateIds.includes(certificate.id));
  const equivalenceCertificates = certificateSelection(analysis, eclass, equivalenceENodeIds);
  const activeCertificate = (analysis.certificates ?? []).find((certificate) => certificate.id === activeCertificateId);

  return (
    <section className="workspace-panel inspector-panel" aria-label="Inspector">
      <PanelHeader title="Inspector" />
      <div className="inspector-scroll">
        <div className="inspector-entity-title">
          <span>{enode ? "ENode" : "EClass"}</span>
          <strong>{entity.id}</strong>
        </div>
        <dl className="inspector-data">
          {enode && <DataRow label="Kind"><code>{enode.kind}</code></DataRow>}
          <DataRow label="Type"><span className="type-value">{formatType(enode?.type ?? eclass.type)}</span></DataRow>
          {!enode && <DataRow label="Support"><SlotList slots={eclass.support} /></DataRow>}
          {!enode && <DataRow label="Effective support"><SlotList slots={eclass.effectiveSupport} /></DataRow>}
          {!enode && <DataRow label="Nodes">{eclass.nodes.length.toLocaleString()}</DataRow>}
          {!enode && <DataRow label="Canonical node"><code>{eclass.canonicalNodeId ?? "Not provided by backend"}</code></DataRow>}
          {enode && <DataRow label="Children">{enode.children.length ? <div className="child-list">{enode.children.map((child, index) => <code key={`${child.eclassId}-${index}`}>{child.role ? `${child.role}: ` : ""}{child.eclassId}</code>)}</div> : "None"}</DataRow>}
          {enode && <DataRow label="Slots">{enode.slots?.length ? <div className="slot-list">{enode.slots.map((slot, index) => <span key={`${slot.slotId}-${index}`}><SlotChip id={slot.slotId} type={slot.type} /><small>{slot.role ?? slot.type}</small></span>)}</div> : <span className="unavailable-value">Not provided by backend</span>}</DataRow>}
          {enode?.container && <DataRow label="Container"><div className="container-details"><strong>{enode.container.kind}</strong>{enode.container.flattened && <span>flattened</span>}{enode.container.orderInsensitive && <span>order-insensitive</span>}{enode.container.duplicateElimination && <span>duplicate-free</span>}</div></DataRow>}
        </dl>

        <div className="inspector-section"><h3>Navigation</h3><Navigation analysis={analysis} eclass={eclass} enode={enode} /></div>

        {(enode?.provenance ?? eclass.provenance) && (
          <div className="inspector-section">
            <h3>Provenance</h3>
            <div className="provenance-list">{(enode?.provenance ?? eclass.provenance ?? []).map((item, index) => <span key={typeof item === "string" ? item : item.id ?? index}><Link2 size={12} />{formatProvenance(item)}</span>)}</div>
          </div>
        )}

        <div className="inspector-section"><h3>Invariant checks</h3><InvariantList invariants={eclass.invariantStatus} index={index} /></div>

        {enode && (
          <div className="inspector-section">
            <h3>Certificates</h3>
            {directCertificates.length ? (
              <div className="certificate-links">{directCertificates.map((certificate) => <button type="button" key={certificate.id} onClick={() => setActiveCertificateId(certificate.id)}><FileCode2 size={13} />{certificate.title ?? certificate.kind}</button>)}</div>
            ) : <span className="unavailable-value">Not provided by backend</span>}
          </div>
        )}

        <div className="inspector-section equivalence-section">
          <h3>Explain equivalence</h3>
          <button type="button" className="explain-button" disabled={equivalenceENodeIds.length !== 2} onClick={() => setActiveCertificateId(equivalenceCertificates[0]?.id)}>
            <GitCompareArrows size={14} />
            {equivalenceENodeIds.length === 2 ? `${equivalenceENodeIds[0]} ≡ ${equivalenceENodeIds[1]}` : "Select two members"}
          </button>
          {equivalenceENodeIds.length === 2 && equivalenceCertificates.length === 0 && (
            <div className="certificate-absent"><AlertTriangle size={14} />The backend reports one e-class, but included no derivation certificate.</div>
          )}
        </div>

        {activeCertificate && <CertificateView certificate={activeCertificate} />}

        <details className="raw-json">
          <summary>Raw JSON</summary>
          <pre>{JSON.stringify(entity, null, 2)}</pre>
        </details>
      </div>
    </section>
  );
}
