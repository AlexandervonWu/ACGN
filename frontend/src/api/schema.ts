import { z } from "zod";

const id = z.string().min(1);
const openRecord = z.record(z.unknown());

export const SourcePositionSchema = z.object({
  line: z.number().int().positive(),
  column: z.number().int().positive(),
});

export const SourceRangeSchema = z.object({
  start: SourcePositionSchema,
  end: SourcePositionSchema,
});

export const DiagnosticSchema = z.object({
  severity: z.enum(["error", "warning", "info"]),
  message: z.string(),
  sourceRange: SourceRangeSchema.optional(),
  code: z.string().optional(),
}).passthrough();

export const CallableKindSchema = z.enum(["predicate", "function"]);

export const CallableSummarySchema = z.object({
  name: id,
  kind: CallableKindSchema,
  sourceRange: SourceRangeSchema.optional(),
  returnType: z.string().optional(),
});

export const PredicateSummarySchema = CallableSummarySchema.omit({
  kind: true,
  returnType: true,
});

export const ModelInspectionSchema = z.object({
  callables: z.array(CallableSummarySchema).optional(),
  predicates: z.array(PredicateSummarySchema).optional(),
  parseDiagnostics: z.array(DiagnosticSchema),
}).passthrough().transform((inspection) => {
  const callables = inspection.callables
    ?? (inspection.predicates ?? []).map((predicate) => ({
      ...predicate,
      kind: "predicate" as const,
    }));
  return {
    ...inspection,
    callables,
    predicates: inspection.predicates
      ?? callables.filter((callable) => callable.kind === "predicate")
        .map(({ name, sourceRange }) => ({ name, sourceRange })),
  };
});

export const TypeDescriptorSchema = z.discriminatedUnion("kind", [
  z.object({ kind: z.literal("formula") }),
  z.object({ kind: z.literal("relation"), columns: z.array(z.string()) }),
  z.object({ kind: z.literal("atom"), signature: z.string() }),
  z.object({ kind: z.literal("unknown"), display: z.string() }),
]);

export const SlotRefSchema = z.object({
  id,
  type: z.string().optional(),
  displayName: z.string().optional(),
}).passthrough();

export const SlotBindingSchema = z.object({
  slotId: id,
  role: z.string().optional(),
  type: z.string().optional(),
  sourceBinder: z.string().optional(),
}).passthrough();

export const ProvenanceRefSchema = z.union([
  id,
  z.object({
    id: id.optional(),
    kind: z.string().optional(),
    label: z.string().optional(),
    summary: z.string().optional(),
  }).passthrough(),
]);

export const InvariantStatusSchema = z.object({
  id,
  name: z.string(),
  status: z.enum(["pass", "fail", "unknown"]),
  message: z.string().optional(),
  relatedEntityIds: z.array(id).optional(),
}).passthrough();

export const ContainerMetadataSchema = z.object({
  kind: z.enum(["A", "AC", "ACI", "ordered", "set-like", "custom"]),
  operator: z.string().optional(),
  duplicateElimination: z.boolean().optional(),
  orderInsensitive: z.boolean().optional(),
  flattened: z.boolean().optional(),
}).passthrough();

export const ChildRefSchema = z.object({
  role: z.string().optional(),
  eclassId: id,
}).passthrough();

export const ENodeSchema = z.object({
  id,
  kind: z.string(),
  displayName: z.string().optional(),
  children: z.array(ChildRefSchema),
  type: TypeDescriptorSchema.optional(),
  slots: z.array(SlotBindingSchema).optional(),
  container: ContainerMetadataSchema.optional(),
  sourceRange: SourceRangeSchema.optional(),
  provenance: z.array(ProvenanceRefSchema).optional(),
  certificateIds: z.array(id).optional(),
  attributes: openRecord.optional(),
}).passthrough();

