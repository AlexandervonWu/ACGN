import PaidGuardEdit

namespace NaturalPaidGuardEdit
open PaidGuardEdit GuardedDomainProjection PaidImportedBinding TemporalPhaseLocalBinding
open DistanceDerivedTrace

def sourceHash : String := "14c5eed3cfa1442e0e7424b32f2383cd15034cf2d7c2522ab0422aa65a040928"
def ownerPath : List TemporalPhaseRole := [.unary .eventually]
def usePath : List TemporalPhaseRole := [.unary .eventually,.unary .always]
def sourceOrigin : BinderOrigin := ⟨0,1,0,0⟩
def targetOrigin : BinderOrigin := ⟨1,1,0,0⟩
def sourceBinding : Binding :=
  { origin := sourceOrigin, carrier := "RELATION[4:File]", domain := "File",
    dependencies := [], quantifier := 0, multiplicity := 1, disjointness := 0 }
def source : Frame :=
  { binding := sourceBinding, ownerPath, usePath, guardName := "Trash",
    occurrences := [3260,3261,3262,3264,3265,3263] }
def target : Frame :=
  { source with
    binding := {source.binding with origin := targetOrigin, quantifier := 1},
    occurrences := [3427,3428] }
/- Reverse occurrence identifiers belong to its fresh JVM, not the forward run. -/
def reverseSource : Frame := {target with occurrences := [289,290]}
def reverseTarget : Frame := {source with occurrences := [122,123,124,126,127,125]}
def payment (a b : Frame) : List PaidDeclarationAlignment.Edit :=
  [.pair (atom a.binding) (atom b.binding)]
def read (a : Frame) : PhaseImport := ⟨a.binding.origin,a.usePath⟩
def check (d : Direction) (a b : Frame) (ops : List (Operation Slot Node)) :=
  execute d a a b b (snapshot (beforeStore d a)) (snapshot (afterStore d b))
    ops [] [] [] [] [] (payment a b) (read a)

theorem forward_selected_path : check .remove source target (program .remove source target) =
    some (plain target,read target,6) := by
  change (run (beforeStore .remove source) (program .remove source target)).bind
    (fun next => if snapshot next != snapshot (plain target) then none else
      some (next,read target,6)) = some (plain target,read target,6)
  rw [program_replays]
  rfl

theorem reverse_selected_path : check .insert reverseSource reverseTarget
    (program .insert reverseSource reverseTarget) = some (guarded reverseTarget,read reverseTarget,6) := by
  change (run (beforeStore .insert reverseSource) (program .insert reverseSource reverseTarget)).bind
    (fun next => if snapshot next != snapshot (guarded reverseTarget) then none else
      some (next,read reverseTarget,6)) = some (guarded reverseTarget,read reverseTarget,6)
  rw [program_replays]
  rfl

/- The old Java projectionMatrix REF branch accepts HISTORICALLY only. Its
   later am.same(bm) test additionally requires equal logical tree structure;
   occurrence IDs and binder lineages are not compared by that test. -/
def oldTemporalGate (kind : UnaryTemporalKind) : Bool := decide (kind = .historically)
def oldBodyGate (a b : Store Slot Node) : Bool :=
  decide ((a .body).map (fun n => (n.head,n.children)) =
    (b .body).map (fun n => (n.head,n.children)))
theorem old_exact_temporal_gate_rejects : oldTemporalGate .always = false := by decide
theorem old_gate_rejects_forward : oldBodyGate (guarded source) (plain target) = false := by decide
theorem old_gate_rejects_reverse : oldBodyGate (plain reverseSource) (guarded reverseTarget) = false := by decide

def world {V : Type} (file trash : Nat → V → Prop) : World V :=
  fun name _ t v => if name = "File" then file t v else if name = "Trash" then file t v ∧ trash t v else False
def futureBody {V : Type} (file trash : Nat → V → Prop) : List TemporalPhaseRole → Nat → V → Prop :=
  fun path t v => if path = usePath then futureAlways (fun u => world file trash "Trash" [] u v) t else False
def originalSource {V : Type} (file trash : Nat → V → Prop) (now : Nat) : Prop :=
  futureEventually (fun t => ∀ v, (file t v ∧ world file trash "Trash" [] t v) →
    futureAlways (fun u => world file trash "Trash" [] u v) t) now
