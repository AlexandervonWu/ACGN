import Lean

namespace GraphRepair

-- Binary applications encode finite labelled, flexible-arity terms.
inductive Term where
  | atom : Nat → Term
  | app : Term → Term → Term
  deriving DecidableEq, Repr

inductive Program where
  | copy : Nat → Program
  | atom : Nat → Program
  | app : Program → Program → Program
  deriving Repr

def replay (source : List Term) : Program → Option Term
  | .copy n => source[n]?
  | .atom a => some (.atom a)
  | .app p q => do
      let l ← replay source p
      let r ← replay source q
      pure (.app l r)

def compile (lookup : Term → Option Nat) (target : Term) : Program :=
  match lookup target with
  | some i => .copy i
  | none => match target with
    | .atom a => .atom a
    | .app l r => .app (compile lookup l) (compile lookup r)

theorem complete_path (source : List Term) (lookup : Term → Option Nat)
    (sound : ∀ t i, lookup t = some i → source[i]? = some t) (target : Term) :
    replay source (compile lookup target) = some target := by
  induction target with
  | atom a =>
      cases h : lookup (.atom a) with
      | none => simp [compile, h, replay]
      | some i => simpa [compile, h, replay] using sound (.atom a) i h
  | app l r hl hr =>
      cases h : lookup (.app l r) with
      | none => simp [compile, h, replay, hl, hr]
      | some i => simpa [compile, h, replay] using sound (.app l r) i h

theorem no_menu_required (source : List Term) (target : Term) :
    ∃ p, replay source p = some target := by
  refine ⟨compile (fun _ => none) target, ?_⟩
  apply complete_path
  intro t i h
  cases h

theorem copy_requires_existing_node (source : List Term) (n : Nat) :
    replay source (.copy n) = source[n]? := rfl

theorem replay_deterministic (source : List Term) (p : Program) (a b : Term)
    (ha : replay source p = some a) (hb : replay source p = some b) : a = b := by
  exact Option.some.inj (ha.symm.trans hb)

theorem target_not_in_key {K V : Type} (key : K) (a b : V) :
    (key, a).1 = (key, b).1 := rfl

def supervisedPositions (keyLength targetLength : Nat) : List Nat :=
  (List.range targetLength).map (keyLength + ·)

theorem prefix_not_supervised (k n i : Nat)
    (h : i ∈ supervisedPositions k n) : k ≤ i := by
  simp only [supervisedPositions, List.mem_map] at h
  obtain ⟨j, _, rfl⟩ := h
  omega

theorem target_length_preserved (k n : Nat) :
    (supervisedPositions k n).length = n := by simp [supervisedPositions]

-- No proposition about behavioral repair follows just from patch execution.
def semanticSuccess (reparsed feasible noExtra noMissing : Bool) : Bool :=
  reparsed && feasible && noExtra && noMissing

theorem semantic_success_gate (p f e m : Bool)
    (h : semanticSuccess p f e m = true) :
    p = true ∧ f = true ∧ e = true ∧ m = true := by
  cases p <;> cases f <;> cases e <;> cases m <;> simp_all [semanticSuccess]

end GraphRepair
