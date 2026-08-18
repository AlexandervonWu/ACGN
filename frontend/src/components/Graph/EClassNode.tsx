import { ChevronDown, ChevronRight, Star } from "lucide-react";
import {
  Handle,
  Position,
  type Node,
  type NodeProps,
} from "@xyflow/react";
import type { EClass, ENode } from "../../api/types";
import { formatType } from "../../utils/formatters";
import { SlotChip } from "../Common/SlotChip";

export interface EClassNodeData extends Record<string, unknown> {
  eclass: EClass;
  collapsed: boolean;
  root: boolean;
  highlighted: boolean;
  selectedEClassId?: string;
  selectedENodeId?: string;
  highlightedEntityIds: string[];
  onSelectEClass: (id: string) => void;
  onSelectENode: (id: string, eclassId: string, extend: boolean) => void;
  onToggle: (id: string) => void;
  onSelectChild: (id: string) => void;
}

export type EClassFlowNode = Node<EClassNodeData, "eclass">;

function NodeSummary({
  node,
  eclass,
  canonical,
  selected,
  highlighted,
  onSelect,
  onSelectChild,
}: {
  node: ENode;
  eclass: EClass;
  canonical: boolean;
  selected: boolean;
  highlighted: boolean;
  onSelect: (extend: boolean) => void;
  onSelectChild: (id: string) => void;
}) {
  const aci = node.container?.kind === "ACI";
  return (
    <div
      className={`enode-row ${selected ? "is-selected" : ""} ${highlighted ? "is-highlighted" : ""} ${aci ? "aci-enode" : ""}`}
      role="button"
      tabIndex={0}
      onClick={(event) => {
        event.stopPropagation();
        onSelect(event.shiftKey);
      }}
      onKeyDown={(event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          onSelect(event.shiftKey);
        }
      }}
    >
      <div className="enode-heading">
        <span className="canonical-star" title={canonical ? "Canonical member" : undefined}>
          {canonical ? <Star size={12} fill="currentColor" /> : <span className="star-spacer" />}
        </span>
        <code>{node.displayName ?? node.kind}</code>
        <span className="enode-id">{node.id}</span>
      </div>
      {aci && (
        <div className="aci-container">
          <div className="aci-title">{node.container?.operator ?? node.kind} / ACI</div>
          <div className="aci-operands">
            {node.children.map((child, index) => (
              <button
                type="button"
                key={`${child.eclassId}-${child.role ?? index}`}
                onClick={(event) => {
                  event.stopPropagation();
                  onSelectChild(child.eclassId);
                }}
              >
                {child.eclassId}
              </button>
            ))}
          </div>
          <div className="aci-flags">
            {node.container?.orderInsensitive && <span>order-insensitive</span>}
            {node.container?.duplicateElimination && <span>duplicate-free</span>}
            {node.container?.flattened && <span>flattened</span>}
          </div>
        </div>
      )}
      {!aci && node.children.length > 0 && (
        <div className="enode-children">
          {node.children.map((child, index) => (
            <button
              type="button"
              key={`${child.eclassId}-${child.role ?? index}`}
              onClick={(event) => {
                event.stopPropagation();
                onSelectChild(child.eclassId);
              }}
            >
              {child.role && <span>{child.role}</span>}{child.eclassId}
            </button>
          ))}
        </div>
      )}
      {node.slots && node.slots.length > 0 && (
        <div className="slot-row">
          {node.slots.map((slot, index) => (
            <SlotChip key={`${slot.slotId}-${slot.role ?? index}`} id={slot.slotId} type={slot.type} />
          ))}
        </div>
      )}
    </div>
  );
}

export function EClassNode({ data }: NodeProps<EClassFlowNode>) {
  const { eclass } = data;
  const canonical = eclass.nodes.find((node) => node.id === eclass.canonicalNodeId)
    ?? eclass.nodes.find((node) => node.id === eclass.representativeNodeId)
    ?? eclass.nodes[0];
  return (
    <div
      className={`eclass-node ${data.root ? "is-root" : ""} ${data.selectedEClassId === eclass.id ? "is-selected" : ""} ${data.highlighted ? "is-highlighted" : ""}`}
      onClick={() => data.onSelectEClass(eclass.id)}
    >
      <Handle type="target" position={Position.Top} className="eclass-handle" />
      <div className="eclass-header">
        <div className="eclass-name">
          <strong>{eclass.id}</strong>
          {data.root && <span className="root-badge">root</span>}
        </div>
        <span className="type-label">{formatType(eclass.type)}</span>
      </div>
      <div className="eclass-support">
        <span>support</span>
        <div>
          {eclass.support?.length
            ? eclass.support.map((slot) => <SlotChip key={slot.id} id={slot.id} type={slot.type} label={slot.displayName} />)
            : <span className="empty-set">∅</span>}
        </div>
        {eclass.effectiveSupport && (
          <>
            <span>effective</span>
            <div>
              {eclass.effectiveSupport.length
                ? eclass.effectiveSupport.map((slot) => <SlotChip key={slot.id} id={slot.id} type={slot.type} label={slot.displayName} />)
                : <span className="empty-set">∅</span>}
            </div>
          </>
        )}
      </div>
      {data.collapsed ? (
        <button
          type="button"
          className="collapsed-enode"
          onClick={(event) => { event.stopPropagation(); data.onToggle(eclass.id); }}
        >
          <ChevronRight size={14} />
          <span>{eclass.nodes.length} node{eclass.nodes.length === 1 ? "" : "s"}</span>
          <code>{canonical?.displayName ?? canonical?.kind ?? "empty"}</code>
        </button>
      ) : (
        <div className="enode-list">
          <button
            type="button"
            className="collapse-control"
            onClick={(event) => { event.stopPropagation(); data.onToggle(eclass.id); }}
            title="Collapse e-class"
            aria-label={`Collapse ${eclass.id}`}
          >
            <ChevronDown size={14} />
          </button>
          {eclass.nodes.map((node) => (
            <NodeSummary
              key={node.id}
              node={node}
              eclass={eclass}
              canonical={node.id === eclass.canonicalNodeId || node.id === eclass.representativeNodeId}
              selected={data.selectedENodeId === node.id}
              highlighted={data.highlightedEntityIds.includes(node.id)}
              onSelect={(extend) => data.onSelectENode(node.id, eclass.id, extend)}
              onSelectChild={data.onSelectChild}
            />
          ))}
        </div>
      )}
      <Handle type="source" position={Position.Bottom} className="eclass-handle" />
    </div>
  );
}

