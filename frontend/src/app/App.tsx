import { lazy, Suspense, useEffect, useMemo, useRef, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { AlertOctagon, X } from "lucide-react";
import {
  AnalysisApiError,
  analyzeCallable,
  healthCheck,
  inspectModel,
} from "../api/client";
import type {
  CallableReference,
  EGraphAnalysis,
  NormalizationStage,
  SourceMapping,
} from "../api/types";
import { GraphEmptyState } from "../components/Graph/GraphEmptyState";
import { Header, type BackendState } from "../components/Header/Header";
import { Inspector } from "../components/Inspector/Inspector";
import { InspectorEmptyState } from "../components/Inspector/InspectorEmptyState";
import { PredicatePipelinePanel } from "../components/PredicateSelector/PredicatePipelinePanel";
import { MobileTabs } from "../components/Responsive/MobileTabs";
import { TracePanel } from "../components/Trace/TracePanel";
import { examples, requestedExample, type ExampleName } from "../examples";
import { useDebouncedValue } from "../hooks/useDebouncedValue";
import { useUiStore } from "../state/uiStore";
import { indexGraph } from "../utils/entityIndex";
import {
  copyCanonicalRepresentation,
  exportAnalysisJson,
  exportVisibleGraphSvg,
} from "../utils/exporters";

const SourceEditor = lazy(async () => ({
  default: (await import("../components/SourceEditor/SourceEditor")).SourceEditor,
}));
const GraphCanvas = lazy(async () => ({
  default: (await import("../components/Graph/GraphCanvas")).GraphCanvas,
}));

interface AnalysisOrigin {
  model: string;
  callable: CallableReference;
}

function uniqueMappings(mappings: SourceMapping[]): SourceMapping[] {
  return [...new Map(mappings.map((mapping) => [mapping.id, mapping])).values()];
}

function describeError(error: unknown): { title: string; message: string; details?: unknown } {
  if (error instanceof AnalysisApiError) {
    const titles: Record<string, string> = {
      configuration: "Backend not configured",
      network: "Backend unavailable",
      backend: "Backend request failed",
      parse: "Model parse failed",
      type: "Model type check failed",
      "callable-not-found": "Callable not found",
      "predicate-not-found": "Predicate not found",
      analysis: "Analysis failed",
      schema: "Visualization schema mismatch",
      "unsupported-version": "Unsupported response version",
      timeout: "Analysis timed out",
      cancelled: "Analysis cancelled",
    };
    return { title: titles[error.kind] ?? "Analysis failed", message: error.message, details: error.details };
  }
  return { title: "Analysis failed", message: error instanceof Error ? error.message : String(error) };
}

export function App() {
  const initialExample = requestedExample();
  const [exampleName, setExampleName] = useState<ExampleName>(initialExample);
  const [model, setModel] = useState(examples[initialExample]);
  const [analysis, setAnalysis] = useState<EGraphAnalysis>();
  const [analysisOrigin, setAnalysisOrigin] = useState<AnalysisOrigin>();
  const [analysisError, setAnalysisError] = useState<unknown>();
  const abortRef = useRef<AbortController>();
  const queryClient = useQueryClient();
  const debouncedModel = useDebouncedValue(model, 450);

  const selectedPredicate = useUiStore((state) => state.selectedPredicate);
  const selectedEClassId = useUiStore((state) => state.selectedEClassId);
  const selectedENodeId = useUiStore((state) => state.selectedENodeId);
  const currentStageId = useUiStore((state) => state.currentStageId);
  const graphFilters = useUiStore((state) => state.graphFilters);
  const expandedClasses = useUiStore((state) => state.expandedClasses);
  const ambiguousMappingIds = useUiStore((state) => state.ambiguousMappingIds);
  const selectedSlotId = useUiStore((state) => state.selectedSlotId);
  const hoveredSlotId = useUiStore((state) => state.hoveredSlotId);
  const mobilePanel = useUiStore((state) => state.mobilePanel);
  const setSelectedPredicate = useUiStore((state) => state.setSelectedPredicate);
  const selectEClass = useUiStore((state) => state.selectEClass);
  const selectENode = useUiStore((state) => state.selectENode);
  const setCurrentStage = useUiStore((state) => state.setCurrentStage);
  const setAmbiguousMappings = useUiStore((state) => state.setAmbiguousMappings);
  const setHighlightedEntities = useUiStore((state) => state.setHighlightedEntities);
  const resetForAnalysis = useUiStore((state) => state.resetForAnalysis);
  const requestFocus = useUiStore((state) => state.requestFocus);
  const requestFitView = useUiStore((state) => state.requestFitView);

  const health = useQuery({
    queryKey: ["analysis-backend-health"],
    queryFn: ({ signal }) => healthCheck(signal),
    retry: false,
    staleTime: 60_000,
    refetchOnWindowFocus: false,
  });

  const inspection = useQuery({
    queryKey: ["model-inspection", debouncedModel],
    queryFn: ({ signal }) => inspectModel(debouncedModel, signal),
    enabled: debouncedModel.trim().length > 0,
    retry: false,
    staleTime: Number.POSITIVE_INFINITY,
    refetchOnWindowFocus: false,
  });

  useEffect(() => {
    const callables = inspection.data?.callables ?? [];
    if (callables.length === 1 && !callables.some((callable) => callable.name === selectedPredicate)) {
      setSelectedPredicate(callables[0]?.name);
    } else if (selectedPredicate && !callables.some((callable) => callable.name === selectedPredicate)) {
      setSelectedPredicate(undefined);
    }
  }, [inspection.data, selectedPredicate, setSelectedPredicate]);

  const analysisMutation = useMutation({
    mutationFn: async ({ source, callable }: { source: string; callable: CallableReference }) => {
      abortRef.current = new AbortController();
      return analyzeCallable(source, callable, undefined, abortRef.current.signal);
    },
    onSuccess: (result, variables) => {
      setAnalysis(result);
      setAnalysisOrigin({ model: variables.source, callable: variables.callable });
      setAnalysisError(undefined);
      resetForAnalysis(result.graph.rootEClassId, result.stages[0]?.id);
    },
    onError: (error) => {
      if (!(error instanceof AnalysisApiError && error.kind === "cancelled")) {
        setAnalysisError(error);
        void queryClient.invalidateQueries({ queryKey: ["analysis-backend-health"] });
      }
    },
    onSettled: () => {
      abortRef.current = undefined;
    },
  });

  const runAnalysis = () => {
    if (!selectedPredicate || analysisMutation.isPending) return;
    const callable = inspection.data?.callables.find((candidate) => candidate.name === selectedPredicate);
    if (!callable) return;
    setAnalysisError(undefined);
    analysisMutation.mutate({
      source: model,
      callable: { name: callable.name, kind: callable.kind },
    });
  };

  const allMappings = useMemo(() => {
    if (!analysis) return [];
    const stageMappings = analysis.stages
      .filter((stage) => !currentStageId || stage.id === currentStageId)
      .flatMap((stage) => stage.sourceMappings ?? []);
    return uniqueMappings([...(analysis.sourceMappings ?? []), ...stageMappings]);
  }, [analysis, currentStageId]);

  const analysisIndex = useMemo(
    () => analysis ? indexGraph(analysis.graph) : undefined,
    [analysis],
  );

  const slotEntityIndex = useMemo(() => {
    const index = new Map<string, Set<string>>();
    const add = (slotId: string, entityId: string) => {
      const entities = index.get(slotId) ?? new Set<string>();
      entities.add(entityId);
      index.set(slotId, entities);
    };
    if (!analysis) return index;
    for (const eclass of analysis.graph.eclasses) {
      for (const slot of [...(eclass.support ?? []), ...(eclass.effectiveSupport ?? [])]) {
        add(slot.id, eclass.id);
      }
      for (const enode of eclass.nodes) {
        for (const slot of enode.slots ?? []) {
          add(slot.slotId, enode.id);
          add(slot.slotId, eclass.id);
        }
      }
    }
    return index;
  }, [analysis]);

  const slotEntityIds = useMemo(() => {
    const ids = new Set<string>();
    for (const slotId of [selectedSlotId, hoveredSlotId]) {
      if (!slotId) continue;
      for (const entityId of slotEntityIndex.get(slotId) ?? []) ids.add(entityId);
    }
    return [...ids];
  }, [hoveredSlotId, selectedSlotId, slotEntityIndex]);

  const activateMapping = (mapping: SourceMapping) => {
    const ids = [...(mapping.eclassIds ?? []), ...(mapping.enodeIds ?? [])];
    const enode = mapping.enodeIds?.[0];
    const eclass = mapping.eclassIds?.[0] ?? (enode ? analysisIndex?.enodes.get(enode)?.eclass.id : undefined);
    if (enode) selectENode(enode, eclass);
    else if (eclass) selectEClass(eclass);
    setHighlightedEntities(ids);
    if (mapping.stageId) setCurrentStage(mapping.stageId);
    requestFocus();
  };

  const mappingsSelected = (mappings: SourceMapping[]) => {
    if (mappings.length === 0) {
      setAmbiguousMappings([]);
      return;
    }
    activateMapping(mappings[0]);
    setAmbiguousMappings(mappings.map((mapping) => mapping.id));
    setHighlightedEntities(mappings.flatMap((mapping) => [
      ...(mapping.eclassIds ?? []),
      ...(mapping.enodeIds ?? []),
    ]));
  };

  const selectStage = (stage: NormalizationStage) => {
    setCurrentStage(stage.id);
    if (stage.rootEClassId) {
      selectEClass(stage.rootEClassId);
      requestFocus();
    }
  };

  const selectExample = (name: ExampleName) => {
    setExampleName(name);
    setModel(examples[name]);
    setSelectedPredicate(undefined);
    setAnalysisError(undefined);
    const nextUrl = new URL(window.location.href);
    nextUrl.searchParams.set("example", name);
    window.history.replaceState({}, "", nextUrl);
  };

  const backendState: BackendState = analysisMutation.isPending
    ? "analyzing"
    : health.isPending ? "checking" : health.isSuccess ? "connected" : "unreachable";
  const parseHasErrors = inspection.data?.parseDiagnostics.some((diagnostic) => diagnostic.severity === "error") ?? false;
  const errorDescription = analysisError ? describeError(analysisError) : undefined;
  const staleAnalysis = analysis && analysisOrigin
    && (analysisOrigin.model !== model || analysisOrigin.callable.name !== selectedPredicate);

  return (
    <div className="app-root">
      <Header
        backendState={backendState}
        canAnalyze={Boolean(selectedPredicate) && !parseHasErrors && !analysisMutation.isPending}
        analysis={analysis}
        onAnalyze={runAnalysis}
        onCancel={() => abortRef.current?.abort()}
        onResetView={requestFitView}
        onExportJson={() => analysis && exportAnalysisJson(analysis)}
        onExportSvg={() => analysis && exportVisibleGraphSvg(analysis, graphFilters, expandedClasses)}
        onCopyCanonical={() => analysis ? copyCanonicalRepresentation(analysis) : Promise.resolve()}
      />
      <MobileTabs />
      {errorDescription && (
        <div className="analysis-error-banner" role="alert">
          <AlertOctagon size={18} />
          <div>
            <strong>{errorDescription.title}</strong>
            <span>{selectedPredicate && <><code>{selectedPredicate}</code>{" "}</>}{errorDescription.message}</span>
            {errorDescription.details !== undefined && <details><summary>Validation details</summary><pre>{JSON.stringify(errorDescription.details, null, 2)}</pre></details>}
          </div>
          <button type="button" aria-label="Dismiss error" onClick={() => setAnalysisError(undefined)}><X size={16} /></button>
        </div>
      )}
      {staleAnalysis && <div className="stale-result-banner">Showing the previous successful analysis</div>}
      <main className="workspace" data-mobile-panel={mobilePanel}>
        <Suspense fallback={<section className="workspace-panel source-panel"><div className="empty-panel">Loading editor</div></section>}>
          <SourceEditor
            model={model}
            diagnostics={inspection.data?.parseDiagnostics ?? []}
            mappings={allMappings}
            selectedEClassId={selectedEClassId}
            selectedENodeId={selectedENodeId}
            slotEntityIds={slotEntityIds}
            ambiguousMappingIds={ambiguousMappingIds}
            inspecting={inspection.isFetching}
            onChange={setModel}
            onAnalyze={runAnalysis}
            onMappingsSelected={mappingsSelected}
            onMappingSelected={activateMapping}
          />
        </Suspense>
        {analysis ? (
          <Suspense fallback={<GraphEmptyState />}><GraphCanvas analysis={analysis} /></Suspense>
        ) : <GraphEmptyState />}
        <PredicatePipelinePanel
          inspection={inspection.data}
          inspectionError={inspection.error ? describeError(inspection.error).message : undefined}
          analysis={analysis}
          selectedPredicate={selectedPredicate}
          currentStageId={currentStageId}
          exampleName={exampleName}
          inspecting={inspection.isFetching}
          onSelectPredicate={setSelectedPredicate}
          onSelectStage={selectStage}
          onSelectExample={selectExample}
        />
        <TracePanel trace={analysis?.trace} graph={analysis?.graph} />
        {analysis ? <Inspector analysis={analysis} /> : <InspectorEmptyState />}
      </main>
    </div>
  );
}
