import PaidDeclarationAlignment
import Phase5SourceRules
import TemporalPhaseLocalBinding

/- A selected declaration update is a charged repair, not alpha equality of
   ALL and SOME. Its exact occurrence link can be used by a descendant read.
   This contract keeps the carrier and lexical origin explicit; temporal
   operator edits and Java object correspondence are separate checked links. -/
namespace PaidImportedBinding
open TemporalPhaseLocalBinding

structure Binding where
  origin : BinderOrigin
  carrier : String
  domain : String
  dependencies : List Nat
  quantifier : Nat
  multiplicity : Nat
  disjointness : Nat
  deriving DecidableEq

def atom (b : Binding) : PaidDeclarationAlignment.Atom :=
  { occurrence := b.origin.coordinate, tuple := b.quantifier }

def sameFrame (a b : Binding) : Bool :=
  decide (a.carrier = b.carrier ∧ a.domain = b.domain ∧
    a.dependencies = b.dependencies ∧ a.multiplicity = b.multiplicity ∧
    a.disjointness = b.disjointness ∧ a.origin.ownerPhase = b.origin.ownerPhase)

def oldGate (a b : Binding) : Bool := sameFrame a b && decide (a.quantifier = b.quantifier)

def sameRole : TemporalPhaseRole → TemporalPhaseRole → Bool
  | .unary _, .unary _ => true
  | .binaryLeft _, .binaryLeft _ => true
  | .binaryRight _, .binaryRight _ => true
  | _, _ => false

def replayRoles : List TemporalPhaseRole → List (TemporalPhaseRole × TemporalPhaseRole) →
    Option (List TemporalPhaseRole × Nat)
  | [], [] => some ([], 0)
  | actual :: rest, (before, after) :: edits => do
    if actual != before || !sameRole before after then none
    else
      let (tail, cost) ← replayRoles rest edits
      pure (after :: tail, cost + if before = after then 0 else 1)
  | _, _ => none

/- The expected declaration comes from the selected diagonal. The imported
   source must still be that exact lexical origin, not merely its type/name. -/
def transport (actual expected target : Binding) (read : PhaseImport)
    (edits : List (TemporalPhaseRole × TemporalPhaseRole)) : Option (PhaseImport × Nat) := do
  if actual != expected || !sameFrame actual target || !TemporalPhaseLocalBinding.admits actual.origin read then none
  else
    let (targetPath, temporalCost) ← replayRoles read.targetPath edits
    let (output, cost, links) ← PaidDeclarationAlignment.replay [atom actual]
      [.pair (atom expected) (atom target)]
    if output == [atom target] && cost == 1 &&
        links == [(actual.origin.coordinate, target.origin.coordinate)] then
      some (⟨target.origin, targetPath⟩, cost + temporalCost)
    else none

theorem selected_paid_update_transports_exact_import (a b : Binding)
    (sourcePath targetPath : List TemporalPhaseRole)
    (edits : List (TemporalPhaseRole × TemporalPhaseRole)) (temporalCost : Nat)
    (temporal : replayRoles sourcePath edits = some (targetPath, temporalCost))
    (frame : sameFrame a b = true) (changed : a.quantifier ≠ b.quantifier) :
    transport a a b ⟨a.origin, sourcePath⟩ edits =
      some (⟨b.origin, targetPath⟩, 1 + temporalCost) := by
  simp [transport, TemporalPhaseLocalBinding.admits, frame, atom, PaidDeclarationAlignment.replay, changed, temporal]

theorem changed_kind_rejected_by_old_gate (a b : Binding)
    (changed : a.quantifier ≠ b.quantifier) : oldGate a b = false := by
  simp [oldGate, changed]

theorem substituted_declaration_rejected (a expected b : Binding)
    (read : PhaseImport) (edits : List (TemporalPhaseRole × TemporalPhaseRole)) (wrong : a ≠ expected) :
    transport a expected b read edits = none := by simp [transport, wrong]

theorem substituted_origin_rejected (a b : Binding)
    (read : PhaseImport) (edits : List (TemporalPhaseRole × TemporalPhaseRole))
    (wrong : a.origin ≠ read.origin) : transport a a b read edits = none := by
  simp [transport, TemporalPhaseLocalBinding.admits, wrong]

