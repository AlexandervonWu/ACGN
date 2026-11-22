import LocalDeclarationProjection
import PaidDeclarationAlignment
import DisjointPaidDeclarationAlignment
import RetainedDifferenceDomain

namespace RetainedComprehensionAdmission

universe u
variable {A : Type u}

-- Exact old eligibility conjuncts; these are not semantic rejection rules.
def oldLocalKind (opcode : String) : Bool :=
  opcode == "FORALL" || opcode == "EXISTS" || opcode == "ONE" || opcode == "LONE"

def oldDisjointLocalGate (disjoint localCount : Nat) : Bool :=
  !(disjoint > 0 && localCount > 0)

def oldGroupedLocalGate (disjoint localCount : Nat) : Bool :=
  !(localCount > 0 && disjoint != 0)

open LocalDeclarationProjection

def retainedMeaning (domain : Group → (Slot → A) → A → Prop)
    (body : (Slot → A) → Prop) (groups : List View) (env : Slot → A) : Prop :=
  comprehension domain body groups env

theorem checked_original_groups_preserve_meaning
    (original selected : List View) (checked : exactGroups original selected = true)
    (domain : Group → (Slot → A) → A → Prop) (body : (Slot → A) → Prop)
    (env : Slot → A) :
    retainedMeaning domain body original env ↔ retainedMeaning domain body selected env := by
  have groups : original.map View.group = selected.map View.group := of_decide_eq_true checked
  have meaning (vs : List View) :
      (∀ v ∈ vs, permits domain env v) ↔
        (∀ g ∈ vs.map View.group, ∀ s ∈ g.slots, domain g env (env s)) := by
    simp [permits]
  unfold retainedMeaning comprehension
  rw [meaning, meaning, groups]

theorem checked_original_groups_preserve_columns
    (original selected : List View) (checked : exactGroups original selected = true) :
    original.flatMap (fun v => v.group.slots) = selected.flatMap (fun v => v.group.slots) := by
  have groups : original.map View.group = selected.map View.group := of_decide_eq_true checked
  have h := congrArg (fun gs : List Group => gs.flatMap Group.slots) groups
  simpa [List.flatMap_map, Function.comp_def] using h

-- The concrete graph comprehension denotes an ordered binary relation. It
-- contains no outer bound occurrence; moving an outer paid link cannot capture
-- either column, even when the source names coincide.
def graphComprehension (nodes : A → Prop) (adj : A → A → Prop) (x y : A) : Prop :=
  nodes x ∧ nodes y ∧ (adj y x ∨ adj x y)

theorem graph_comprehension_ignores_outer (nodes : A → Prop) (adj : A → A → Prop)
    (outerBefore outerAfter : E) :
    (fun (_ : E) => graphComprehension nodes adj) outerBefore =
      (fun (_ : E) => graphComprehension nodes adj) outerAfter := rfl

theorem contextual_relation_congruence (a b : A → A → Prop)
    (same : ∀ x y, a x y ↔ b x y) (context : (A → A → Prop) → Prop) :
    context a ↔ context b := by
  have eq : a = b := funext fun x => funext fun y => propext (same x y)
  rw [eq]

structure Address where
  predicate : String
  owner : String
  phase : Nat
  ordinal : Nat
  type : String
  role : String
  dependencies : List Nat
  deriving DecidableEq

structure ReadOccurrence where
  binding : Address
  occurrence : Nat
  branch : String
  deriving DecidableEq

-- A matrix read is licensed by an executed declaration path, not a proposed
-- map or a copied distance. The before/after occurrences are the selected ones.
def license (source target : List PaidDeclarationAlignment.Atom)
    (edits : List PaidDeclarationAlignment.Edit) (expectedCost : Nat)
    (sourceKey targetKey : Nat) (addresses : Nat → Option Address)
    (before after actualBefore actualAfter : ReadOccurrence) : Bool :=
  match PaidDeclarationAlignment.replay source edits with
  | none => false
  | some (actualTarget, cost, links) => decide (
      actualTarget = target ∧ cost = expectedCost ∧ (sourceKey,targetKey) ∈ links ∧
      addresses sourceKey = some before.binding ∧ addresses targetKey = some after.binding ∧
      before = actualBefore ∧ after = actualAfter ∧
      before.binding.type = after.binding.type ∧
      before.binding.phase = after.binding.phase ∧
      before.binding.role = after.binding.role ∧
      before.binding.dependencies = after.binding.dependencies)

