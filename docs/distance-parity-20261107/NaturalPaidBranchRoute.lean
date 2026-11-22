import PaidBranchRoute

namespace NaturalPaidBranchRoute
open PaidBranchRoute PaidImportedBinding TemporalPhaseLocalBinding

/- Finite encoding of source-hash + predicate + declaration-owner coordinates.
   1/2 identify inv12/inv12c, not Java object identities. The checked extractor
   binds the actual source occurrences and owner paths separately. -/
def binding (side kind : Nat) : Binding :=
  ⟨⟨side,1,0,0⟩,"RELATION[4:File]","19:alloy-binder-domain[1:4:File]{0:}",[],kind,1,0⟩
def sourceBinding := binding 1 0
def targetBinding := binding 2 1
def memberBody (negated : Bool) : Body :=
  [("TEMPORALROOT","BOOL",[1]),(if negated then "NOT_IN" else "IN","BOOL",[2,3]),
   ("VARIABLE","RELATION[4:File]",[]),("GLOBALBINDING:alloy/signature/Trash","RELATION[4:File]",[])]
def leftBranch : Branch :=
  ⟨124,sourceBinding.origin,"RELATION[4:File]",2,[],memberBody false,[124,125,126,127],126⟩
def rightBranch : Branch :=
  ⟨159,sourceBinding.origin,"RELATION[4:File]",3,[],memberBody true,[159,160,161,162],161⟩
def targetBranch : Branch :=
  ⟨310,targetBinding.origin,"RELATION[4:File]",2,[],memberBody false,[310,311,312,313],312⟩
def source : State :=
  ⟨sourceBinding,.always,.binary .until,90,2,[leftBranch,rightBranch]⟩
def target : State :=
  ⟨targetBinding,.eventually,.unary .always,276,1,[targetBranch]⟩
def forward : Plan := ⟨source,target,leftBranch,targetBranch,rightBranch,false,false⟩
def reverse : Plan := ⟨target,source,targetBranch,leftBranch,rightBranch,false,true⟩

def selected : List (Nat × Nat) := [(1,1),(2,2),(3,3)]
def oldSourceRoute : List RouteStep := [⟨3,0,0,1⟩,⟨2,0,0,1⟩,⟨1,0,-1,2⟩]
def oldTargetRoute : List RouteStep := [⟨3,0,0,1⟩,⟨2,0,0,1⟩,⟨1,0,-1,1⟩]

theorem old_gate_rejects_forward : oldRouteGate selected oldSourceRoute oldTargetRoute = false := by decide
theorem old_gate_rejects_reverse : oldRouteGate selected oldTargetRoute oldSourceRoute = false := by decide
theorem actual_forward_shape : shapeCheck forward = true := by decide
theorem actual_reverse_shape : shapeCheck reverse = true := by decide
theorem actual_forward_run : run source (program forward) = some target := by decide
theorem actual_reverse_run : run target (program reverse) = some source := by decide
theorem actual_forward_acceptance : execute forward forward (program forward) = some (target,8) := by decide
theorem actual_reverse_acceptance : execute reverse reverse (program reverse) = some (source,8) := by decide

def sourceFormula {File : Type} (carrier trash : Nat → File → Prop) (t : Nat) : Prop :=
  futureAlways (fun now => ∀ f, carrier now f →
    futureUntil (fun later => trash later f) (fun later => ¬ trash later f) now) t
def targetFormula {File : Type} (carrier trash : Nat → File → Prop) (t : Nat) : Prop :=
  futureEventually (fun now => ∃ f, carrier now f ∧
    futureAlways (fun later => trash later f) now) t
def atomMeaning {File : Type} (trash : Nat → File → Prop) (body : Body) (f : File) (t : Nat) : Prop :=
  if body = memberBody false then trash t f else if body = memberBody true then ¬ trash t f else False

theorem source_semantics {File : Type} (carrier trash : Nat → File → Prop) (t : Nat) :
    meaning carrier (atomMeaning trash) source t = sourceFormula carrier trash t := rfl
theorem target_semantics {File : Type} (carrier trash : Nat → File → Prop) (t : Nat) :
    meaning carrier (atomMeaning trash) target t = targetFormula carrier trash t := rfl

/- The target is derived from the executed selected program. This is a paid
   repair, not an assertion that the original and repaired predicates agree. -/