theorem unchanged_declaration_cannot_fabricate_payment (a : Binding)
    (sourcePath : List TemporalPhaseRole) (edits : List (TemporalPhaseRole × TemporalPhaseRole)) :
    transport a a a ⟨a.origin, sourcePath⟩ edits = none := by
  cases h : replayRoles sourcePath edits <;>
    simp [transport, sameFrame, TemporalPhaseLocalBinding.admits, atom, PaidDeclarationAlignment.replay, h]

theorem changed_role_rejected (before after : TemporalPhaseRole)
    (rest : List TemporalPhaseRole) (edits : List (TemporalPhaseRole × TemporalPhaseRole))
    (different : sameRole before after = false) :
    replayRoles (before :: rest) ((before, after) :: edits) = none := by
  simp [replayRoles, different]

theorem missing_temporal_payment_rejected (a b : Binding)
    (read : PhaseImport) (edits : List (TemporalPhaseRole × TemporalPhaseRole))
    (missing : replayRoles read.targetPath edits = none) :
    transport a a b read edits = none := by
  simp [transport, missing]

/- Rebinding changes the quantifier head, not which value its descendant
   reads. Both environments are constructed here, rather than assuming that
   two arbitrary environments agree on the disputed coordinate. -/
theorem paid_import_read_sound (a b : Binding)
    (sourcePath targetPath : List TemporalPhaseRole)
    (edits : List (TemporalPhaseRole × TemporalPhaseRole)) (temporalCost : Nat)
    (temporal : replayRoles sourcePath edits = some (targetPath, temporalCost))
    (frame : sameFrame a b = true) (changed : a.quantifier ≠ b.quantifier)
    (Value : String → Type) (value : Value a.carrier)
    (sourceEnv : Nat → Value a.carrier) (targetEnv : Nat → Value b.carrier) :
    ∃ typed : a.carrier = b.carrier,
      transport a a b ⟨a.origin, sourcePath⟩ edits =
        some (⟨b.origin, targetPath⟩, 1 + temporalCost) ∧
      shadowBinder targetEnv b.origin.coordinate (typed ▸ value) b.origin.coordinate =
        typed ▸ shadowBinder sourceEnv a.origin.coordinate value a.origin.coordinate := by
  have fields : a.carrier = b.carrier ∧ a.domain = b.domain ∧
      a.dependencies = b.dependencies ∧ a.multiplicity = b.multiplicity ∧
      a.disjointness = b.disjointness ∧ a.origin.ownerPhase = b.origin.ownerPhase := by
    simpa [sameFrame] using frame
  refine ⟨fields.1, selected_paid_update_transports_exact_import a b sourcePath targetPath edits temporalCost temporal frame changed, ?_⟩
  simp [shadowBinder]

theorem updated_binder_body_reads_selected_value {Value : Type}
    (targetSlot : Nat) (environment : Nat → Value)
    (updatedQuantifier : (Value → Prop) → Prop) (body : Value → Prop) :
    updatedQuantifier (fun value => body
      (shadowBinder environment targetSlot value targetSlot)) = updatedQuantifier body := by
  simp [shadowBinder]

/- The exact natural source shapes before/after the three paid heads. These
   are not claimed equivalent. Matrix read transport above retains the same
   typed value at every time under the updated quantifier's environment. -/
def sourceFormula {File : Type} (carrier trash : Nat → File → Prop) (now : Nat) : Prop :=
  pastOnce (fun time => ∀ file, carrier time file →
    futureEventually (fun later => trash later file) time) now

def afterInnerUpdate {File : Type} (carrier trash : Nat → File → Prop) (now : Nat) : Prop :=
  pastOnce (fun time => ∀ file, carrier time file →
    futureAlways (fun later => trash later file) time) now

def afterOuterUpdate {File : Type} (carrier trash : Nat → File → Prop) (now : Nat) : Prop :=
  futureEventually (fun time => ∀ file, carrier time file →
    futureAlways (fun later => trash later file) time) now

def targetFormula {File : Type} (carrier trash : Nat → File → Prop) (now : Nat) : Prop :=
  futureEventually (fun time => ∃ file, carrier time file ∧
    futureAlways (fun later => trash later file) time) now

#print axioms selected_paid_update_transports_exact_import
#print axioms substituted_declaration_rejected
#print axioms substituted_origin_rejected
#print axioms unchanged_declaration_cannot_fabricate_payment
#print axioms paid_import_read_sound
end PaidImportedBinding
