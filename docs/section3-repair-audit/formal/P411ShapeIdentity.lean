import Std

namespace ACGN.Eighth.P411

abbrev Bytes := List Nat
abbrev Shape := Bytes × Bytes

def tag : Bytes := "producer-shape-id".toUTF8.data.toList.map UInt8.toNat

def u32 (n : Nat) : Bytes :=
  [n / 16777216 % 256, n / 65536 % 256, n / 256 % 256, n % 256]

def read32 : Bytes → Option (Nat × Bytes)
  | a :: b :: c :: d :: tail =>
    if a < 128 ∧ b < 256 ∧ c < 256 ∧ d < 256 then
      some (a*16777216 + b*65536 + c*256 + d, tail)
    else none
  | _ => none

def frame (b : Bytes) := u32 b.length ++ b

def readFrame (input : Bytes) : Option (Bytes × Bytes) := do
  let (n, rest) ← read32 input
  if n ≤ rest.length then some (rest.take n, rest.drop n) else none

/-- Exact raw Wire.leaf layout: tag, scalar count, owner, term ID, child count. -/
def shapeBytes (x : Shape) : Bytes :=
  frame tag ++ u32 2 ++ frame x.1 ++ frame x.2 ++ u32 0

def decodeShape (input : Bytes) : Option Shape := do
  let (t, a) ← readFrame input
  if t ≠ tag then none else
    let (ns,b) ← read32 a
    if ns ≠ 2 then none else
      let (owner,c) ← readFrame b
      let (term,d) ← readFrame c
      let (nc,tail) ← read32 d
      if nc = 0 ∧ tail = [] then some (owner,term) else none

def Fits (x : Shape) := x.1.length < 2147483648 ∧ x.2.length < 2147483648

theorem read32_u32 (n : Nat) (small : n < 2147483648) (tail : Bytes) :
    read32 (u32 n ++ tail) = some (n,tail) := by
  simp only [u32, List.cons_append, List.nil_append, read32]
  split <;> simp_all <;> omega

theorem readFrame_frame (xs tail : Bytes) (small : xs.length < 2147483648) :
    readFrame (frame xs ++ tail) = some (xs,tail) := by
  simp [readFrame, frame, List.append_assoc, read32_u32 _ small]

theorem shape_roundtrip (x : Shape) (fits : Fits x) : decodeShape (shapeBytes x) = some x := by
  rcases x with ⟨owner,term⟩
  rcases fits with ⟨ownerFits, termFits⟩
  have tagFits : tag.length < 2147483648 := by decide
  simp [decodeShape, shapeBytes, List.append_assoc, readFrame_frame _ _ tagFits,
    read32_u32 2 (by decide), readFrame_frame _ _ ownerFits, readFrame_frame _ _ termFits]
  rfl

theorem shape_frame_injective {x y : Shape} (hx : Fits x) (hy : Fits y)
    (same : shapeBytes x = shapeBytes y) : x = y := by
  have h := congrArg decodeShape same
  simpa [shape_roundtrip x hx, shape_roundtrip y hy] using h

/-- A functional presentation of the two implementation-local maps. Each accepted
entry names the complete pair; no constraint is placed on the digest function. -/
abbrev Registry (D : Type) := D → Option Shape

def observe {D : Type} [DecidableEq D] (hash : Bytes → D) (s : Registry D) (x : Shape) :
    Option (Registry D) :=
  let id := hash (shapeBytes x)
  match s id with
  | none => some (fun j => if j = id then some x else s j)
  | some old => if old = x then some s else none

theorem accepted_entry {D} [DecidableEq D] {hash : Bytes → D} {s t : Registry D} {x}
    (accepted : observe hash s x = some t) : t (hash (shapeBytes x)) = some x := by
  simp only [observe] at accepted
  split at accepted
  · cases accepted; simp
  · split at accepted <;> simp_all

theorem accepted_preserves {D} [DecidableEq D] {hash : Bytes → D} {s t : Registry D} {x id old}
    (accepted : observe hash s x = some t) (seen : s id = some old) : t id = some old := by
  simp only [observe] at accepted
  split at accepted
  · cases accepted
    dsimp only
    split <;> simp_all
  · split at accepted <;> simp_all

def run {D} [DecidableEq D] (hash : Bytes → D) : Registry D → List Shape → Option (Registry D)
  | s, [] => some s
  | s, x :: xs => (observe hash s x).bind (fun t => run hash t xs)

theorem run_preserves {D} [DecidableEq D] {hash : Bytes → D} {s t : Registry D} {id x}
    (xs : List Shape) (ok : run hash s xs = some t) (known : s id = some x) : t id = some x := by
  induction xs generalizing s with
  | nil => cases ok; exact known
  | cons y ys ih =>
    cases e : observe hash s y with
    | none => simp [run, e] at ok
    | some mid => exact ih (by simpa [run, e] using ok) (accepted_preserves e known)

theorem run_contains_every_pair {D} [DecidableEq D] {hash : Bytes → D} {s t : Registry D}
    (xs : List Shape) (ok : run hash s xs = some t) {x} (mem : x ∈ xs) :
    t (hash (shapeBytes x)) = some x := by
  induction xs generalizing s with
  | nil => contradiction
  | cons y ys ih =>
    cases e : observe hash s y with
    | none => simp [run, e] at ok
    | some mid =>
      have rest : run hash mid ys = some t := by simpa [run, e] using ok
      rcases List.mem_cons.mp mem with h | h
      · subst x; exact run_preserves ys rest (accepted_entry e)
      · exact ih rest h

theorem observed_digest_nonaliasing {D} [DecidableEq D] {hash : Bytes → D} {s t : Registry D}
    {xs x y} (ok : run hash s xs = some t) (hx : x ∈ xs) (hy : y ∈ xs)
    (sameId : hash (shapeBytes x) = hash (shapeBytes y)) : x = y := by
  have a := run_contains_every_pair xs ok hx
  have b := run_contains_every_pair xs ok hy
  rw [sameId, b] at a
  exact (Option.some.inj a).symm

theorem repeated_pair_idempotent {D} [DecidableEq D] {hash : Bytes → D} {s : Registry D} {x}
    (seen : s (hash (shapeBytes x)) = some x) : observe hash s x = some s := by
  simp [observe, seen]

theorem observed_collision_rejects {D} [DecidableEq D] {hash : Bytes → D} {s : Registry D} {x y}
    (seen : s (hash (shapeBytes x)) = some y) (distinct : y ≠ x) : observe hash s x = none := by
  simp [observe, seen, distinct]

#print axioms read32_u32
#print axioms readFrame_frame
#print axioms shape_roundtrip
#print axioms shape_frame_injective
#print axioms accepted_entry
#print axioms accepted_preserves
#print axioms run_preserves
#print axioms run_contains_every_pair
#print axioms observed_digest_nonaliasing
#print axioms repeated_pair_idempotent
#print axioms observed_collision_rejects

end ACGN.Eighth.P411
