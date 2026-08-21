/-
Abstract Phase 3 model for statically empty Alloy relation types. It proves the
arity and non-invention obligations only; parser, Java, wire, visualization,
and metric refinement remain independent conformance gates.
-/

import Std

namespace Phase3EmptyRelations

abbrev Column := String

structure ParserView where
  arity : Nat
  maskedColumns : List (Option Column)
deriving DecidableEq, Repr

def parserEmptyView (sourceColumns : List Column) : ParserView :=
  { arity := sourceColumns.length
    maskedColumns := List.replicate sourceColumns.length none }

theorem parser_retains_arity (columns : List Column) :
    (parserEmptyView columns).arity = columns.length := by
  rfl

theorem empty_parent_columns_are_erased :
    parserEmptyView ["none", "A"] = parserEmptyView ["A", "none"] := by
  decide

theorem no_decoder_recovers_both_parent_column_orders
    (decode : ParserView -> List Column) :
    ¬ (decode (parserEmptyView ["none", "A"]) = ["none", "A"] ∧
       decode (parserEmptyView ["A", "none"]) = ["A", "none"]) := by
  intro recovered
  have impossible : (["none", "A"] : List Column) = ["A", "none"] := by
    calc
      ["none", "A"] = decode (parserEmptyView ["none", "A"]) :=
        recovered.1.symm
      _ = decode (parserEmptyView ["A", "none"]) :=
        congrArg decode empty_parent_columns_are_erased
      _ = ["A", "none"] := recovered.2
  simp at impossible

inductive ArityFreeExact where
  | emptyRelation
deriving DecidableEq, Repr

inductive ArityFreeGraph where
  | constructor (name : String)
deriving DecidableEq, Repr

def arityFreeExact (_view : ParserView) : ArityFreeExact := .emptyRelation

def arityFreeBridge : ArityFreeExact -> ArityFreeGraph
  | .emptyRelation => .constructor "AlloyEmptyRelation"

theorem arity_free_unary_binary_collapse :
    arityFreeBridge (arityFreeExact (parserEmptyView ["none"])) =
      arityFreeBridge (arityFreeExact (parserEmptyView ["none", "none"])) := by
  rfl

theorem arity_free_unary_ternary_collapse :
    arityFreeBridge (arityFreeExact (parserEmptyView ["none"])) =
      arityFreeBridge
        (arityFreeExact (parserEmptyView ["none", "none", "none"])) := by
  rfl

structure PositiveArity where
  value : Nat
  positive : 0 < value
deriving DecidableEq, Repr

def positiveArity (value : Nat) : Option PositiveArity :=
  if positive : 0 < value then some { value, positive } else none

inductive ExactEmpty where
  | emptyRelation (arity : PositiveArity)
deriving DecidableEq, Repr

inductive EmptyGraphType where
  | emptyRelation (arity : PositiveArity)
deriving DecidableEq, Repr

def exactEmpty (view : ParserView) : Option ExactEmpty :=
  (positiveArity view.arity).map ExactEmpty.emptyRelation

def emptyBridge : ExactEmpty -> EmptyGraphType
  | .emptyRelation arity => .emptyRelation arity

theorem arityless_empty_fails_closed :
    exactEmpty { arity := 0, maskedColumns := [] } = none := by
  decide

theorem exact_unary :
    (exactEmpty (parserEmptyView ["none"])).map
      (fun value => match value with | .emptyRelation arity => arity.value) =
        some 1 := by
  decide

theorem exact_binary :
    (exactEmpty (parserEmptyView ["none", "none"])).map
      (fun value => match value with | .emptyRelation arity => arity.value) =
        some 2 := by
  decide

theorem exact_ternary :
    (exactEmpty (parserEmptyView ["none", "none", "none"])).map
      (fun value => match value with | .emptyRelation arity => arity.value) =
        some 3 := by
  decide

theorem empty_graph_arity_is_injective :
    Function.Injective EmptyGraphType.emptyRelation := by
  intro left right equality
  cases equality
  rfl

theorem empty_arities_are_distinct :
    EmptyGraphType.emptyRelation ⟨1, by decide⟩ ≠
        EmptyGraphType.emptyRelation ⟨2, by decide⟩ ∧
    EmptyGraphType.emptyRelation ⟨1, by decide⟩ ≠
        EmptyGraphType.emptyRelation ⟨3, by decide⟩ ∧
    EmptyGraphType.emptyRelation ⟨2, by decide⟩ ≠
        EmptyGraphType.emptyRelation ⟨3, by decide⟩ := by
  decide

