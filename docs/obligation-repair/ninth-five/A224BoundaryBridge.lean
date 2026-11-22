import A224Join
import A222Intersection

namespace A224

/-- Closed source-extraction language. Both compiler-attributed implementations must
lower to this program before its parametric JOIN interpretation is available. -/
def lower : List String → Option Unit
  | ["positive-width:checked-sum-minus-two", "left-ascending", "right-ascending",
     "boundary:last-left:first-right", "disjoint:record:skip", "overlap:init-left:tail-right",
     "overlap:record:retain", "empty:typed-width", "nonempty:normalize"] => some ()
  | _ => none

def toDecision (l r : A222.Col) : Option (Boundary A222.Boundary) :=
  match A222.classify l r with
  | .exact => some ⟨.exact,.exact⟩
  | .leftSubtype => some ⟨.leftSubtype,.leftSubtype⟩
  | .rightSubtype => some ⟨.rightSubtype,.rightSubtype⟩
  | .disjoint a => some ⟨.disjoint,.disjoint a⟩
  | .unsupported => none

theorem rejection_is_not_disjoint (l r : A222.Col) :
    toDecision l r = none ↔ A222.classify l r = .unsupported := by
  cases h : A222.classify l r <;> simp [toDecision,h]

theorem omission_provenance (l r : A222.Col) (a : Nat) :
    toDecision l r = some ⟨.disjoint,.disjoint a⟩ ↔
    l.head ≠ r.head ∧ A222.shared l r ∧ r.head ∉ l.parents ∧ l.head ∉ r.parents ∧
      A222.firstCommon l r = some a := by
  rw [← A222.classify_disjoint]
  cases h : A222.classify l r <;> simp [toDecision,h]

theorem authentic_disjoint_has_no_carrier (f : A222.Forest) (l r : A222.Col)
    (hl : A222.fits f l) (hr : A222.fits f r) (a x : Nat)
    (h : toDecision l r = some ⟨.disjoint,.disjoint a⟩) :
    ¬ (A222.below f x l.head ∧ A222.below f x r.head) := by
  have d := (A222.classify_disjoint l r a).mpr ((omission_provenance ..).mp h)
  have accepted : A222.classify l r ≠ .unsupported := by simp [d]
  have semantics := A222.column_semantics f l r hl hr accepted x
  rw [d] at semantics
  simpa [A222.chosen] using semantics

def combineJ (p q m n : Nat) (l : Nat → Left A222.Col) (r : Nat → Right A222.Col)
    (normalize : List (List A222.Col) → List (List A222.Col)) :
    Option (List (Entry A222.Col A222.Boundary) × Family A222.Col) := do
  let w := (p+1)+(q+1)-2
  if w = 0 then none else
    let es ← replay m n (decideCell toDecision l r)
    let family ← finish w normalize es
    return (es,family)

theorem checked_arity (p q : Nat) : (p+1)+(q+1)-2 = p+q := by omega

theorem nullary_blocked (m n : Nat) (l : Nat → Left A222.Col) (r : Nat → Right A222.Col)
    (normalize : List (List A222.Col) → List (List A222.Col)) :
    combineJ 0 0 m n l r normalize = none := by simp [combineJ]