export const EClassSchema = z.object({
  id,
  type: TypeDescriptorSchema.optional(),
  support: z.array(SlotRefSchema).optional(),
  effectiveSupport: z.array(SlotRefSchema).optional(),
  nodes: z.array(ENodeSchema),
  canonicalNodeId: id.optional(),
  representativeNodeId: id.optional(),
  provenance: z.array(ProvenanceRefSchema).optional(),
  invariantStatus: z.array(InvariantStatusSchema).optional(),
  statistics: z.object({
    nodeCount: z.number().int().nonnegative().optional(),
    incomingCount: z.number().int().nonnegative().optional(),
    outgoingCount: z.number().int().nonnegative().optional(),
  }).optional(),
}).passthrough();

export const GraphEdgeSchema = z.object({
  id: id.optional(),
  sourceEClassId: id,
  targetEClassId: id,
  role: z.string().optional(),
  enodeId: id.optional(),
}).passthrough();

export const SaturationRoundSchema = z.object({
  index: z.number().int().nonnegative(),
  eclassCount: z.number().int().nonnegative(),
  enodeCount: z.number().int().nonnegative(),
  merges: z.number().int().nonnegative(),
  rebuilds: z.number().int().nonnegative().optional(),
}).passthrough();

export const SaturationMetadataSchema = z.object({
  rounds: z.array(SaturationRoundSchema).optional(),
  saturated: z.boolean().optional(),
  stopReason: z.string().optional(),
}).passthrough();

export const EGraphSchema = z.object({
  rootEClassId: id,
  eclasses: z.array(EClassSchema),
  edges: z.array(GraphEdgeSchema).optional(),
  saturation: SaturationMetadataSchema.optional(),
}).passthrough();

export const SourceMappingSchema = z.object({
  id,
  sourceRange: SourceRangeSchema,
  eclassIds: z.array(id).optional(),
  enodeIds: z.array(id).optional(),
  stageId: id.optional(),
  kind: z.enum(["origin", "normalized-from", "binder", "derived", "other"]),
}).passthrough();

export const NormalizationStageSchema = z.object({
  id,
  index: z.number().int().nonnegative(),
  name: z.string(),
  description: z.string().optional(),
  text: z.string().optional(),
  rootEClassId: id.optional(),
  graphSnapshotId: id.optional(),
  sourceMappings: z.array(SourceMappingSchema).optional(),
}).passthrough();

export const TraceEventSchema = z.object({
  id,
  index: z.number().int().nonnegative(),
  kind: z.enum([
    "rewrite",
    "merge",
    "rebuild",
    "normalize",
    "slot-map",
    "canonicalize",
    "other",
  ]),
  rule: z.string().optional(),
  summary: z.string(),
  beforeEClassIds: z.array(id).optional(),
  afterEClassIds: z.array(id).optional(),
  beforeENodeIds: z.array(id).optional(),
  afterENodeIds: z.array(id).optional(),
  certificateIds: z.array(id).optional(),
  stageId: id.optional(),
  metadata: openRecord.optional(),
}).passthrough();

export const CertificateTermSchema = z.object({
  text: z.string().optional(),
  entityIds: z.array(id).optional(),
  slotIds: z.array(id).optional(),
  metadata: openRecord.optional(),
}).passthrough();

export const CertificateStepSchema = z.object({
  index: z.number().int().nonnegative().optional(),
  rule: z.string().optional(),
  summary: z.string().optional(),
  term: CertificateTermSchema.optional(),
  entityIds: z.array(id).optional(),
  metadata: openRecord.optional(),
}).passthrough();

export const CertificateSchema = z.object({
  id,
  kind: z.string(),
  title: z.string().optional(),
  summary: z.string().optional(),
  premises: z.array(CertificateTermSchema).optional(),
  conclusion: CertificateTermSchema.optional(),
  steps: z.array(CertificateStepSchema).optional(),
  metadata: openRecord.optional(),
}).passthrough();

export const ModelMetadataSchema = z.object({
  name: z.string().optional(),
  digest: z.string().optional(),
  sourceLength: z.number().int().nonnegative().optional(),
}).passthrough();