def originalTarget {V : Type} (file trash : Nat → V → Prop) (now : Nat) : Prop :=
  futureEventually (fun t => ∃ v, file t v ∧
    futureAlways (fun u => world file trash "Trash" [] u v) t) now

theorem declared_dynamic_subset {V : Type} (file trash : Nat → V → Prop) (t : Nat) (v : V) :
    world file trash "Trash" [] t v → world file trash "File" [] t v := by
  change (file t v ∧ trash t v) → file t v
  exact And.left

theorem source_lowering_at_owner {V : Type} (file trash : Nat → V → Prop) (now : Nat) :
    originalSource file trash now ↔ futureEventually
      (fun t => nativeMeaning .all source (guarded source) (world file trash) [] (futureBody file trash) t) now := by
  simp [originalSource, nativeMeaning, quantify, guarded_meaning, source, sourceBinding, futureBody,
    futureEventually, world, and_imp]

theorem executed_forward_source_target {V : Type} (file trash : Nat → V → Prop) (now : Nat)
    (next : Store Slot Node) (resultRead : PhaseImport) (charge : Nat)
    (executed : check .remove source target (program .remove source target) = some (next,resultRead,charge)) :
    charge = 6 ∧ resultRead = read target ∧
    (futureEventually (fun t => nativeMeaning .some target next (world file trash) []
      (futureBody file trash) t) now ↔ originalTarget file trash now) := by
  rw [forward_selected_path] at executed
  simp only [Option.some.injEq, Prod.mk.injEq] at executed
  rcases executed with ⟨hn,hr,hc⟩
  subst next
  refine ⟨hc.symm,hr.symm,?_⟩
  simp [nativeMeaning, quantify, plain_meaning, originalTarget, target, source, sourceBinding, futureBody, world]

theorem executed_reverse_source_target {V : Type} (file trash : Nat → V → Prop) (now : Nat)
    (next : Store Slot Node) (resultRead : PhaseImport) (charge : Nat)
    (executed : check .insert reverseSource reverseTarget (program .insert reverseSource reverseTarget) =
      some (next,resultRead,charge)) :
    charge = 6 ∧ resultRead = read reverseTarget ∧
    (futureEventually (fun t => nativeMeaning .all reverseTarget next (world file trash) []
      (futureBody file trash) t) now ↔ originalSource file trash now) := by
  rw [reverse_selected_path] at executed
  simp only [Option.some.injEq, Prod.mk.injEq] at executed
  rcases executed with ⟨hn,hr,hc⟩
  subst next
  refine ⟨hc.symm,hr.symm,?_⟩
  simp [nativeMeaning, quantify, guarded_meaning, originalSource, reverseTarget, source, sourceBinding,
    futureBody, world, and_imp]

def futureRead : RetainedRead :=
  ⟨sourceOrigin,targetOrigin,3313,3464,"RELATION[4:File]","RELATION[4:File]",usePath⟩
def reverseFutureRead : RetainedRead :=
  ⟨targetOrigin,sourceOrigin,326,175,"RELATION[4:File]","RELATION[4:File]",usePath⟩
theorem forward_future_read : retainedReadCheck source target futureRead futureRead = true := by decide
theorem reverse_future_read : retainedReadCheck reverseSource reverseTarget reverseFutureRead reverseFutureRead = true := by decide
def linked (d : Direction) (a b : Frame) (actual selected : RetainedRead) :=
  executeLinked d a a b b (snapshot (beforeStore d a)) (snapshot (afterStore d b))
    (program d a b) [] [] [] [] [] (payment a b) actual selected
theorem forward_linked_payment_and_zero_read :
    (linked .remove source target futureRead futureRead).map (fun r => (snapshot r.1,r.2.1,r.2.2)) =
      some (snapshot (plain target),6,0) := by decide
theorem reverse_linked_payment_and_zero_read :
    (linked .insert reverseSource reverseTarget reverseFutureRead reverseFutureRead).map
      (fun r => (snapshot r.1,r.2.1,r.2.2)) = some (snapshot (guarded reverseTarget),6,0) := by decide
theorem deleted_guard_read_cannot_be_retained : linked .remove source target
    {futureRead with beforeOccurrence := 3264} futureRead = none := by decide
