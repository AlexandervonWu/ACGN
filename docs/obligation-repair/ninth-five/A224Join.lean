import Std

namespace A224

abbrev Address := Nat × Nat

/-- Left rows split immediately before their last column, right rows after their first. -/
structure Left (α : Type) where
  initial : List α
  endpoint : α

structure Right (α : Type) where
  endpoint : α
  suffix : List α

inductive Rule | exact | leftSubtype | rightSubtype | disjoint
  deriving DecidableEq, Repr

structure Boundary (ω : Type) where
  rule : Rule
  witness : ω

structure Entry (α ω : Type) where
  address : Address
  boundary : Boundary ω
  result : Option (List α)

def row (i n : Nat) : List Address := (List.range n).map fun j => (i,j)
def grid (base n : Nat) : Nat → List Address
  | 0 => []
  | m+1 => row base n ++ grid (base+1) n m

theorem matrix_size (base m n : Nat) : (grid base n m).length = m*n := by
  induction m generalizing base with
  | zero => simp [grid]
  | succ m ih => simp [grid,row,ih,Nat.succ_mul,Nat.add_comm]

theorem row_major_address (base m n i j : Nat) (hi : i < m) (hj : j < n) :
    (grid base n m)[i*n+j]? = some (base+i,j) := by
  induction m generalizing base i with
  | zero => omega
  | succ m ih =>
    cases i with
    | zero =>
      simp [grid,row,List.getElem?_append,hj]
    | succ i =>
      have hi' : i < m := by omega
      have notFirst : ¬ (i+1)*n+j < n := by rw [Nat.succ_mul]; omega
      simp [grid, List.getElem?_append, row, notFirst]
      have off : (i+1)*n+j-n = i*n+j := by rw [Nat.succ_mul]; omega
      rw [off, ih (base+1) i hi']
      simp [Nat.add_comm,Nat.add_left_comm]

theorem address_mem (base m n i j : Nat) :
    (i,j) ∈ grid base n m ↔ base ≤ i ∧ i < base+m ∧ j<n := by
  induction m generalizing base with
  | zero => simp [grid]; omega
  | succ m ih =>
    simp [grid,row,ih]
    omega

def collect (f : α → Option β) : List α → Option (List β)
  | [] => some []
  | a::as => do
    let b ← f a
    let bs ← collect f as
    return b::bs

theorem complete_iff (xs : List α) (f : α → Option β) :
    (∃ ys, collect f xs = some ys) ↔ ∀ x ∈ xs, ∃ y, f x = some y := by
  induction xs with
  | nil => simp [collect]
  | cons a xs ih =>
    cases h : f a with
    | none => simp [collect,h]
    | some v =>
      cases t : collect f xs with
      | none => simp [collect,h,t] at ih ⊢; exact ih
      | some bs => simp [collect,h,t] at ih ⊢; exact ih

theorem collected_at {xs : List α} {ys : List β} {f : α → Option β}
    (h : collect f xs = some ys) (k : Nat) :
    ys[k]? = xs[k]?.bind f := by
  induction xs generalizing ys k with
  | nil => simp [collect] at h; subst ys; simp
  | cons x xs ih =>
    cases hx : f x with
    | none => simp [collect,hx] at h
    | some y =>
      cases hxs : collect f xs with
      | none => simp [collect,hx,hxs] at h
      | some bs =>
        simp [collect,hx,hxs] at h
        subst ys
        cases k with
        | zero => simpa using hx.symm
        | succ k => simpa using ih hxs k

theorem collected_length {xs : List α} {ys : List β} {f : α → Option β}
    (h : collect f xs = some ys) : ys.length = xs.length := by
  induction xs generalizing ys with
  | nil => simp [collect] at h; subst ys; rfl
  | cons x xs ih =>
    cases hx : f x with
    | none => simp [collect,hx] at h
    | some y =>
      cases hxs : collect f xs with
      | none => simp [collect,hx,hxs] at h
      | some bs =>
        simp [collect,hx,hxs] at h
        subst ys
        simp [ih hxs]

def joined (left : Left α) (right : Right α) : List α := left.initial ++ right.suffix

def decideCell (classify : α → α → Option (Boundary ω))
    (left : Nat → Left α) (right : Nat → Right α) (ij : Address) : Option (Entry α ω) := do
  let boundary ← classify (left ij.1).endpoint (right ij.2).endpoint
  let output := if boundary.rule = .disjoint then none else some (joined (left ij.1) (right ij.2))
  return ⟨ij,boundary,output⟩

def replay (m n : Nat) (f : Address → Option (Entry α ω)) := collect f (grid 0 n m)
def products (entries : List (Entry α ω)) : List (List α) := entries.filterMap Entry.result

theorem replay_count {m n : Nat} {f : Address → Option (Entry α ω)} {es}
    (ok : replay m n f = some es) : es.length = m*n :=
  (collected_length ok).trans (matrix_size 0 m n)

theorem exact_cell {m n i j : Nat} {c : α → α → Option (Boundary ω)} {l : Nat → Left α}
    {r : Nat → Right α} {es} (ok : replay m n (decideCell c l r) = some es)
    (hi : i<m) (hj : j<n) :
    es[i*n+j]? = decideCell c l r (i,j) := by
  rw [collected_at ok, row_major_address 0 m n i j hi hj]
  simp

theorem unclassified_pair_blocks {m n i j : Nat} {c : α → α → Option (Boundary ω)}
    {l : Nat → Left α} {r : Nat → Right α} (hi : i<m) (hj : j<n)
    (missing : c (l i).endpoint (r j).endpoint = none) :
    replay m n (decideCell c l r) = none := by
  cases h : replay m n (decideCell c l r) with
  | none => rfl
  | some es =>
    have legal := (complete_iff (grid 0 n m) (decideCell c l r)).mp ⟨es,h⟩
    have mem : (i,j) ∈ grid 0 n m := (address_mem ..).mpr (by simp [hi,hj])
    obtain ⟨e,he⟩ := legal (i,j) mem
    simp [decideCell,missing] at he

theorem retained_or_disjoint {m n i j : Nat} {c : α → α → Option (Boundary ω)}
    {l : Nat → Left α} {r : Nat → Right α} {es} (ok : replay m n (decideCell c l r) = some es)
    (hi : i<m) (hj : j<n) {b : Boundary ω} (hb : c (l i).endpoint (r j).endpoint = some b) :
    es[i*n+j]? = some ⟨(i,j),b,if b.rule = .disjoint then none else some (joined (l i) (r j))⟩ := by
  rw [exact_cell ok hi hj]
  simp [decideCell,hb]

theorem product_width (l : Left α) (r : Right α) (p q : Nat)
    (hl : l.initial.length=p) (hr : r.suffix.length=q) :
    (joined l r).length = (p+1) + (q+1) - 2 := by simp [joined,hl,hr]; omega

/-- The empty branch precedes the product-DAG normalization branch in both Java implementations. -/
inductive Family (α : Type)
  | typedEmpty (width : Nat)
  | normalized (width : Nat) (rows : List (List α))

def finish (width : Nat) (normalize : List (List α) → List (List α))
    (es : List (Entry α ω)) : Option (Family α) :=
  if width = 0 then none else match products es with
  | [] => some (.typedEmpty width)
  | x::xs => some (.normalized width (normalize (x::xs)))

theorem empty_exactly_omitted {normalize : List (List α) → List (List α)}
    {es : List (Entry α ω)} {w : Nat} (positive : w>0) :
    finish w normalize es = some (.typedEmpty w) ↔ ∀ e ∈ es, e.result = none := by
  have h : w ≠ 0 := by omega
  rw [← List.filterMap_eq_nil_iff]
  change _ ↔ products es = []
  cases hp : products es <;> simp [finish,h,hp]

theorem all_disjoint_typed_empty {m n w : Nat} {c : α → α → Option (Boundary ω)}
    {l : Nat → Left α} {r : Nat → Right α} {es} (ok : replay m n (decideCell c l r) = some es)
    (positive : w>0) (disjoint : ∀ i<m, ∀ j<n, ∃ b, c (l i).endpoint (r j).endpoint = some b ∧ b.rule = .disjoint)
    (normalize : List (List α) → List (List α)) :
    finish w normalize es = some (.typedEmpty w) := by
  apply (empty_exactly_omitted positive).mpr
  intro e he
  obtain ⟨k,hk,hval⟩ := List.mem_iff_getElem.mp he
  have max : k<m*n := (replay_count ok) ▸ hk
  have hn : n>0 := by
    cases n with
    | zero => simp at max
    | succ n => omega
  let i := k/n
  let j := k%n
  have hi : i<m := (Nat.div_lt_iff_lt_mul hn).mpr max
  have hj : j<n := Nat.mod_lt _ hn
  obtain ⟨b,hb,hd⟩ := disjoint i hi j hj
  have value := retained_or_disjoint ok hi hj hb
  have unique : i*n+j=k := by dsimp [i,j]; rw [Nat.mul_comm]; exact Nat.div_add_mod k n
  rw [unique,List.getElem?_eq_getElem hk,hval,hd] at value
  simp at value
  rw [value]

#print axioms matrix_size
#print axioms row_major_address
#print axioms address_mem
#print axioms complete_iff
#print axioms collected_at
#print axioms collected_length
#print axioms replay_count
#print axioms exact_cell
#print axioms unclassified_pair_blocks
#print axioms retained_or_disjoint
#print axioms product_width
#print axioms empty_exactly_omitted
#print axioms all_disjoint_typed_empty

theorem candidate_iff_index {m n : Nat} {c : α → α → Option (Boundary ω)}
    {l : Nat → Left α} {r : Nat → Right α} {es} (ok : replay m n (decideCell c l r) = some es)
    (a : List α) : a ∈ products es ↔ ∃ i<m, ∃ j<n, ∃ b,
      c (l i).endpoint (r j).endpoint = some b ∧ b.rule ≠ .disjoint ∧ a = joined (l i) (r j) := by
  constructor
  · intro h
    obtain ⟨e,he,ret⟩ := List.mem_filterMap.mp h
    obtain ⟨t,ht,hval⟩ := List.mem_iff_getElem.mp he
    have bound : t<m*n := (replay_count ok) ▸ ht
    have hn : n>0 := by cases n <;> simp_all
    let i:=t/n
    let j:=t%n
    have hi : i<m := (Nat.div_lt_iff_lt_mul hn).mpr bound
    have hj : j<n := Nat.mod_lt _ hn
    have pos : i*n+j=t := by dsimp [i,j]; rw [Nat.mul_comm]; exact Nat.div_add_mod t n
    have actual := exact_cell ok hi hj
    rw [pos,List.getElem?_eq_getElem ht,hval] at actual
    cases hc : c (l i).endpoint (r j).endpoint with
    | none => simp [decideCell,hc] at actual
    | some b =>
      by_cases d : b.rule=.disjoint
      · simp [decideCell,hc,d] at actual; rw [actual] at ret; contradiction
      · simp [decideCell,hc,d] at actual
        rw [actual] at ret
        exact ⟨i,hi,j,hj,b,hc,d,(Option.some.inj ret).symm⟩
  · rintro ⟨i,hi,j,hj,b,hb,hd,rfl⟩
    have e := retained_or_disjoint ok hi hj hb
    simp only [hd, ↓reduceIte] at e
    apply List.mem_filterMap.mpr
    exact ⟨_,List.mem_of_getElem? e,rfl⟩

#print axioms candidate_iff_index

end A224