theorem accepted_ledger {p q m n : Nat} {l : Nat → Left A222.Col} {r : Nat → Right A222.Col}
    {normalize es result} (ok : combineJ p q m n l r normalize = some (es,result)) :
    0 < p+q ∧ replay m n (decideCell toDecision l r) = some es ∧ es.length = m*n ∧
      finish (p+q) normalize es = some result := by
  unfold combineJ at ok
  rw [checked_arity] at ok
  by_cases z : p+q=0
  · simp [z] at ok
  · simp only [z, ↓reduceIte] at ok
    cases h : replay m n (decideCell toDecision l r) with
    | none => simp [h] at ok
    | some entries =>
      cases h' : finish (p+q) normalize entries with
      | none => simp [h,h'] at ok
      | some family =>
        simp [h,h'] at ok
        obtain ⟨rfl,rfl⟩ := ok
        exact ⟨by omega,rfl,replay_count h,h'⟩

theorem every_survivor_from_its_pair {p q m n i j : Nat}
    {l : Nat → Left A222.Col} {r : Nat → Right A222.Col} {normalize es result}
    (ok : combineJ p q m n l r normalize = some (es,result)) (hi : i<m) (hj : j<n)
    (hl : (l i).initial.length=p) (hr : (r j).suffix.length=q)
    {b : Boundary A222.Boundary} (decided : toDecision (l i).endpoint (r j).endpoint = some b)
    (overlap : b.rule ≠ .disjoint) :
    es[i*n+j]? = some ⟨(i,j),b,some ((l i).initial ++ (r j).suffix)⟩ ∧
      ((l i).initial ++ (r j).suffix).length = p+q := by
  have e := retained_or_disjoint (accepted_ledger ok).2.1 hi hj decided
  exact ⟨by simpa [overlap,joined] using e, by simp [hl,hr]⟩

#print axioms rejection_is_not_disjoint
#print axioms omission_provenance
#print axioms authentic_disjoint_has_no_carrier
#print axioms checked_arity
#print axioms nullary_blocked
#print axioms accepted_ledger
#print axioms every_survivor_from_its_pair

theorem classified_disjoint_builds_empty {p q m n : Nat} {l : Nat → Left A222.Col}
    {r : Nat → Right A222.Col} (width : 0 < p+q)
    (disjoint : ∀ i<m, ∀ j<n, ∃ a, A222.classify (l i).endpoint (r j).endpoint = .disjoint a)
    (normalize : List (List A222.Col) → List (List A222.Col)) :
    ∃ es, combineJ p q m n l r normalize = some (es,.typedEmpty (p+q)) ∧ es.length=m*n := by
  have cert : ∀ i<m, ∀ j<n, ∃ b, toDecision (l i).endpoint (r j).endpoint = some b ∧
      b.rule = .disjoint := by
    intro i hi j hj
    obtain ⟨a,ha⟩ := disjoint i hi j hj
    exact ⟨⟨.disjoint,.disjoint a⟩,by simp [toDecision,ha],rfl⟩
  have possible : ∀ x ∈ grid 0 n m, ∃ e, decideCell toDecision l r x = some e := by
    intro x hx
    obtain ⟨i,j⟩ := x
    obtain ⟨_,hi,hj⟩ := (address_mem 0 m n i j).mp hx
    obtain ⟨b,hb,_⟩ := cert i (by simpa using hi) j hj
    simp [decideCell,hb]
  obtain ⟨es,ok⟩ := (complete_iff _ _).mpr possible
  change replay m n (decideCell toDecision l r) = some es at ok
  have finished := all_disjoint_typed_empty ok width cert normalize
  refine ⟨es,?_,replay_count ok⟩
  simp [combineJ,checked_arity,ok,finished]
  omega

/-- The post-check returns every record only after the count and every decoded field agree. -/
def agree [DecidableEq ρ] (expected seen : List ρ) : Bool :=
  decide (expected.length=seen.length) && (expected.zip seen).all fun ab => decide (ab.1=ab.2)

theorem admitted_records_exact [DecidableEq ρ] (expected observed : List ρ) :
    agree expected observed = true ↔ expected = observed := by
  induction expected generalizing observed with
  | nil => cases observed <;> simp [agree]
  | cons x xs ih =>
    cases observed with
    | nil => simp [agree]
    | cons y ys =>
      have tail := ih ys
      simp only [agree, Bool.and_eq_true, decide_eq_true_eq, List.length_cons,
        Nat.add_right_cancel_iff, List.zip_cons_cons, List.all_cons, List.cons.injEq] at tail ⊢
      constructor
      · rintro ⟨hs,xy,e⟩
        exact ⟨xy,tail.mp ⟨hs,e⟩⟩
      · rintro ⟨xy,eq⟩
        obtain ⟨hs,e⟩ := tail.mpr eq
        exact ⟨hs,xy,e⟩

#print axioms classified_disjoint_builds_empty
#print axioms admitted_records_exact

end A224