theorem wrong_same_type_occurrence : retainedReadCheck source target
    {futureRead with beforeOccurrence := 3264} futureRead = false := by decide
theorem wrong_read_owner : retainedReadCheck source target
    {futureRead with beforeOwner := targetOrigin} futureRead = false := by decide
theorem wrong_read_phase : retainedReadCheck source target
    {futureRead with path := ownerPath} futureRead = false := by decide
theorem wrong_read_type : retainedReadCheck source target
    {futureRead with beforeType := "BOOL"} futureRead = false := by decide

def altered (ops : List (Operation Slot Node)) : List (Operation Slot Node) :=
  ops.map fun op => {op with charge := 0}
theorem uncharged_guard_erasure : check .remove source target (altered (program .remove source target)) = none := by decide
theorem missing_guard_delete : check .remove source target (program .remove source target).dropLast = none := by decide
theorem missing_guard_insert : check .insert reverseSource reverseTarget (program .insert reverseSource reverseTarget).dropLast = none := by decide
theorem wrong_expected_owner : execute .remove source target target target
    (snapshot (guarded source)) (snapshot (plain target)) (program .remove source target)
    [] [] [] [] [] (payment source target) (read source) = none := by decide
theorem forged_endpoint_and_projection :
    let forged := {source with guardName := "Protected"}
    execute .remove forged source target target (snapshot (guarded forged)) (snapshot (plain target))
      (program .remove forged target) [] [] [] [] [] (payment forged target) (read forged) = none := by decide
theorem wrong_payment : execute .remove source source target target
    (snapshot (guarded source)) (snapshot (plain target)) (program .remove source target)
    [] [] [] [] [] (payment target source) (read source) = none := by decide
theorem missing_payment : execute .remove source source target target
    (snapshot (guarded source)) (snapshot (plain target)) (program .remove source target)
    [] [] [] [] [] [] (read source) = none := by decide
theorem wrong_cardinality :
    let b := {target with binding := {target.binding with multiplicity := 2}}
    check .remove source b (program .remove source b) = none := by decide
theorem wrong_disjointness :
    let b := {target with binding := {target.binding with disjointness := 1}}
    check .remove source b (program .remove source b) = none := by decide
theorem wrong_carrier :
    let b := {target with binding := {target.binding with carrier := "RELATION[5:Other]"}}
    check .remove source b (program .remove source b) = none := by decide
theorem wrong_branch :
    let b := {target with usePath := [.unary .eventually,.binaryRight .until]}
    check .remove source b (program .remove source b) = none := by decide
theorem moved_owner_time :
    let b := {target with ownerPath := [.unary .always]}
    check .remove source b (program .remove source b) = none := by decide

def dependency : Dependency := ⟨⟨2,0,0,3⟩,"RELATION[4:File]"⟩
def repeatedOccurrences : List DependencyOccurrence := [⟨11,0⟩,⟨12,0⟩,⟨13,0⟩]
theorem repeated_owner_occurrences_retained : occurrenceCheck [dependency] repeatedOccurrences repeatedOccurrences = true := by decide
theorem erased_occurrence : occurrenceCheck [dependency] [⟨11,0⟩,⟨13,0⟩] repeatedOccurrences = false := by decide
theorem reordered_occurrences : occurrenceCheck [dependency] [⟨12,0⟩,⟨11,0⟩,⟨13,0⟩] repeatedOccurrences = false := by decide
theorem nonexistent_dependency_owner : occurrenceCheck [dependency] [⟨11,1⟩] [⟨11,1⟩] = false := by decide

/- Neither guard erasure nor relocation is an uncharged semantic law. -/
theorem erasing_guard_not_equivalence :
    ¬ ((∀ v : Bool, (True ∧ False) → v = true) ↔ (∀ v : Bool, True → v = true)) := by
  intro h
  have bad := h.mp (by simp) false trivial
  cases bad
theorem moving_guard_into_future_not_equivalence :
    ¬ ((0 = 1 → futureAlways (fun _ => False) 0) ↔
      futureAlways (fun t => t = 1 → False) 0) := by
  intro h
  have bad := h.mp (by simp) 1 (by decide) rfl
  exact bad

end NaturalPaidGuardEdit