theorem license_requires_executed_payment
    (source target : List PaidDeclarationAlignment.Atom) (edits : List PaidDeclarationAlignment.Edit)
    (cost sourceKey targetKey : Nat) (addresses : Nat → Option Address)
    (before after actualBefore actualAfter : ReadOccurrence)
    (checked : license source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter = true) :
    ∃ links, PaidDeclarationAlignment.replay source edits = some (target,cost,links) ∧
      (sourceKey,targetKey) ∈ links ∧ before = actualBefore ∧ after = actualAfter ∧
      before.binding.type = after.binding.type := by
  cases h : PaidDeclarationAlignment.replay source edits with
  | none => simp [license, h] at checked
  | some result =>
    rcases result with ⟨actualTarget,actualCost,links⟩
    have valid := of_decide_eq_true (show decide (
      actualTarget = target ∧ actualCost = cost ∧ (sourceKey,targetKey) ∈ links ∧
      addresses sourceKey = some before.binding ∧ addresses targetKey = some after.binding ∧
      before = actualBefore ∧ after = actualAfter ∧ before.binding.type = after.binding.type ∧
      before.binding.phase = after.binding.phase ∧ before.binding.role = after.binding.role ∧
      before.binding.dependencies = after.binding.dependencies) = true from by
        simpa only [license, h] using checked)
    rcases valid with ⟨htarget,hc,hl,_,_,hb,ha,ht,_⟩
    exact ⟨links,by simp only [htarget,hc],hl,hb,ha,ht⟩

def transported (before after : Address) (env : Address → Option A) : Address → Option A :=
  fun address => if address = after then env before else none

theorem licensed_selected_read (source target : List PaidDeclarationAlignment.Atom)
    (edits : List PaidDeclarationAlignment.Edit) (cost sourceKey targetKey : Nat)
    (addresses : Nat → Option Address) (before after actualBefore actualAfter : ReadOccurrence)
    (checked : license source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter = true)
    (env : Address → Option A) :
    transported before.binding after.binding env actualAfter.binding = env actualBefore.binding := by
  obtain ⟨_,_,_,hb,ha,_⟩ := license_requires_executed_payment _ _ _ _ _ _ _ _ _ _ _ checked
  rw [← hb, ← ha]
  simp [transported]

def extendLocal (locals : List Address) (values outer : Address → Option A) : Address → Option A :=
  fun address => if address ∈ locals then values address else outer address

def noCapture (before after : ReadOccurrence) (sourceLocals targetLocals : List Address) : Bool :=
  decide (before.binding ∉ sourceLocals ∧ after.binding ∉ targetLocals)

theorem licensed_read_under_retained_scope (source target : List PaidDeclarationAlignment.Atom)
    (edits : List PaidDeclarationAlignment.Edit) (cost sourceKey targetKey : Nat)
    (addresses : Nat → Option Address) (before after actualBefore actualAfter : ReadOccurrence)
    (checked : license source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter = true)
    (sourceLocals targetLocals : List Address)
    (captureChecked : noCapture actualBefore actualAfter sourceLocals targetLocals = true)
    (localBefore localAfter env : Address → Option A) :
    extendLocal targetLocals localAfter (transported before.binding after.binding env) actualAfter.binding =
      extendLocal sourceLocals localBefore env actualBefore.binding := by
  have safe : actualBefore.binding ∉ sourceLocals ∧ actualAfter.binding ∉ targetLocals :=
    of_decide_eq_true captureChecked
  simpa only [extendLocal, ite_eq_right safe.1, ite_eq_right safe.2] using
    licensed_selected_read source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter checked env

def relationAt (env : Address → Option (A → Prop)) (address : Address) : A → Prop :=
  fun value => match env address with
    | some relation => relation value
    | none => False

-- Reuse the existing retained-domain semantics. The dependency equivalence is
-- derived from the executed paid path, not supplied as a semantic assumption.
theorem licensed_difference_domain {A : Type} (source target : List PaidDeclarationAlignment.Atom)
    (edits : List PaidDeclarationAlignment.Edit) (cost sourceKey targetKey : Nat)
    (addresses : Nat → Option Address) (before after actualBefore actualAfter : ReadOccurrence)
    (checked : license source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter = true)
    (env : Address → Option (A → Prop)) (carrier : A → Prop) (value : A) :
    RetainedDifferenceDomain.difference carrier
      (fun _ => relationAt env actualBefore.binding) sourceKey value ↔
    RetainedDifferenceDomain.difference carrier
      (fun _ => relationAt (transported before.binding after.binding env) actualAfter.binding) targetKey value := by
  have read := licensed_selected_read source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter checked env
  apply RetainedDifferenceDomain.domain_transport
  intro x
  simp only [relationAt, read]

theorem licensed_retained_body (source target : List PaidDeclarationAlignment.Atom)
    (edits : List PaidDeclarationAlignment.Edit) (cost sourceKey targetKey : Nat)
    (addresses : Nat → Option Address) (before after actualBefore actualAfter : ReadOccurrence)
    (checked : license source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter = true)
    (sourceLocals targetLocals : List Address)
    (captureChecked : noCapture actualBefore actualAfter sourceLocals targetLocals = true)
    (localBefore localAfter env : Address → Option A) (context : Option A → Prop) :
    context (extendLocal targetLocals localAfter (transported before.binding after.binding env) actualAfter.binding) ↔
      context (extendLocal sourceLocals localBefore env actualBefore.binding) := by
  rw [licensed_read_under_retained_scope source target edits cost sourceKey targetKey addresses before after actualBefore actualAfter checked sourceLocals targetLocals captureChecked localBefore localAfter env]

end RetainedComprehensionAdmission