export const PredicateMetadataSchema = z.object({
  name: id,
  sourceRange: SourceRangeSchema.optional(),
  rootEClassId: id,
  originalText: z.string().optional(),
  normalizedText: z.string().optional(),
  canonicalText: z.string().optional(),
  certifiedStableForm: z.string().optional(),
}).passthrough();

export const CallableMetadataSchema = PredicateMetadataSchema.extend({
  kind: CallableKindSchema,
  returnType: z.string().optional(),
}).passthrough();

export const AnalysisStatisticsSchema = z.object({
  parseMs: z.number().nonnegative().optional(),
  normalizationMs: z.number().nonnegative().optional(),
  saturationMs: z.number().nonnegative().optional(),
  totalMs: z.number().nonnegative().optional(),
  eclassCount: z.number().int().nonnegative().optional(),
  enodeCount: z.number().int().nonnegative().optional(),
  mergeCount: z.number().int().nonnegative().optional(),
  saturationRounds: z.number().int().nonnegative().optional(),
  rootReachableEClassCount: z.number().int().nonnegative().optional(),
}).passthrough();

export const EGraphAnalysisSchema = z.object({
  schemaVersion: z.string().regex(/^\d+\.\d+(?:\.\d+)?$/),
  model: ModelMetadataSchema,
  predicate: PredicateMetadataSchema,
  callable: CallableMetadataSchema.optional(),
  stages: z.array(NormalizationStageSchema),
  graph: EGraphSchema,
  sourceMappings: z.array(SourceMappingSchema).optional(),
  trace: z.array(TraceEventSchema).optional(),
  certificates: z.array(CertificateSchema).optional(),
  diagnostics: z.array(DiagnosticSchema).optional(),
  statistics: AnalysisStatisticsSchema.optional(),
}).passthrough().superRefine((analysis, context) => {
  const eclassIds = new Set<string>();
  const enodeIds = new Set<string>();

  analysis.graph.eclasses.forEach((eclass, classIndex) => {
    if (eclassIds.has(eclass.id)) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["graph", "eclasses", classIndex, "id"],
        message: `Duplicate e-class ID ${eclass.id}.`,
      });
    }
    eclassIds.add(eclass.id);

    const memberIds = new Set<string>();
    eclass.nodes.forEach((enode, nodeIndex) => {
      if (enodeIds.has(enode.id)) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["graph", "eclasses", classIndex, "nodes", nodeIndex, "id"],
          message: `Duplicate e-node ID ${enode.id}.`,
        });
      }
      enodeIds.add(enode.id);
      memberIds.add(enode.id);
    });

    for (const [field, value] of [
      ["canonicalNodeId", eclass.canonicalNodeId],
      ["representativeNodeId", eclass.representativeNodeId],
    ] as const) {
      if (value && !memberIds.has(value)) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["graph", "eclasses", classIndex, field],
          message: `${field} ${value} is not a member of e-class ${eclass.id}.`,
        });
      }
    }
  });

  if (!eclassIds.has(analysis.graph.rootEClassId)) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["graph", "rootEClassId"],
      message: `Graph root ${analysis.graph.rootEClassId} does not reference an e-class.`,
    });
  }
  const callableRoot = analysis.callable?.rootEClassId ?? analysis.predicate.rootEClassId;
  if (!eclassIds.has(callableRoot)) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      path: [analysis.callable ? "callable" : "predicate", "rootEClassId"],
      message: `Callable root ${callableRoot} does not reference an e-class.`,
    });
  }

  analysis.graph.eclasses.forEach((eclass, classIndex) => {
    eclass.nodes.forEach((enode, nodeIndex) => {
      enode.children.forEach((child, childIndex) => {
        if (!eclassIds.has(child.eclassId)) {
          context.addIssue({
            code: z.ZodIssueCode.custom,
            path: ["graph", "eclasses", classIndex, "nodes", nodeIndex, "children", childIndex, "eclassId"],
            message: `Child reference ${child.eclassId} does not reference an e-class.`,
          });
        }
      });
    });
  });

  analysis.graph.edges?.forEach((edge, edgeIndex) => {
    for (const [field, value] of [
      ["sourceEClassId", edge.sourceEClassId],
      ["targetEClassId", edge.targetEClassId],
    ] as const) {
      if (!eclassIds.has(value)) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["graph", "edges", edgeIndex, field],
          message: `Edge ${field} ${value} does not reference an e-class.`,
        });
      }
    }
    if (edge.enodeId && !enodeIds.has(edge.enodeId)) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["graph", "edges", edgeIndex, "enodeId"],
        message: `Edge e-node ${edge.enodeId} does not reference an e-node.`,
      });
    }
  });
});

