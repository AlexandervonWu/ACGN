import Focused225ConsumersWitnesses
import ScopedCallCorrespondence

namespace Focused225CallViews
open ScopedCallCorrespondence

inductive Shape where
  | variable : Slot → Shape
  | node : Head → Shape → Shape
  | nil : Shape
  | cons : Shape → Shape → Shape
  deriving DecidableEq

mutual
def decode : Shape → Option Term
  | .variable slot => some (.variable slot)
  | .node head args => do pure (.node head (← decodeArgs args))
  | _ => none
def decodeArgs : Shape → Option (List Term)
  | .nil => some []
  | .cons term rest => do pure ((← decode term) :: (← decodeArgs rest))
  | _ => none
end

abbrev SlotMap := List (String × String)
abbrev Scope := List (String × Slot)

def lookup {V : Type} (entries : List (String × V)) (key : String) : Option V :=
  match entries.filter (fun entry => decide (entry.1 = key)) with
  | [entry] => some entry.2
  | _ => none

def compose (parent child : SlotMap) : Option SlotMap :=
  if (child.map Prod.fst).Nodup then
    child.mapM (fun entry => do
      let target ← lookup parent entry.2
      pure (entry.1, target))
  else none

structure Step where
  localMap : SlotMap
  effective : SlotMap
  deriving DecidableEq

def step (parent : SlotMap) (edge : Step) : Option SlotMap := do
  let computed ← compose parent edge.localMap
  if computed = edge.effective then some computed else none

def ancestors (initial : SlotMap) : List Step → Option SlotMap
  | [] => some initial
  | edge :: rest => do ancestors (← step initial edge) rest

inductive Raw where
  | variable (head : Head) (alpha : String) (edge : Step)
  | node (head : Head) (edge : Step) (children : Raw)
  | nil
  | cons (head tail : Raw)

def shapeList (terms : List Shape) : Shape := terms.foldr Shape.cons .nil

/- Ordered children use an explicit list spine so resolution is structurally
   recursive in the kernel, with no fuel or arbitrary depth limit. -/
mutual
def resolve (scope : Scope) (parent : SlotMap) : Raw → Option Shape
  | .variable head alpha edge => do
      let effective ← step parent edge
      let name ← lookup effective alpha
      let slot ← lookup scope name
      if slot.type = head.type then some (.node head (.cons (.variable slot) .nil)) else none
  | .node head edge children => do
      let effective ← step parent edge
      let args ← resolveArgs scope effective children
      pure (.node head (shapeList args))
  | _ => none
def resolveArgs (scope : Scope) (parent : SlotMap) : Raw → Option (List Shape)
  | .nil => some []
  | .cons term rest => do pure ((← resolve scope parent term) :: (← resolveArgs scope parent rest))
  | _ => none
end

structure SourceKey where
  sourceHash : String
  predicate : String
  lineage : Nat
  occurrence : Nat
  owner : String
  phase : Nat
  branch : List Nat
  deriving DecidableEq

structure View where
  key : SourceKey
  scope : Scope
  initial : SlotMap
  ancestry : List Step
  call : Raw

def resolved (view : View) : Option Shape := do
  let parent ← ancestors view.initial view.ancestry
  resolve view.scope parent view.call

def sourceAt (registry : List View) (key : SourceKey) : Option View :=
  match registry.filter (fun view => decide (view.key = key)) with
  | [view] => some view
  | _ => none

theorem sourceAt_single (original view : View) (same : original.key = view.key) :
    sourceAt [original] view.key = some original := by simp [sourceAt,same]

/- The registry and key are issued from the parser-owned opaque anchor.
   Reconstructing a key from a callee name is not an allowed producer. -/
def transport (registry : List View) (view : View) : Option Shape := do
  let original ← sourceAt registry view.key
  let source ← resolved original
  let target ← resolved view
  if source = target then some target else none

theorem checked_transport_exact (registry : List View) (view : View) (term : Shape)
    (checked : transport registry view = some term) :
    ∃ original, sourceAt registry view.key = some original ∧
      resolved original = some term ∧ resolved view = some term := by
  unfold transport at checked
  cases hs : sourceAt registry view.key with
  | none => simp [hs] at checked
  | some original =>
    cases ho : resolved original with
    | none => simp [hs,ho] at checked
    | some source =>
      cases ht : resolved view with
      | none => simp [hs,ht] at checked
      | some target =>
        by_cases same : source = target
        · simp [hs,ho,ht,same] at checked
          cases checked
          exact ⟨original,rfl,by simpa [same] using ho,rfl⟩
        · simp [hs,ho,ht,same] at checked

theorem checked_transport_evaluation {V : Type} (environment : Slot → V)
    (operation : Head → List V → V) (registry : List View) (view : View) (term : Shape)
    (checked : transport registry view = some term) :
    ∃ original, sourceAt registry view.key = some original ∧
      ((resolved original).bind decode).map (eval environment operation) =
      ((resolved view).bind decode).map (eval environment operation) := by
  obtain ⟨original,found,source,target⟩ := checked_transport_exact registry view term checked
  exact ⟨original,found,by rw [source,target]⟩

theorem absent_source_rejected (registry : List View) (view : View)
    (absent : sourceAt registry view.key = none) : transport registry view = none := by
  simp [transport,absent]

theorem wrong_argument_rejected (registry : List View) (view original : View)
    (source target : Shape) (found : sourceAt registry view.key = some original)
    (hs : resolved original = some source) (ht : resolved view = some target)
    (different : source ≠ target) : transport registry view = none := by
  simp [transport,found,hs,ht,different]

theorem exact_view_accepts (registry : List View) (original view : View) (term : Shape)
    (found : sourceAt registry view.key = some original)
    (hs : resolved original = some term) (ht : resolved view = some term) :
    transport registry view = some term := by
  simp [transport,found,hs,ht]

end Focused225CallViews
