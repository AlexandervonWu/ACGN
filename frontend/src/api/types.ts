import type { z } from "zod";
import type {
  AnalysisStatisticsSchema,
  CallableComparisonSchema,
  CallableKindSchema,
  CallableMetadataSchema,
  CallableSummarySchema,
  CertificateSchema,
  CertificateStepSchema,
  CertificateTermSchema,
  ChildRefSchema,
  ContainerMetadataSchema,
  DiagnosticSchema,
  DistanceBreakdownSchema,
  DistanceComponentSchema,
  DistanceOperationSchema,
  DistanceStatisticsSchema,
  EClassSchema,
  EGraphAnalysisSchema,
  EGraphSchema,
  ENodeSchema,
  GraphEdgeSchema,
  HealthStatusSchema,
  InvariantStatusSchema,
  ModelInspectionSchema,
  ModelMetadataSchema,
  NormalizationStageSchema,
  PredicateMetadataSchema,
  PredicateSummarySchema,
  ProvenanceRefSchema,
  SaturationMetadataSchema,
  SaturationRoundSchema,
  SlotBindingSchema,
  SlotRefSchema,
  SourceMappingSchema,
  SourcePositionSchema,
  SourceRangeSchema,
  TraceEventSchema,
  TypeDescriptorSchema,
} from "./schema";

export type SourcePosition = z.infer<typeof SourcePositionSchema>;
export type SourceRange = z.infer<typeof SourceRangeSchema>;
export type Diagnostic = z.infer<typeof DiagnosticSchema>;
export type CallableComparison = z.infer<typeof CallableComparisonSchema>;
export type CallableKind = z.infer<typeof CallableKindSchema>;
export type CallableSummary = z.infer<typeof CallableSummarySchema>;
export type PredicateSummary = z.infer<typeof PredicateSummarySchema>;
export type ModelInspection = z.infer<typeof ModelInspectionSchema>;
export type TypeDescriptor = z.infer<typeof TypeDescriptorSchema>;
export type SlotRef = z.infer<typeof SlotRefSchema>;
export type SlotBinding = z.infer<typeof SlotBindingSchema>;
export type ProvenanceRef = z.infer<typeof ProvenanceRefSchema>;
export type InvariantStatus = z.infer<typeof InvariantStatusSchema>;
export type ContainerMetadata = z.infer<typeof ContainerMetadataSchema>;
export type ChildRef = z.infer<typeof ChildRefSchema>;
export type ENode = z.infer<typeof ENodeSchema>;
export type EClass = z.infer<typeof EClassSchema>;
export type GraphEdge = z.infer<typeof GraphEdgeSchema>;
export type SaturationRound = z.infer<typeof SaturationRoundSchema>;
export type SaturationMetadata = z.infer<typeof SaturationMetadataSchema>;
export type EGraph = z.infer<typeof EGraphSchema>;
export type SourceMapping = z.infer<typeof SourceMappingSchema>;
export type NormalizationStage = z.infer<typeof NormalizationStageSchema>;
export type TraceEvent = z.infer<typeof TraceEventSchema>;
export type CertificateTerm = z.infer<typeof CertificateTermSchema>;
export type CertificateStep = z.infer<typeof CertificateStepSchema>;
export type Certificate = z.infer<typeof CertificateSchema>;
export type ModelMetadata = z.infer<typeof ModelMetadataSchema>;
export type PredicateMetadata = z.infer<typeof PredicateMetadataSchema>;
export type CallableMetadata = z.infer<typeof CallableMetadataSchema>;
export type AnalysisStatistics = z.infer<typeof AnalysisStatisticsSchema>;
export type DistanceComponent = z.infer<typeof DistanceComponentSchema>;
export type DistanceOperation = z.infer<typeof DistanceOperationSchema>;
export type DistanceBreakdown = z.infer<typeof DistanceBreakdownSchema>;
export type DistanceStatistics = z.infer<typeof DistanceStatisticsSchema>;
export type EGraphAnalysis = z.infer<typeof EGraphAnalysisSchema>;
export type HealthStatus = z.infer<typeof HealthStatusSchema>;

export interface AnalysisOptions {
  includeStages?: boolean;
  includeTrace?: boolean;
  includeCertificates?: boolean;
  includeSourceMappings?: boolean;
}

export interface CallableReference {
  name: string;
  kind: CallableKind;
}

export type ApiErrorKind =
  | "configuration"
  | "network"
  | "backend"
  | "parse"
  | "type"
  | "callable-not-found"
  | "predicate-not-found"
  | "analysis"
  | "schema"
  | "unsupported-version"
  | "timeout"
  | "cancelled";