export const DistanceComponentSchema = z.enum([
  "temporal",
  "quantifier",
  "matrix",
  "equivalence",
]);

export const DistanceOperationSchema = z.object({
  id,
  index: z.number().int().nonnegative(),
  component: DistanceComponentSchema,
  kind: z.enum(["insert", "delete", "replace", "modify", "aggregate", "no-op"]),
  path: z.string(),
  summary: z.string(),
  source: z.string().optional(),
  target: z.string().optional(),
  cost: z.number().int().nonnegative(),
  detail: z.enum(["unit", "aggregate"]),
});

export const ComparisonCallableSchema = z.object({
  name: id,
  kind: CallableKindSchema,
  returnType: z.string().optional(),
  originalText: z.string(),
  normalizedText: z.string(),
  canonicalText: z.string(),
  certifiedStableForm: z.string().optional(),
  digest: id,
  representationSize: z.number().int().nonnegative(),
});

export const DistanceBreakdownSchema = z.object({
  total: z.number().int().nonnegative(),
  temporal: z.number().int().nonnegative(),
  quantifier: z.number().int().nonnegative(),
  matrix: z.number().int().nonnegative(),
  exactForStoredOrbits: z.boolean(),
  binderAlignments: z.number().int().nonnegative(),
});

export const DistanceStatisticsSchema = z.object({
  parseMs: z.number().nonnegative().optional(),
  preparationMs: z.number().nonnegative().optional(),
  distanceMs: z.number().nonnegative().optional(),
  totalMs: z.number().nonnegative().optional(),
});

export const CallableComparisonSchema = z.object({
  schemaVersion: z.string().regex(/^\d+\.\d+(?:\.\d+)?$/),
  model: ModelMetadataSchema,
  left: ComparisonCallableSchema,
  right: ComparisonCallableSchema,
  metricVersion: id,
  certifiedEquivalent: z.boolean(),
  operationDetail: z.enum(["unit", "mixed"]),
  distance: DistanceBreakdownSchema,
  operations: z.array(DistanceOperationSchema),
  statistics: DistanceStatisticsSchema.optional(),
}).superRefine((comparison, context) => {
  const componentTotal = comparison.distance.temporal
    + comparison.distance.quantifier
    + comparison.distance.matrix;
  if (componentTotal !== comparison.distance.total) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["distance", "total"],
      message: `Distance components sum to ${componentTotal}, not ${comparison.distance.total}.`,
    });
  }

  const operationTotal = comparison.operations.reduce(
    (sum, operation) => sum + operation.cost,
    0,
  );
  if (operationTotal !== comparison.distance.total) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["operations"],
      message: `Operation costs sum to ${operationTotal}, not ${comparison.distance.total}.`,
    });
  }

  if (comparison.certifiedEquivalent !== (comparison.distance.total === 0)) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["certifiedEquivalent"],
      message: "Certified equivalence must coincide with the zero-distance kernel.",
    });
  }

  const operationIds = new Set<string>();
  comparison.operations.forEach((operation, index) => {
    if (operationIds.has(operation.id)) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["operations", index, "id"],
        message: `Duplicate operation ID ${operation.id}.`,
      });
    }
    operationIds.add(operation.id);
  });
});

export const HealthStatusSchema = z.object({
  status: z.enum(["ok", "degraded"]),
  version: z.string().optional(),
  visualizationSchemaVersion: z.string().optional(),
}).passthrough();
