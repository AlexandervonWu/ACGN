import ClosedSourceArguments
import ProjectedAlternativeCensus
import NativeDeclarationTraceCoherence
import AuthenticatedPhaseTransport
import TemporalReferenceReconstruction
import SelectedTemporalPayment
import SelectedPrimaryCongruence

/- One shared environment for the eight diagnosed families. Each law exposes
   the premises Java must establish. Compilation does not discharge candidate
   completeness, live source authentication, or any of the forty pairs. -/
namespace Focus40Congruence

-- 1. Live support and relocation preserve construction in any enclosing context.
theorem temporal_support_congruence (expression : TemporalReferenceReachability.Expr V)
    (address : TemporalReferenceReachability.Reference → Nat)
    (lookup : Nat → Option TemporalReferenceReachability.Reference)
    (resolve : TemporalReferenceReachability.Reference → Option V)
    (roundtrip : ∀ source ∈ TemporalReferenceReachability.support expression,
      lookup (address source) = some source) (context : Option V → R) :
    context (TemporalReferenceReachability.construct
      (TemporalReferenceReachability.restrict (TemporalReferenceReachability.support expression)
        (TemporalReferenceReachability.relocatedResolver address lookup resolve)) expression) =
      context (TemporalReferenceReachability.construct resolve expression) := by
  rw [Category72.Temporal.projected_support_and_relocation expression address lookup resolve roundtrip]

-- 2. An attaining declaration program must use its actual selected matrix link.
theorem declaration_matrix_congruence
    (old chosen : List SelectedDeclarationPathTransport.Step)
    (source target : List SelectedDeclarationCompletion.Binding) (n : Nat)
    (mapping : SelectedDeclarationCompletion.Mapping)
    (oldSource : SelectedDeclarationPathTransport.sources old = source)
    (newSource : SelectedDeclarationPathTransport.sources chosen = source)
    (oldReplay : SelectedDeclarationPathTransport.replay source old = some (target,n))
    (newReplay : SelectedDeclarationPathTransport.replay source chosen = some (target,n))
    (linked : ∀ step ∈ chosen, NativeDeclarationTraceCoherence.linked mapping step) :
    SelectedDeclarationPathTransport.cost old = SelectedDeclarationPathTransport.cost chosen ∧
    SelectedDeclarationPathTransport.targets chosen = target ∧
    ∀ a b, SelectedDeclarationPathTransport.Step.pair a b ∈ chosen →
      mapping a.vectorIndex = some b.vectorIndex :=
  NativeDeclarationTraceCoherence.selected_tie_preserves_component
    old chosen source target n mapping oldSource newSource oldReplay newReplay linked

-- 3. Opaque calls preserve all ordered typed arguments and original source keys.
theorem call_congruence {V : Type} (environment : ScopedCallCorrespondence.Slot → V)
    (operation : ScopedCallCorrespondence.Head → List V → V)
    (invoke : Focused225CallViews.SourceKey → BoundCallAdmission.Head → List V → V)
    (issued current : ClosedSourceArguments.IssuedCall)
    (checked : ClosedSourceArguments.admits issued current = true) :
    ClosedSourceArguments.evaluate environment operation invoke current =
      ClosedSourceArguments.evaluate environment operation invoke issued :=
  ClosedSourceArguments.opaque_congruence environment operation invoke issued current checked

-- 4. Independent alternatives do not consume one endpoint's size allowance.
theorem census_congruence (inventory : ProjectedAlternativeCensus.Inventory)
    (limit size : Nat) (accepted : ProjectedAlternativeCensus.admits limit inventory = true)
    (selected : ProjectedAlternativeCensus.Selected inventory size) :
    size ≤ limit ∧ ProjectedAlternativeCensus.validate inventory = true :=
  ProjectedAlternativeCensus.accepted_endpoint_bounded inventory limit size accepted selected

-- 5. A typed read transports through an inverse owned-slot map, not a name match.
theorem paid_read_congruence {Value : String → Type} (types : Nat → String)
    (environment : (i : Nat) → Value (types i)) (forward back : Nat → Nat)
    (source : Nat) (inverse : back (forward source) = source) :
    HEq (DeclarationKeepTransport.transported types environment back (forward source))
      (environment source) :=
  DeclarationKeepTransport.typed_read_roundtrip types environment forward back source inverse

-- 6. A REF payload may be reconstructed only from the executed paid skeleton.
theorem reference_payment_congruence (program : List TemporalReferenceReconstruction.Edit)
    (source target : TemporalReferenceReconstruction.Skeleton)
    (slot : TemporalReferenceReconstruction.Slot) (before after : TemporalReferenceReconstruction.Edge)
    (paid : Nat)
    (selected : TemporalReferenceReconstruction.execute program source = some (target,paid))
    (sourceLink : source slot = some before) (targetLink : target slot = some after) :
    TemporalReferenceReconstruction.reconstitute program source slot before = some (after,paid) :=
  TemporalReferenceReconstruction.selected_skeleton_reconstructs_typed_reference
    program source target slot before after paid selected sourceLink targetLink

-- 7. Equal scalar minima alone are insufficient; complete keyed candidates agree.
theorem matrix_selection_congruence {Program : Type}
    (key : Program → Category72.Selection.Key)
    (faithful : ∀ x y, key x = key y → x = y) (fast certified : Program)
    (f c : Category72.Selection.Key) (fs cs : List Category72.Selection.Key)
    (same : ∀ k, k ∈ f :: fs ↔ k ∈ c :: cs)
    (hf : key fast = Category72.Selection.select f fs)
    (hc : key certified = Category72.Selection.select c cs) : fast = certified :=
  Category72.Selection.identical_selected_programs key faithful fast certified f c fs cs same hf hc

-- 8. Phase presentation transports one entire program, including all charges.
theorem phase_presentation_congruence [DecidableEq A] [DecidableEq B] [DecidableEq P]
    (e : AuthenticatedPhaseTransport.Reindex A B)
    (s t : DistanceDerivedTrace.Store A P) (ops : List (DistanceDerivedTrace.Operation A P))
    (replayed : DistanceDerivedTrace.run s ops = some t) :
    DistanceDerivedTrace.run (AuthenticatedPhaseTransport.moveStore e s)
      (ops.map (AuthenticatedPhaseTransport.moveOperation e)) =
        some (AuthenticatedPhaseTransport.moveStore e t) ∧
    DistanceDerivedTrace.cost (ops.map (AuthenticatedPhaseTransport.moveOperation e)) =
      DistanceDerivedTrace.cost ops :=
  AuthenticatedPhaseTransport.selected_path_preserved e s t ops replayed

end Focus40Congruence