theorem actual_forward_path_sound {File : Type} (carrier trash : Nat → File → Prop)
    (t : Nat) :
    (execute forward forward (program forward)).map
        (fun (out, cost) => (meaning carrier (atomMeaning trash) out t, cost)) =
      some (targetFormula carrier trash t,8) := by
  rw [actual_forward_acceptance]
  rfl

theorem actual_reverse_path_sound {File : Type} (carrier trash : Nat → File → Prop)
    (t : Nat) :
    (execute reverse reverse (program reverse)).map
        (fun (out, cost) => (meaning carrier (atomMeaning trash) out t, cost)) =
      some (sourceFormula carrier trash t,8) := by
  rw [actual_reverse_acceptance]
  rfl

theorem actual_typed_retained_read (Value : String → Type)
    (value : Value source.binding.carrier)
    (before : Nat → Value source.binding.carrier)
    (after : Nat → Value target.binding.carrier) :
    shadowBinder before leftBranch.owner.coordinate value leftBranch.owner.coordinate =
      shadowBinder after targetBranch.owner.coordinate value targetBranch.owner.coordinate := by
  simp [shadowBinder]

theorem source_and_target_not_equated :
    ¬ sourceFormula (fun (_ : Nat) (_ : Bool) => True) (fun _ _ => True) 0 ∧
      targetFormula (fun (_ : Nat) (_ : Bool) => True) (fun _ _ => True) 0 := by
  simp [sourceFormula,targetFormula,futureAlways,futureUntil,futureEventually]

theorem wrong_branch_rejected :
    execute forward {forward with right := true} (program forward) = none := by decide
theorem wrong_owner_rejected :
    shapeCheck {forward with keptSource := {leftBranch with owner := targetBinding.origin}} = false := by decide
theorem wrong_type_rejected :
    shapeCheck {forward with keptSource := {leftBranch with type := "Int"}} = false := by decide
theorem wrong_phase_rejected :
    shapeCheck {forward with keptSource := {leftBranch with phase := 1}} = false := by decide
theorem wrong_dependency_rejected :
    shapeCheck {forward with keptSource := {leftBranch with dependencies := [7]}} = false := by decide
theorem foreign_same_metadata_occurrence_rejected :
    execute forward {forward with keptSource := {leftBranch with occurrence := 999}}
      (program forward) = none := by decide
theorem missing_deleted_branch_payment_rejected :
    execute forward forward ((program forward).take 5) = none := by decide
theorem reordered_payment_rejected :
    execute forward forward ((program forward).reverse) = none := by decide
theorem wrong_reference_rejected :
    execute forward {forward with source := {source with referenceOccurrence := 999}}
      (program forward) = none := by decide
theorem missing_declaration_payment_rejected :
    execute forward forward ((program forward).eraseIdx 2) = none := by decide
theorem discarded_read_is_not_retained : rightBranch.readOccurrence ≠ leftBranch.readOccurrence := by decide
theorem stale_payload_rejected :
    apply source (.retain 0 rightBranch targetBranch) = none := by decide
theorem overlapping_branch_occurrences_rejected :
    shapeCheck {forward with discarded := leftBranch} = false := by decide

def coherentSourceChange (b : Branch) : Plan :=
  {forward with source := {source with branches := [b,rightBranch]}, keptSource := b}
theorem coherently_forged_owner_rejected :
    shapeCheck (coherentSourceChange {leftBranch with owner := targetBinding.origin}) = false := by decide
theorem coherently_forged_type_rejected :
    shapeCheck (coherentSourceChange {leftBranch with type := "Int"}) = false := by decide
theorem coherently_forged_phase_rejected :
    shapeCheck (coherentSourceChange {leftBranch with phase := 1}) = false := by decide
theorem coherently_forged_dependency_rejected :
    shapeCheck (coherentSourceChange {leftBranch with dependencies := [7]}) = false := by decide
theorem changed_retained_expression_rejected :
    shapeCheck (coherentSourceChange {leftBranch with body := memberBody true}) = false := by decide
theorem incomplete_deleted_nodes_rejected :
    let bad := {rightBranch with nodes := [159,160,161]}
    shapeCheck {forward with source := {source with branches := [leftBranch,bad]}, discarded := bad} = false := by decide

/- Derived structural control, explicitly not another natural-corpus witness. -/
def keepRight : Plan :=
  { forward with source := {source with branches := [rightBranch,leftBranch]}, right := true }
theorem derived_right_branch_control :
    execute keepRight keepRight (program keepRight) = some (target,8) := by decide

end NaturalPaidBranchRoute
