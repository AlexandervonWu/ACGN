import A224NinthDenotation

namespace A224

def eval (code : List String) (p q m n : Nat) (l : Nat → Left A222.Col)
    (r : Nat → Right A222.Col) (normalize : List (List A222.Col) → List (List A222.Col)) :
    Option (List (Entry A222.Col A222.Boundary) × Family A222.Col) := do
  let _ ← lower code
  combineJ p q m n l r normalize

theorem registered_matrix {code : List String} {p q m n i j : Nat} {l : Nat → Left A222.Col}
    {r : Nat → Right A222.Col} {normalize es result}
    (ok : eval code p q m n l r normalize = some (es,result)) (hi : i<m) (hj : j<n) :
    lower code = some () ∧ es.length = m*n ∧
    es[i*n+j]? = decideCell toDecision l r (i,j) := by
  cases h : lower code with
  | none => simp [eval,h] at ok
  | some u =>
    cases u
    have actual : combineJ p q m n l r normalize = some (es,result) := by simpa [eval,h] using ok
    have ledger := accepted_ledger actual
    exact ⟨rfl,ledger.2.2.1,exact_cell ledger.2.1 hi hj⟩

theorem registered_typed_empty {code : List String} {p q m n : Nat} {l : Nat → Left A222.Col}
    {r : Nat → Right A222.Col} (accepted : lower code = some ()) (width : 0<p+q)
    (d : ∀ i<m, ∀ j<n, ∃ a, A222.classify (l i).endpoint (r j).endpoint = .disjoint a)
    (normalize : List (List A222.Col) → List (List A222.Col)) :
    ∃ es, eval code p q m n l r normalize = some (es,.typedEmpty (p+q)) ∧ es.length=m*n := by
  simpa [eval,accepted] using classified_disjoint_builds_empty width d normalize

abbrev NinthCol := ACGN.Ninth.A221.Column

def ninthDecision (tag : ACGN.Ninth.A221.AtomKey → Nat) (a b : NinthCol) :=
  toDecision (A222.Normalized.project tag a) (A222.Normalized.project tag b)

/-- The same extracted instruction program, interpreted on the current Java column
and normalization model. Both the returned family and matrix use the same entries. -/
noncomputable def evalNinth (program : List String) (tag : ACGN.Ninth.A221.AtomKey → Nat) (p q m n : Nat)
    (l : Nat → Left NinthCol) (r : Nat → Right NinthCol) :
    Option (List (Entry NinthCol A222.Boundary) × Family NinthCol) := do
  let _ ← lower program
  let entries ← replay m n (decideCell (ninthDecision tag) l r)
  let result ← finish ((p+1)+(q+1)-2) ACGN.Ninth.A221.normalize entries
  return (entries,result)

def familyRows : Family α → List (List α)
  | .typedEmpty _ => []
  | .normalized _ rows => rows

theorem registered_normalized_result (f : A222.Forest) (tag : ACGN.Ninth.A221.AtomKey → Nat)
    (inj : ∀ {a b}, tag a = tag b → a = b)
    {program : List String} {p q m n : Nat} {l : Nat → Left NinthCol} {r : Nat → Right NinthCol}
    {es result} (ok : evalNinth program tag p q m n l r = some (es,result))
    (fl : ∀ i<m, ∀ a ∈ (l i).initial, A222.fits f (A222.Normalized.project tag a))
    (fr : ∀ j<n, ∀ b ∈ (r j).suffix, A222.fits f (A222.Normalized.project tag b)) :
    lower program = some () ∧ 0<p+q ∧ es.length=m*n ∧
    (∀ i<m, ∀ j<n, es[i*n+j]? = decideCell (ninthDecision tag) l r (i,j)) ∧
    (result = .typedEmpty (p+q) ↔ ∀ e ∈ es, e.result = none) ∧
    (∀ ws, A222.familyContains f ((familyRows result).map (A222.Normalized.rowOf tag)) ws ↔
      ∃ i<m, ∃ j<n, ∃ b, ninthDecision tag (l i).endpoint (r j).endpoint = some b ∧
          b.rule ≠ .disjoint ∧ A222.inhabits f (A222.Normalized.rowOf tag (joined (l i) (r j))) ws) := by
  cases hl : lower program with
  | none => simp [evalNinth,hl] at ok
  | some u =>
    cases u
    cases hr : replay m n (decideCell (ninthDecision tag) l r) with
    | none => simp [evalNinth,hl,hr] at ok
    | some entries =>
      cases hf : finish (p+q) ACGN.Ninth.A221.normalize entries with
      | none => simp [evalNinth,hl,hr,checked_arity,hf] at ok
      | some family =>
        simp [evalNinth,hl,hr,checked_arity,hf] at ok
        obtain ⟨rfl,rfl⟩ := ok
        have positive : 0 < p+q := by
          by_cases z : p+q=0
          · simp [finish,z] at hf
          · omega
        have empty := empty_exactly_omitted (normalize:=ACGN.Ninth.A221.normalize) (es:=entries) positive
        rw [hf] at empty
        refine ⟨rfl,positive,replay_count hr,fun i hi j hj => exact_cell hr hi hj,by simpa using empty,?_⟩
        have rows : familyRows family = ACGN.Ninth.A221.normalize (products entries) := by
          have nz : p+q ≠ 0 := by omega
          cases hp : products entries with
          | nil =>
            simp only [finish, ite_eq_right nz, hp, Option.some.injEq] at hf
            subst family
            simp [familyRows, ACGN.Ninth.A221.normalize, ACGN.Ninth.A221.groups,
                  ACGN.Ninth.A221.distinct, ACGN.Ninth.A221.maximal]
          | cons hd tl =>
            simp only [finish, ite_eq_right nz, hp, Option.some.injEq] at hf
            subst family
            rfl
        intro ws
        rw [rows]
        exact normalized_join_denotation f tag inj hr fl fr ws

#print axioms registered_normalized_result
#print axioms registered_matrix
#print axioms registered_typed_empty

end A224