abbrev Atom := Nat
abbrev Relation (arity : Nat) := (Fin arity -> Atom) -> Prop

def typedEmpty {arity : Nat}
    (_columns : Fin arity -> Column) : Relation arity :=
  fun _tuple => False

theorem empty_columns_are_semantically_irrelevant_at_fixed_arity
    {arity : Nat} (left right : Fin arity -> Column) :
    typedEmpty left = typedEmpty right := by
  funext tuple
  apply propext
  constructor <;> intro impossible <;> contradiction

structure MasgOccurrence where exact : ExactEmpty
structure EGraphOccurrence where exact : ExactEmpty
structure MetricKey where exact : ExactEmpty
structure WireType where exact : ExactEmpty

def recordMasg (exact : ExactEmpty) : MasgOccurrence := { exact }
def attachEGraph (masg : MasgOccurrence) : EGraphOccurrence :=
  { exact := masg.exact }
def metricKey (node : EGraphOccurrence) : MetricKey := { exact := node.exact }
def wireType (node : EGraphOccurrence) : WireType := { exact := node.exact }

theorem pipeline_model_preserves_exact_empty (exact : ExactEmpty) :
    (metricKey (attachEGraph (recordMasg exact))).exact = exact ∧
    (wireType (attachEGraph (recordMasg exact))).exact = exact := by
  exact ⟨rfl, rfl⟩

def arityFreeMetricKey (_arity : Nat) : ArityFreeGraph :=
  .constructor "AlloyEmptyRelation"

def exactMetricKey (arity : PositiveArity) : EmptyGraphType :=
  .emptyRelation arity

theorem arity_free_metric_aliases_cross_arity :
    arityFreeMetricKey 1 = arityFreeMetricKey 2 := by
  rfl

theorem exact_metric_distinguishes_cross_arity :
    exactMetricKey ⟨1, by decide⟩ ≠ exactMetricKey ⟨2, by decide⟩ := by
  decide

def sameArityCarrier (left right : EmptyGraphType) : Bool :=
  match left, right with
  | .emptyRelation leftArity, .emptyRelation rightArity =>
      leftArity.value == rightArity.value

theorem same_arity_empty_carrier_admitted :
    sameArityCarrier
      (.emptyRelation ⟨2, by decide⟩)
      (.emptyRelation ⟨2, by decide⟩) = true := by
  rfl

theorem cross_arity_empty_carrier_rejected :
    sameArityCarrier
      (.emptyRelation ⟨1, by decide⟩)
      (.emptyRelation ⟨2, by decide⟩) = false := by
  rfl

structure EncodedEmpty where
  arity : Nat
  arguments : List Unit
  stableArity : Nat
deriving DecidableEq, Repr

def decodeEmpty (encoded : EncodedEmpty) : Option ExactEmpty :=
  if positive : 0 < encoded.arity then
    if ¬encoded.arguments.isEmpty then
      none
    else if encoded.stableArity != encoded.arity then
      none
    else
      some (.emptyRelation ⟨encoded.arity, positive⟩)
  else
    none

theorem canonical_nullary_empty_decodes (arity : Nat)
    (positive : 0 < arity) :
    decodeEmpty {
      arity := arity
      arguments := []
      stableArity := arity
    } = some (.emptyRelation ⟨arity, positive⟩) := by
  simp [decodeEmpty, positive]

theorem encoded_zero_arity_rejects :
    decodeEmpty { arity := 0, arguments := [], stableArity := 0 } = none := by
  rfl

theorem argument_bearing_empty_rejects (arity : Nat)
    (positive : 0 < arity) :
    decodeEmpty {
      arity := arity
      arguments := [()]
      stableArity := arity
    } = none := by
  simp [decodeEmpty, positive]

theorem forged_stable_arity_rejects
    (arity forged : Nat)
    (positive : 0 < arity)
    (different : forged ≠ arity) :
    decodeEmpty {
      arity := arity
      arguments := []
      stableArity := forged
    } = none := by
  simp [decodeEmpty, positive, different]

end Phase3EmptyRelations
