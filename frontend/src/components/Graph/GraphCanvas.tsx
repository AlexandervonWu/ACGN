import { useEffect, useMemo } from "react";
import {
  Background,
  BackgroundVariant,
  Controls,
  MarkerType,
  MiniMap,
  ReactFlow,
  ReactFlowProvider,
  useNodesState,
  useReactFlow,
  type Edge,
} from "@xyflow/react";
import "@xyflow/react/dist/style.css";
import type { EGraphAnalysis } from "../../api/types";
import {
  buildVisibleGraph,
  shouldCollapseEClass,
} from "../../graph/buildVisibleGraph";
import { layoutEClasses } from "../../graph/layout";
import { useUiStore } from "../../state/uiStore";
import { PanelHeader } from "../Common/PanelHeader";
import { StatisticsStrip } from "../Statistics/StatisticsStrip";
import { EClassNode, type EClassFlowNode } from "./EClassNode";
import { GraphToolbar, type GraphSearchResult } from "./GraphToolbar";

const nodeTypes = { eclass: EClassNode };

function CanvasInner({ analysis }: { analysis: EGraphAnalysis }) {
  const graphFilters = useUiStore((state) => state.graphFilters);
  const expandedClasses = useUiStore((state) => state.expandedClasses);
  const selectedEClassId = useUiStore((state) => state.selectedEClassId);
  const selectedENodeId = useUiStore((state) => state.selectedENodeId);
  const highlightedEntityIds = useUiStore((state) => state.highlightedEntityIds);
  const selectedSlotId = useUiStore((state) => state.selectedSlotId);
  const graphSearch = useUiStore((state) => state.graphSearch);
  const fitViewRequest = useUiStore((state) => state.fitViewRequest);
  const focusRequest = useUiStore((state) => state.focusRequest);
  const selectEClass = useUiStore((state) => state.selectEClass);
  const selectENode = useUiStore((state) => state.selectENode);
  const toggleExpandedClass = useUiStore((state) => state.toggleExpandedClass);
  const setGraphFilter = useUiStore((state) => state.setGraphFilter);
  const setGraphSearch = useUiStore((state) => state.setGraphSearch);
  const requestFocus = useUiStore((state) => state.requestFocus);
  const clearSelections = useUiStore((state) => state.clearSelections);
  const setSelectedSlot = useUiStore((state) => state.setSelectedSlot);
  const { fitView, getNode, setCenter } = useReactFlow<EClassFlowNode>();

  const visible = useMemo(
    () => buildVisibleGraph(analysis.graph, graphFilters, expandedClasses),
    [analysis.graph, graphFilters, expandedClasses],
  );

  const displayClasses = useMemo(() => {
    if (!selectedEClassId || visible.eclasses.some((eclass) => eclass.id === selectedEClassId)) {
      return visible.eclasses;
    }
    const selected = analysis.graph.eclasses.find((eclass) => eclass.id === selectedEClassId);
    return selected ? [...visible.eclasses, selected] : visible.eclasses;
  }, [analysis.graph.eclasses, selectedEClassId, visible.eclasses]);

  const positioned = useMemo(
    () => layoutEClasses(displayClasses, visible.depthByEClass),
    [displayClasses, visible.depthByEClass],
  );

  const nextNodes = useMemo<EClassFlowNode[]>(() => positioned.map(({ eclass, position }) => ({
    id: eclass.id,
    type: "eclass",
    position,
    selected: selectedEClassId === eclass.id,
    data: {
      eclass,
      collapsed: shouldCollapseEClass(eclass, graphFilters, expandedClasses),
      root: eclass.id === analysis.graph.rootEClassId,
      highlighted: highlightedEntityIds.includes(eclass.id),
      selectedEClassId,
      selectedENodeId,
      highlightedEntityIds,
      onSelectEClass: (id) => {
        selectEClass(id);
      },
      onSelectENode: selectENode,
      onToggle: toggleExpandedClass,
      onSelectChild: (id) => {
        selectEClass(id);
        requestFocus();
      },
    },
  })), [
    analysis.graph.rootEClassId,
    expandedClasses,
    graphFilters,
    highlightedEntityIds,
    positioned,
    requestFocus,
    selectEClass,
    selectedEClassId,
    selectedENodeId,
    selectENode,
    toggleExpandedClass,
  ]);

  const [nodes, setNodes, onNodesChange] = useNodesState<EClassFlowNode>(nextNodes);

  useEffect(() => {
    setNodes((current) => nextNodes.map((node) => {
      const prior = current.find((candidate) => candidate.id === node.id);
      return prior ? { ...node, position: prior.position } : node;
    }));
  }, [nextNodes, setNodes]);

  const edges = useMemo<Edge[]>(() => visible.edges.map((edge, index) => ({
    id: edge.id ?? `${edge.sourceEClassId}-${edge.targetEClassId}-${index}`,
    source: edge.sourceEClassId,
    target: edge.targetEClassId,
    label: edge.role,
    type: "smoothstep",
    markerEnd: { type: MarkerType.ArrowClosed, width: 14, height: 14 },
    animated: false,
    className: highlightedEntityIds.includes(edge.sourceEClassId)
      || highlightedEntityIds.includes(edge.targetEClassId) ? "is-highlighted" : "",
  })), [highlightedEntityIds, visible.edges]);

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => {
      void fitView({ padding: 0.2, duration: 320, maxZoom: 1.05 });
    });
    return () => window.cancelAnimationFrame(frame);
  }, [fitView, fitViewRequest]);

  useEffect(() => {
    if (!selectedEClassId || focusRequest === 0) return;
    const frame = window.requestAnimationFrame(() => {
      const node = getNode(selectedEClassId);
      if (!node) return;
      const width = node.measured?.width ?? 300;
      const height = node.measured?.height ?? 150;
      void setCenter(node.position.x + width / 2, node.position.y + height / 2, {
        zoom: 1,
        duration: 300,
      });
    });
    return () => window.cancelAnimationFrame(frame);
  }, [focusRequest, getNode, selectedEClassId, setCenter]);

  const selectSearchResult = (result: GraphSearchResult) => {
    if (result.enodeId) selectENode(result.enodeId, result.eclassId);
    else selectEClass(result.eclassId);
    setGraphSearch("");
    requestFocus();
  };

  return (
    <>
      <GraphToolbar
        graph={analysis.graph}
        filters={graphFilters}
        graphSearch={graphSearch}
        selectedEClassId={selectedEClassId}
        selectedSlotId={selectedSlotId}
        onSearchChange={setGraphSearch}
        onSelectResult={selectSearchResult}
        onFilterChange={setGraphFilter}
        onCenterSelected={requestFocus}
        onClearSlot={() => setSelectedSlot(undefined)}
      />
      {visible.restricted && (
        <div className="graph-restriction-notice" role="status">
          <strong>{analysis.graph.eclasses.length.toLocaleString()} e-classes</strong>
          <span>Root neighborhood shown · {visible.omittedCount.toLocaleString()} omitted</span>
        </div>
      )}
      <ReactFlow<EClassFlowNode, Edge>
        nodes={nodes}
        edges={edges}
        nodeTypes={nodeTypes}
        onNodesChange={onNodesChange}
        onPaneClick={clearSelections}
        minZoom={0.12}
        maxZoom={1.8}
        fitView
        fitViewOptions={{ padding: 0.2, maxZoom: 1.05 }}
        defaultEdgeOptions={{ style: { stroke: "#78838e", strokeWidth: 1.4 } }}
        proOptions={{ hideAttribution: true }}
      >
        <Background variant={BackgroundVariant.Dots} gap={18} size={1} color="#cfd6dc" />
        <Controls position="bottom-left" showInteractive={false} />
        {displayClasses.length > 8 && (
          <MiniMap
            position="bottom-right"
            pannable
            zoomable
            nodeColor={(node) => node.id === analysis.graph.rootEClassId ? "#138a84" : "#aeb9c2"}
            maskColor="rgba(244, 246, 248, 0.76)"
          />
        )}
      </ReactFlow>
      <div className="graph-legend" aria-label="Graph legend">
        <span><i className="legend-eclass" /> e-class</span>
        <span><i className="legend-canonical">★</i> canonical</span>
        <span><i className="legend-aci" /> ACI</span>
      </div>
    </>
  );
}

export function GraphCanvas({ analysis }: { analysis: EGraphAnalysis }) {
  return (
    <section className="workspace-panel graph-panel" aria-label="E-graph">
      <PanelHeader title="Graph" count={analysis.graph.eclasses.length} actions={<StatisticsStrip statistics={analysis.statistics} />} />
      <div className="graph-shell">
        <ReactFlowProvider>
          <CanvasInner analysis={analysis} />
        </ReactFlowProvider>
      </div>
    </section>
  );
}
