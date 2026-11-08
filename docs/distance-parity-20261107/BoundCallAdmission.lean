import Std

/- Opaque declared calls with ordered, binder-free argument expressions. The
   source call and each argument keep their type/module/occurrence authority.
   This is a model of correspondence, not a proof of Java or of paid edits as
   semantic equivalences. No function body is unfolded. -/
namespace BoundCallAdmission

structure Slot where
  owner : Nat
  index : Nat
  deriving DecidableEq

inductive Arg where
  | bound : Slot → Arg
  | literal : Nat → Arg
  | join : Arg → Arg → Arg
  | difference : Arg → Arg → Arg

def rename (r : Slot → Slot) : Arg → Arg
  | .bound s => .bound (r s)
  | .literal n => .literal n
  | .join a b => .join (rename r a) (rename r b)
  | .difference a b => .difference (rename r a) (rename r b)

def eval {V : Type} (env : Slot → V) (literal : Nat → V)
    (join difference : V → V → V) : Arg → V
  | .bound s => env s
  | .literal n => literal n
  | .join a b => join (eval env literal join difference a) (eval env literal join difference b)
  | .difference a b => difference (eval env literal join difference a) (eval env literal join difference b)

theorem argument_transport {V : Type} (old new : Slot → V) (r : Slot → Slot)
    (literal : Nat → V) (join difference : V → V → V)
    (links : ∀ s, new (r s) = old s) (a : Arg) :
    eval new literal join difference (rename r a) = eval old literal join difference a := by
  induction a with
  | bound s => exact links s
  | literal n => rfl
  | join a b ha hb => simp only [rename, eval, ha, hb]
  | difference a b ha hb => simp only [rename, eval, ha, hb]

structure Head where
  module : Nat
  callee : Nat
  resultType : Nat
  argumentTypes : List Nat
  deriving DecidableEq

theorem ordered_opaque_call_transport {V : Type} (invoke : Head → List V → V)
    (head : Head) (old new : Slot → V) (r : Slot → Slot)
    (literal : Nat → V) (join difference : V → V → V)
    (links : ∀ s, new (r s) = old s) (args : List Arg) :
    invoke head ((args.map (rename r)).map (eval new literal join difference)) =
      invoke head (args.map (eval old literal join difference)) := by
  congr 1
  induction args with
  | nil => rfl
  | cons a rest ih => simp only [List.map_cons, argument_transport old new r literal join difference links, ih]

theorem same_head_preserves_types (actual original : Head) (h : actual = original) :
    actual.resultType = original.resultType ∧ actual.argumentTypes = original.argumentTypes := by
  cases h; exact ⟨rfl,rfl⟩

theorem foreign_callee_rejected (actual original : Head) (h : actual.callee ≠ original.callee) :
    actual ≠ original := by intro eq; exact h (congrArg Head.callee eq)

theorem ordered_arguments_not_a_set :
    ([1,2] : List Nat) ≠ [2,1] ∧ ([1,1] : List Nat) ≠ [1] := by decide

theorem owner_not_only_slot (owner other index : Nat) (h : owner ≠ other) :
    (Slot.mk owner index) ≠ (Slot.mk other index) := by
  intro eq; exact h (congrArg Slot.owner eq)

#print axioms argument_transport
#print axioms ordered_opaque_call_transport
#print axioms same_head_preserves_types
#print axioms foreign_callee_rejected
#print axioms ordered_arguments_not_a_set
#print axioms owner_not_only_slot
end BoundCallAdmission
