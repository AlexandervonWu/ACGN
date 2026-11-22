import Std

namespace ACGN.Eighth.P611

def schema := "acgncert-schema-v10"

structure Root where
  tag : String
  scalars : List String
  children : Nat
  deriving DecidableEq, Repr

inductive Fault | envelope | badShape | unsupported | usePair
  deriving DecidableEq, Repr

/-- A decoder may fail before the root guard. An arbitrary decoded tree reaches the
same guard as a directly supplied structural DTO. -/
abbrev Input := Except Fault Root

def schemaGate (r : Root) : Except Fault Root :=
  if r.tag != "acgncert-bundle" || r.children != 12 then .error .badShape
  else match r.scalars with
  | [v] => if v = schema then .ok r else .error .unsupported
  | _ => .error .badShape

def openInput (input : Input) : Except Fault Root := do
  let root ← input
  schemaGate root

theorem exact_scalar_necessary (r admitted : Root) (ok : schemaGate r = .ok admitted) :
    r = admitted ∧ admitted.scalars = [schema] := by
  unfold schemaGate at ok
  split at ok
  · contradiction
  · split at ok
    next v eq =>
      split at ok
      next hv => cases ok; exact ⟨rfl, by simp_all⟩
      next => contradiction
    next => contradiction

theorem every_other_string_rejects (v : String) (different : v ≠ schema) :
    schemaGate ⟨"acgncert-bundle", [v], 12⟩ = .error .unsupported := by
  simp [schemaGate, different]

theorem post_decode_admission (input : Input) (r : Root) (ok : openInput input = .ok r) :
    input = .ok r ∧ r.scalars = [schema] := by
  cases input with
  | error => contradiction
  | ok decoded =>
    obtain ⟨rfl, scalar⟩ := exact_scalar_necessary decoded r ok
    exact ⟨rfl, scalar⟩

inductive Request
  | single (input : Input)
  | pair (left right : Input)
  | inspect (input : Input)
  | metadata (input : Input)
  | invalidSinglePair

/-- Records the inputs that reached schema admission, before feature- or policy-dependent work. -/
def admittedRoots : Request → Except Fault (List Root)
  | .single a | .inspect a | .metadata a => do return [← openInput a]
  | .pair a b => do return [← openInput a, ← openInput b]
  | .invalidSinglePair => .error .usePair

theorem single_route (a : Input) (r : List Root)
    (ok : (do return [← openInput a] : Except Fault (List Root)) = .ok r) :
    ∀ item ∈ r, item.scalars = [schema] := by
  cases h : openInput a with
  | error e => simp [h, Bind.bind, Except.bind] at ok
  | ok root =>
    simp [h, Bind.bind, Except.bind, Pure.pure, Except.pure] at ok
    subst r
    simpa using (post_decode_admission a root h).2

theorem pair_route (a b : Input) (r : List Root)
    (ok : admittedRoots (.pair a b) = .ok r) :
    ∃ l h, a = .ok l ∧ b = .ok h ∧ r = [l,h] ∧ l.scalars = [schema] ∧ h.scalars = [schema] := by
  unfold admittedRoots at ok
  cases ha : openInput a with
  | error e => simp [ha, Bind.bind, Except.bind] at ok
  | ok l =>
    cases hb : openInput b with
    | error e => simp [ha, hb, Bind.bind, Except.bind] at ok
    | ok h =>
      simp [ha, hb, Bind.bind, Except.bind, Pure.pure, Except.pure] at ok
      obtain ⟨al, ls⟩ := post_decode_admission a l ha
      obtain ⟨bh, hs⟩ := post_decode_admission b h hb
      exact ⟨l,h,al,bh,ok.symm,ls,hs⟩

theorem all_admitted_roots (request : Request) (r : List Root) (ok : admittedRoots request = .ok r) :
    ∀ item ∈ r, item.scalars = [schema] := by
  cases request with
  | single a | inspect a | metadata a => exact single_route a r ok
  | invalidSinglePair => contradiction
  | pair a b =>
    obtain ⟨l,h,_,_,rfl,ls,hs⟩ := pair_route a b r ok
    simp [ls, hs]

#print axioms exact_scalar_necessary
#print axioms every_other_string_rejects
#print axioms post_decode_admission
#print axioms single_route
#print axioms pair_route
#print axioms all_admitted_roots

end ACGN.Eighth.P611
