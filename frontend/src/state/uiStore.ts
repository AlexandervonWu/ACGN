import { create } from "zustand";

export type GraphDepth = 3 | 5 | 10 | "all";
export type MobilePanel = "source" | "graph" | "pipeline" | "trace" | "inspector";

export interface GraphFilters {
  reachableOnly: boolean;
  collapseSingleton: boolean;
  collapseLarge: boolean;
  showAllAlternatives: boolean;
  showCrossLinks: boolean;
  showHistorical: boolean;
  showRebuildDetails: boolean;
  depth: GraphDepth;
}

interface UiState {
  selectedPredicate?: string;
  selectedEClassId?: string;
  selectedENodeId?: string;
  equivalenceENodeIds: string[];
  selectedSlotId?: string;
  hoveredSlotId?: string;
  expandedClasses: Set<string>;
  graphFilters: GraphFilters;
  graphSearch: string;
  currentStageId?: string;
  traceKind: string;
  traceSearch: string;
  traceSelectedOnly: boolean;
  ambiguousMappingIds: string[];
  highlightedEntityIds: string[];
  fitViewRequest: number;
  focusRequest: number;
  mobilePanel: MobilePanel;
  setSelectedPredicate: (id?: string) => void;
  selectEClass: (id?: string) => void;
  selectENode: (id: string | undefined, eclassId?: string, extend?: boolean) => void;
  setSelectedSlot: (id?: string) => void;
  setHoveredSlot: (id?: string) => void;
  toggleExpandedClass: (id: string) => void;
  setGraphFilter: <K extends keyof GraphFilters>(key: K, value: GraphFilters[K]) => void;
  setGraphSearch: (value: string) => void;
  setCurrentStage: (id?: string) => void;
  setTraceKind: (kind: string) => void;
  setTraceSearch: (value: string) => void;
  setTraceSelectedOnly: (value: boolean) => void;
  setAmbiguousMappings: (ids: string[]) => void;
  setHighlightedEntities: (ids: string[]) => void;
  requestFitView: () => void;
  requestFocus: () => void;
  setMobilePanel: (panel: MobilePanel) => void;
  resetForAnalysis: (rootEClassId: string, stageId?: string) => void;
  clearSelections: () => void;
}

export const defaultGraphFilters: GraphFilters = {
  reachableOnly: true,
  collapseSingleton: true,
  collapseLarge: true,
  showAllAlternatives: false,
  showCrossLinks: false,
  showHistorical: false,
  showRebuildDetails: false,
  depth: 5,
};

export const useUiStore = create<UiState>((set) => ({
  equivalenceENodeIds: [],
  expandedClasses: new Set(),
  graphFilters: defaultGraphFilters,
  graphSearch: "",
  traceKind: "all",
  traceSearch: "",
  traceSelectedOnly: false,
  ambiguousMappingIds: [],
  highlightedEntityIds: [],
  fitViewRequest: 0,
  focusRequest: 0,
  mobilePanel: "graph",
  setSelectedPredicate: (selectedPredicate) => set({ selectedPredicate }),
  selectEClass: (selectedEClassId) => set({
    selectedEClassId,
    selectedENodeId: undefined,
    equivalenceENodeIds: [],
    ambiguousMappingIds: [],
    highlightedEntityIds: selectedEClassId ? [selectedEClassId] : [],
  }),
  selectENode: (selectedENodeId, selectedEClassId, extend = false) => set((state) => {
    if (!selectedENodeId) {
      return { selectedENodeId: undefined, equivalenceENodeIds: [] };
    }
    const next = extend
      ? [...state.equivalenceENodeIds.filter((id) => id !== selectedENodeId), selectedENodeId].slice(-2)
      : [selectedENodeId];
    return {
      selectedENodeId,
      selectedEClassId: selectedEClassId ?? state.selectedEClassId,
      equivalenceENodeIds: next,
      ambiguousMappingIds: [],
      highlightedEntityIds: [selectedENodeId, selectedEClassId ?? state.selectedEClassId]
        .filter((id): id is string => Boolean(id)),
    };
  }),
  setSelectedSlot: (selectedSlotId) => set({ selectedSlotId }),
  setHoveredSlot: (hoveredSlotId) => set({ hoveredSlotId }),
  toggleExpandedClass: (id) => set((state) => {
    const expandedClasses = new Set(state.expandedClasses);
    if (expandedClasses.has(id)) expandedClasses.delete(id);
    else expandedClasses.add(id);
    return { expandedClasses };
  }),
  setGraphFilter: (key, value) => set((state) => ({
    graphFilters: { ...state.graphFilters, [key]: value },
  })),
  setGraphSearch: (graphSearch) => set({ graphSearch }),
  setCurrentStage: (currentStageId) => set({ currentStageId }),
  setTraceKind: (traceKind) => set({ traceKind }),
  setTraceSearch: (traceSearch) => set({ traceSearch }),
  setTraceSelectedOnly: (traceSelectedOnly) => set({ traceSelectedOnly }),
  setAmbiguousMappings: (ambiguousMappingIds) => set({ ambiguousMappingIds }),
  setHighlightedEntities: (highlightedEntityIds) => set({ highlightedEntityIds }),
  requestFitView: () => set((state) => ({ fitViewRequest: state.fitViewRequest + 1 })),
  requestFocus: () => set((state) => ({ focusRequest: state.focusRequest + 1 })),
  setMobilePanel: (mobilePanel) => set({ mobilePanel }),
  resetForAnalysis: (selectedEClassId, currentStageId) => set({
    selectedEClassId,
    selectedENodeId: undefined,
    equivalenceENodeIds: [],
    selectedSlotId: undefined,
    hoveredSlotId: undefined,
    expandedClasses: new Set(),
    graphSearch: "",
    currentStageId,
    traceKind: "all",
    traceSearch: "",
    traceSelectedOnly: false,
    ambiguousMappingIds: [],
    highlightedEntityIds: [selectedEClassId],
    fitViewRequest: 1,
    focusRequest: 0,
  }),
  clearSelections: () => set({
    selectedEClassId: undefined,
    selectedENodeId: undefined,
    equivalenceENodeIds: [],
    hoveredSlotId: undefined,
    ambiguousMappingIds: [],
    highlightedEntityIds: [],
  }),
}));
