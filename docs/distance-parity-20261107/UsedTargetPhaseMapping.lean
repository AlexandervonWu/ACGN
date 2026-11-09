import MatrixReplay

namespace UsedTargetPhaseMapping

-- Matrix labels use only target bindings occurring in that phase; the paid
-- declaration map remains global. This is not an alpha-renaming theorem.
def project (used : Nat → Bool) (mapping : Nat → Option Nat) (i : Nat) : Option Nat :=
  (mapping i).filter used

theorem used_target_iff (used : Nat → Bool) (mapping : Nat → Option Nat)
    (i j : Nat) (hj : used j = true) :
    project used mapping i = some j ↔ mapping i = some j := by
  simp [project, hj]

def variableCost (mapping : Nat → Option Nat) (i j : Nat) : Nat :=
  if mapping i = some j then 0 else 1

theorem variable_cost_preserved (used : Nat → Bool) (mapping : Nat → Option Nat)
    (i j : Nat) (hj : used j = true) :
    variableCost (project used mapping) i j = variableCost mapping i j := by
  simp only [variableCost, used_target_iff used mapping i j hj]

inductive Charge where
  | fixed (cost : Nat)
  | bound (source target : Nat)
  deriving DecidableEq, Repr

def charge (mapping : Nat → Option Nat) : Charge → Nat
  | .fixed n => n
  | .bound i j => variableCost mapping i j

def covered (used : Nat → Bool) : Charge → Prop
  | .fixed _ => True
  | .bound _ j => used j = true

theorem selected_path_cost_preserved (used : Nat → Bool) (mapping : Nat → Option Nat)
    (path : List Charge) (coverage : ∀ c ∈ path, covered used c) :
    (path.map (charge (project used mapping))).sum = (path.map (charge mapping)).sum := by
  induction path with
  | nil => rfl
  | cons c cs ih =>
    have hc : charge (project used mapping) c = charge mapping c := by
      cases c with
      | fixed n => rfl
      | bound i j => exact variable_cost_preserved used mapping i j (coverage (.bound i j) (by simp))
    simp only [List.map_cons, List.sum_cons, hc]
    rw [ih (fun c h => coverage c (by simp [h]))]

structure Binding where
  ordinal : Nat
  sourceName : String
  owner : String
  role : String
  carrier : String
  phase : Nat
  dependencies : List Nat
  deriving DecidableEq, Repr

def reverseSource : List Binding :=
  [⟨0,"c","root/predicate[0]/decl[0]@pos","MATRIX","Class",0,[]⟩,
   ⟨1,"p","root/predicate[0]/decl[1]@pos","MATRIX","Person",0,[]⟩]
def reverseTarget : List Binding :=
  [⟨0,"s","root/predicate[0]/decl[0]@pos","MATRIX","Person",0,[]⟩,
   ⟨1,"g","root/predicate[0]/decl[1]@pos","MATRIX","Group",0,[]⟩]
def selectedGlobal : Nat → Option Nat
  | 0 => some 1
  | 1 => some 0
  | _ => none
def reverseUsed (j : Nat) : Bool := j == 0
def forwardUsed (j : Nat) : Bool := j == 0 || j == 1

theorem exact_old_gate_rejects :
    [project reverseUsed selectedGlobal 0, project reverseUsed selectedGlobal 1] ≠
      [selectedGlobal 0, selectedGlobal 1] := by decide
theorem exact_reverse_projection :
    [project reverseUsed selectedGlobal 0, project reverseUsed selectedGlobal 1] =
      [none, some 0] := by decide
theorem exact_forward_projection :
    [project forwardUsed selectedGlobal 0, project forwardUsed selectedGlobal 1] =
      [some 1, some 0] := by decide
theorem actual_person_reference_cost :
    variableCost (project reverseUsed selectedGlobal) 1 0 = 0 := by decide
theorem wrong_used_reference_cost :
    variableCost (project reverseUsed selectedGlobal) 0 0 = 1 := by decide
theorem cannot_drop_used_target :
    variableCost (project (fun _ => false) selectedGlobal) 1 0 ≠
      variableCost selectedGlobal 1 0 := by decide
theorem paid_declaration_not_erased : selectedGlobal 0 = some 1 := rfl
theorem actual_scopes :
    (reverseSource.map Binding.phase = [0,0]) ∧
    (reverseTarget.map Binding.dependencies = [[],[]]) := by decide

#print axioms used_target_iff
#print axioms variable_cost_preserved
#print axioms selected_path_cost_preserved
#print axioms exact_old_gate_rejects
#print axioms exact_reverse_projection
#print axioms exact_forward_projection
#print axioms actual_person_reference_cost
#print axioms wrong_used_reference_cost
#print axioms cannot_drop_used_target
#print axioms paid_declaration_not_erased
#print axioms actual_scopes
end UsedTargetPhaseMapping
