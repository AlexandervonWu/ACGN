import Std

namespace ACGN.Eighth.A223
variable {α : Type} {le lt : α → α → Prop}
abbrev Family (α : Type) := List (List α)

-- Column keys are the exact graph types. Weak includes exact equality and the
-- admitted LEFT_SUBTYPE_OF_RIGHT evidence for an individual coordinate.
def Weak (le : α → α → Prop) : List α → List α → Prop
  | [], [] => True
  | a :: as, b :: bs => le a b ∧ Weak le as bs
  | _, _ => False

def Antichain (le : α → α → Prop) (F : Family α) : Prop :=
  ∀ x ∈ F, ∀ y ∈ F, Weak le x y → x = y

def Width (n : Nat) (F : Family α) : Prop := ∀ x ∈ F, x.length = n

-- This is the product part of the nested case loop, in its original order.
def matrix (L R : Family α) : Family α := L.flatMap fun x => R.map (x ++ ·)

theorem exact_rows {L R : Family α} {z : List α} :
    z ∈ matrix L R ↔ ∃ x ∈ L, ∃ y ∈ R, x ++ y = z := by
  simp [matrix]

theorem case_count (L R : Family α) : (matrix L R).length = L.length * R.length := by
  induction L with
  | nil => simp [matrix]
  | cons x xs ih => simpa [matrix, Nat.succ_mul, Nat.add_comm] using ih

theorem split_weak {a b x y : List α} (hab : a.length = b.length) :
    Weak le (a ++ x) (b ++ y) ↔ Weak le a b ∧ Weak le x y := by
  induction a generalizing b with
  | nil => cases b <;> simp_all [Weak]
  | cons h t ih =>
    cases b with
    | nil => simp at hab
    | cons k u =>
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hab
      simp only [List.cons_append, Weak, ih hab, and_assoc]

theorem no_new_absorption {L R : Family α} (wl : Width n L)
    (al : Antichain le L) (ar : Antichain le R) : Antichain le (matrix L R) := by
  intro x hx y hy hw
  obtain ⟨a,ha,b,hb,rfl⟩ := exact_rows.mp hx
  obtain ⟨c,hc,d,hd,rfl⟩ := exact_rows.mp hy
  obtain ⟨hl,hr⟩ := (split_weak ((wl _ ha).trans (wl _ hc).symm)).mp hw
  rw [al _ ha _ hc hl, ar _ hb _ hd hr]

theorem lex_prefix (p : List α) {a b : List α} (h : List.Lex lt a b) :
    List.Lex lt (p ++ a) (p ++ b) := by
  induction p with
  | nil => exact h
  | cons x xs ih => exact .cons ih

theorem lex_suffix {a b : List α} (h : List.Lex lt a b) (w : a.length = b.length)
    (x y : List α) : List.Lex lt (a ++ x) (b ++ y) := by
  induction h with
  | nil => simp at w
  | rel h => exact .rel h
  | cons _ ih => exact .cons (ih (by simpa using w))

theorem row_major_is_sorted {L R : Family α} (w : Width n L)
    (hl : L.Pairwise (List.Lex lt)) (hr : R.Pairwise (List.Lex lt)) :
    (matrix L R).Pairwise (List.Lex lt) := by
  apply List.pairwise_flatMap.mpr
  constructor
  · intro x _
    exact List.pairwise_map.mpr (hr.imp fun h => lex_prefix x h)
  · apply List.Pairwise.imp_of_mem (p := hl)
    intro a b ha hb hab x hx y hy
    obtain ⟨c,_,rfl⟩ := List.mem_map.mp hx
    obtain ⟨d,_,rfl⟩ := List.mem_map.mp hy
    exact lex_suffix hab ((w _ ha).trans (w _ hb).symm) c d

-- On rows with distinct keys, the Java duplicate representative preference
-- never runs. This deletion specification is used only under that invariant.
def unique [DecidableEq α] : List α → List α
  | [] => []
  | x :: xs => if x ∈ xs then unique xs else x :: unique xs

theorem unique_on_nodup [DecidableEq α] {xs : List α} (h : xs.Nodup) : unique xs = xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [unique, (List.nodup_cons.mp h).1, ih (List.nodup_cons.mp h).2]

-- Java's absorption test is strict. Sorting uses the structural recursive
-- GraphType order on products of fixed arity. The model uses a stable sort.
noncomputable def normalize (le lt : α → α → Prop) (xs : Family α) : Family α := by
  classical
  let ys := unique xs
  let keep := ys.filter fun x => decide (∀ y ∈ ys, Weak le x y → x = y)
  exact keep.mergeSort (fun a b => decide (List.Lex lt a b ∨ a = b))

theorem normalized_matrix_exact {L R : Family α} (w : Width n L)
    (ir : ∀ x, ¬ lt x x) (al : Antichain le L) (ar : Antichain le R)
    (hl : L.Pairwise (List.Lex lt)) (hr : R.Pairwise (List.Lex lt)) :
    normalize le lt (matrix L R) = matrix L R := by
  classical
  have hs := row_major_is_sorted w hl hr
  have nd : (matrix L R).Nodup := hs.imp fun h eq => by
    subst_vars
    exact List.lex_irrefl ir _ h
  have ha := no_new_absorption w al ar
  simp only [normalize, unique_on_nodup nd]
  rw [List.filter_eq_self.mpr (fun x hx => decide_eq_true (ha x hx))]
  apply List.mergeSort_of_pairwise
  exact hs.imp fun h => decide_eq_true (Or.inl h)

theorem row_width {L R : Family α} (wl : Width m L) (wr : Width n R) :
    Width (m+n) (matrix L R) := by
  intro x hx
  obtain ⟨a,ha,b,hb,rfl⟩ := exact_rows.mp hx
  simp [wl a ha, wr b hb]

theorem empty_cases (L R : Family α) : matrix [] R = [] ∧ matrix L [] = [] := by
  simp [matrix]

theorem pair_at {L R : Family α} {i j : Nat} (hi : i < L.length) (hj : j < R.length) :
    (matrix L R)[i * R.length + j]? = some (L[i] ++ R[j]) := by
  induction L generalizing i with
  | nil => simp at hi
  | cons x xs ih =>
    cases i with
    | zero =>
      simp only [matrix, List.flatMap_cons, Nat.zero_mul, Nat.zero_add, List.getElem_cons_zero]
      rw [List.getElem?_append_left (by simpa using hj), List.getElem?_map,
        List.getElem?_eq_getElem hj]
      rfl
    | succ i =>
      have bound : i < xs.length := by simpa using hi
      change ((R.map (x ++ ·)) ++ matrix xs R)[(i+1)*R.length+j]? = _
      rw [List.getElem?_append_right (by simp; rw [Nat.succ_mul]; omega)]
      simp only [List.length_map, List.getElem_cons_succ]
      have off : (i+1)*R.length+j-R.length = i*R.length+j := by rw [Nat.succ_mul]; omega
      rw [off]
      exact ih bound

theorem duplicate_columns [DecidableEq α] (c : α) (x y : List α) :
    (x ++ y).count c = x.count c + y.count c := List.count_append

-- Distinct column evidence can project to the same exact graph type.
-- Sorting and duplicate detection use exact keys; subsumption inspects evidence.
abbrev keys (k : ε → α) (p : List ε) := p.map k
def AntiKeys (k : ε → α) (weak : ε → ε → Prop) (F : Family ε) : Prop :=
  ∀ x ∈ F, ∀ y ∈ F, Weak weak x y → keys k x = keys k y

theorem mapped_matrix (k : ε → α) (L R : Family ε) :
    (matrix L R).map (keys k) = matrix (L.map (keys k)) (R.map (keys k)) := by
  simp [matrix, keys, List.map_flatMap, List.flatMap_map, List.map_map, Function.comp_def]

theorem evidence_absorption (k : ε → α) {weak : ε → ε → Prop} {L R : Family ε}
    (w : Width n L) (al : AntiKeys k weak L) (ar : AntiKeys k weak R) :
    AntiKeys k weak (matrix L R) := by
  intro x hx y hy hw
  obtain ⟨a,ha,b,hb,rfl⟩ := exact_rows.mp hx
  obtain ⟨c,hc,d,hd,rfl⟩ := exact_rows.mp hy
  obtain ⟨u,v⟩ := (split_weak ((w _ ha).trans (w _ hc).symm)).mp hw
  simp only [keys, List.map_append]
  change keys k a ++ keys k b = keys k c ++ keys k d
  rw [al a ha c hc u, ar b hb d hd v]

def uniqueKeys [DecidableEq α] (k : ε → α) : Family ε → Family ε
  | [] => []
  | x :: xs => if keys k x ∈ xs.map (keys k) then uniqueKeys k xs else x :: uniqueKeys k xs

theorem unique_evidence_on_keys [DecidableEq α] (k : ε → α) {xs : Family ε}
    (h : (xs.map (keys k)).Nodup) : uniqueKeys k xs = xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.map_cons,List.nodup_cons] at h
    simp [uniqueKeys,h.1,ih h.2]

noncomputable def normalizeEvidence (k : ε → α) (weak : ε → ε → Prop) (lt : α → α → Prop)
    (xs : Family ε) : Family ε := by
  classical
  let ys := uniqueKeys k xs
  let keep := ys.filter fun x => decide (∀ y ∈ ys, Weak weak x y → keys k x = keys k y)
  exact keep.mergeSort fun a b => decide (List.Lex lt (keys k a) (keys k b) ∨ keys k a = keys k b)

theorem normalize_preserves_actual_evidence (k : ε → α) {weak : ε → ε → Prop} {L R : Family ε}
    (w : Width n L) (ir : ∀ x, ¬ lt x x) (al : AntiKeys k weak L) (ar : AntiKeys k weak R)
    (hl : (L.map (keys k)).Pairwise (List.Lex lt)) (hr : (R.map (keys k)).Pairwise (List.Lex lt)) :
    normalizeEvidence k weak lt (matrix L R) = matrix L R := by
  classical
  have wk : Width n (L.map (keys k)) := by
    intro x hx
    obtain ⟨y,hy,rfl⟩ := List.mem_map.mp hx
    simpa [keys] using w y hy
  have hs := row_major_is_sorted wk hl hr
  rw [← mapped_matrix] at hs
  have nd : ((matrix L R).map (keys k)).Nodup := hs.imp fun h eq => by
    subst_vars
    exact List.lex_irrefl ir _ h
  have ha := evidence_absorption k w al ar
  simp only [normalizeEvidence,unique_evidence_on_keys k nd]
  rw [List.filter_eq_self.mpr (fun x hx => decide_eq_true (ha x hx))]
  apply List.mergeSort_of_pairwise
  exact (List.pairwise_map.mp hs).imp fun h => decide_eq_true (Or.inl h)

theorem arbitrary_reassociation (a b c : Family α) :
    matrix (matrix a b) c = matrix a (matrix b c) := by
  simp [matrix, List.flatMap_assoc, List.flatMap_map, List.map_flatMap, List.map_map, Function.comp_def]

#print axioms arbitrary_reassociation
#print axioms mapped_matrix
#print axioms evidence_absorption
#print axioms unique_evidence_on_keys
#print axioms normalize_preserves_actual_evidence
#print axioms pair_at
#print axioms duplicate_columns
#print axioms exact_rows
#print axioms case_count
#print axioms split_weak
#print axioms no_new_absorption
#print axioms lex_prefix
#print axioms lex_suffix
#print axioms row_major_is_sorted
#print axioms unique_on_nodup
#print axioms normalized_matrix_exact
#print axioms row_width
#print axioms empty_cases
inductive OperandSide | left | right deriving DecidableEq, BEq

def readSide : String → Option OperandSide
  | "addAll:leftProduct" => some .left
  | "addAll:rightProduct" => some .right
  | _ => none

-- Accepted lowering has only counted loops, their indexed reads, ARROW, two
-- block appends, the product/case writes, and the immediate continue.
def decode : List String → Option (List OperandSide)
  | ["outer:left:ascending-index","lookup:left:outer","inner:right:ascending-index",
     "lookup:right:inner","guard:ARROW",a,b,"add:product",
     "new:CombinationCase:leftIndex:rightIndex:CombinationDecision.ARROW_PRODUCT:null:product",
     "add:case","continue","admission:positive-uniform-width-and-compatible-authority",
     "group:exact-product-key-prefer-authenticated-duplicate","prune:all-other-products-strict-coordinate-subtype",
     "sort:by-structural-product-type","type-order:int-before-nominal-UTF16-then-lex-columns",
     "freeze:rows-and-ordered-column-evidence","return:typed-empty-or-normalized-products-and-cases",
     "source:append-left-leaves-then-right-leaves"] => do return [← readSide a, ← readSide b]
  | _ => none

def block (p : List OperandSide) (a b : List α) : List α :=
  p.flatMap fun | .left => a | .right => b

-- Forward indexed loops append to the result; this recursive machine preserves
-- its initial result prefix at each step, independently of the flatMap definition.
def inner (p : List OperandSide) (a : List α) : Family α → Family α → Family α
  | [], acc => acc
  | b :: bs, acc => inner p a bs (acc ++ [block p a b])

def outer (p : List OperandSide) (R : Family α) : Family α → Family α → Family α
  | [], acc => acc
  | x :: xs, acc => outer p R xs (inner p x R acc)

theorem inner_accumulator (p : List OperandSide) (a : List α) (R acc : Family α) :
    inner p a R acc = acc ++ R.map (block p a) := by
  induction R generalizing acc with
  | nil => simp [inner]
  | cons x xs ih => simp [inner,ih,List.append_assoc]

theorem outer_accumulator (p : List OperandSide) (L R acc : Family α) :
    outer p R L acc = acc ++ L.flatMap (fun a => R.map (block p a)) := by
  induction L generalizing acc with
  | nil => simp [outer]
  | cons x xs ih => simp [outer,ih,inner_accumulator,List.append_assoc]

def accepted (stream : List String) := decide (decode stream = some [.left,.right])
def execute (stream : List String) (L R : Family α) := (decode stream).map fun p => outer p R L []

theorem accepted_compiler_stream_refines (stream : List String) (L R : Family α)
    (h : accepted stream = true) : execute stream L R = some (matrix L R) := by
  have hd : decode stream = some [.left,.right] := of_decide_eq_true h
  have hb (x : List α) : block [.left,.right] x = fun y => x ++ y := by
    funext y
    simp [block]
  simp [execute,hd,outer_accumulator,matrix,hb]

#print axioms inner_accumulator
#print axioms outer_accumulator
#print axioms accepted_compiler_stream_refines
-- Atomic keys use the Java enum tag followed by the UTF-16 symbol units.
-- A relation product has constant outer kind and null symbol, hence its
-- comparison is lexicographic on these atomic keys, with a final length tie.
abbrev AtomKey := List Nat
def intKey : AtomKey := [0]
def nominalKey (utf16 : List (Fin 65536)) : AtomKey := 1 :: utf16.map Fin.val

-- LinkedHashMap.put: an old key retains its position. Its representative
-- can be replaced with the newly encountered row only by the authority policy.
def putRepresentative (k : ε → AtomKey) (auth : List ε → Bool) (xs : Family ε) (row : List ε) : Family ε :=
  if keys k row ∈ xs.map (keys k) then
    xs.map fun old => if keys k old = keys k row ∧ auth old = false ∧ auth row = true then row else old
  else xs ++ [row]

theorem put_keys (k : ε → AtomKey) (auth : List ε → Bool) (xs : Family ε) (r : List ε) :
    (putRepresentative k auth xs r).map (keys k) =
      if keys k r ∈ xs.map (keys k) then xs.map (keys k) else xs.map (keys k) ++ [keys k r] := by
  unfold putRepresentative
  split
  · rw [List.map_map]
    apply List.map_congr_left
    intro a _
    simp only [Function.comp_apply]
    split <;> simp_all
  · simp

theorem put_admits (k : ε → AtomKey) (auth : List ε → Bool) {xs : Family ε} {r : List ε}
    (nd : (xs.map (keys k)).Nodup) (w : Width n xs) (wr : r.length = n) :
    ((putRepresentative k auth xs r).map (keys k)).Nodup ∧ Width n (putRepresentative k auth xs r) := by
  constructor
  · rw [put_keys]
    split <;> simp_all [List.nodup_append]
  · intro a ha
    unfold putRepresentative at ha
    split at ha
    · obtain ⟨old,ho,he⟩ := List.mem_map.mp ha
      split at he <;> subst a <;> first | exact wr | exact w old ho
    · rcases List.mem_append.mp ha with hm|hm
      · exact w _ hm
      · simp only [List.mem_singleton] at hm
        simpa [hm] using wr

theorem grouped_admits (k : ε → AtomKey) (auth : List ε → Bool) (raw acc : Family ε)
    (wr : Width n raw) (wa : Width n acc) (nd : (acc.map (keys k)).Nodup) :
    let grouped := raw.foldl (putRepresentative k auth) acc
    (grouped.map (keys k)).Nodup ∧ Width n grouped := by
  induction raw generalizing acc with
  | nil => exact ⟨nd,wa⟩
  | cons r rs ih =>
    have h := put_admits k auth nd wa (wr _ (List.mem_cons_self ..))
    exact ih _ (fun x hx => wr x (List.mem_cons_of_mem _ hx)) h.2 h.1

noncomputable def prune (k : ε → AtomKey) (weak : ε → ε → Prop) (xs : Family ε) : Family ε := by
  classical
  exact xs.filter fun x => decide (∀ y ∈ xs, Weak weak x y → keys k x = keys k y)

theorem prune_antichain (k : ε → AtomKey) (weak : ε → ε → Prop) (xs : Family ε) :
    AntiKeys k weak (prune k weak xs) := by
  classical
  intro x hx y hy h
  exact (of_decide_eq_true (List.mem_filter.mp hx).2) y (List.mem_filter.mp hy).1 h

def keyOrder (k : ε → AtomKey) (x y : List ε) := decide (keys k x ≤ keys k y)

theorem sorted_keys (k : ε → AtomKey) (xs : Family ε) (nd : (xs.map (keys k)).Nodup) :
    ((xs.mergeSort (keyOrder k)).map (keys k)).Pairwise (List.Lex (· < ·)) := by
  have ord : (xs.mergeSort (keyOrder k)).Pairwise (fun x y => keys k x ≤ keys k y) := by
    apply List.Pairwise.imp (fun h => of_decide_eq_true h)
    apply List.pairwise_mergeSort
    · intro x y z xy yz
      exact decide_eq_true (Std.le_trans (of_decide_eq_true xy) (of_decide_eq_true yz))
    · intro x y
      simp only [Bool.or_eq_true,decide_eq_true_eq]
      exact Std.le_total
  have n := ((List.mergeSort_perm xs (keyOrder k)).symm.map (keys k)).nodup nd
  have pw : ((xs.mergeSort (keyOrder k)).map (keys k)).Pairwise (· ≤ ·) := List.pairwise_map.mpr ord
  exact (pw.and n).imp (fun h => Std.lt_of_le_of_ne h.1 h.2)

noncomputable def admission (k : ε → AtomKey) (auth : List ε → Bool) (weak : ε → ε → Prop)
    (raw : Family ε) : Family ε :=
  (prune k weak (raw.foldl (putRepresentative k auth) [])).mergeSort (keyOrder k)

theorem constructor_invariants (k : ε → AtomKey) (auth : List ε → Bool) (weak : ε → ε → Prop)
    (raw : Family ε) (wr : Width n raw) :
    let F := admission k auth weak raw
    Width n F ∧ AntiKeys k weak F ∧ (F.map (keys k)).Pairwise (List.Lex (· < ·)) := by
  classical
  let xs := raw.foldl (putRepresentative k auth) []
  have hg := grouped_admits k auth raw [] wr (by simp [Width]) (by simp)
  have nd : (xs.map (keys k)).Nodup := hg.1
  have ts : (prune k weak xs).Sublist xs := List.filter_sublist
  have kept : ((prune k weak xs).map (keys k)).Nodup := nd.sublist (ts.map _)
  constructor
  · intro x hx
    exact hg.2 x (ts.subset (List.mem_mergeSort.mp hx))
  constructor
  · intro x hx y hy equiv
    exact prune_antichain k weak xs x (List.mem_mergeSort.mp hx) y (List.mem_mergeSort.mp hy) equiv
  · exact sorted_keys k _ kept

theorem constructor_arrow_exact (k : ε → AtomKey) (auth : List ε → Bool) (weak : ε → ε → Prop)
    (left right : Family ε) (wl : Width m left) (wr : Width n right) :
    let l := admission k auth weak left
    let r := admission k auth weak right
    normalizeEvidence k weak (· < ·) (matrix l r) = matrix l r := by
  obtain ⟨w,a,s⟩ := constructor_invariants k auth weak left wl
  obtain ⟨_,b,t⟩ := constructor_invariants k auth weak right wr
  exact normalize_preserves_actual_evidence k w List.lt_irrefl a b s t

#print axioms put_keys
#print axioms put_admits
#print axioms grouped_admits
#print axioms prune_antichain
#print axioms sorted_keys
#print axioms constructor_invariants
#print axioms constructor_arrow_exact

theorem grouped_on_unique (k : ε → AtomKey) (auth : List ε → Bool) (raw acc : Family ε)
    (nd : ((acc ++ raw).map (keys k)).Nodup) :
    raw.foldl (putRepresentative k auth) acc = acc ++ raw := by
  induction raw generalizing acc with
  | nil => simp
  | cons x xs ih =>
    have dis := (List.nodup_append.mp (by simpa only [List.map_append] using nd)).2.2
    have fresh : keys k x ∉ acc.map (keys k) := by
      intro h
      exact dis _ h _ (List.mem_map.mpr ⟨x,List.mem_cons_self ..,rfl⟩) rfl
    have tail : (((acc ++ [x]) ++ xs).map (keys k)).Nodup := by simpa [List.append_assoc] using nd
    simp only [List.foldl_cons,putRepresentative,ite_eq_right (fun h => (fresh h).elim)]
    simpa [List.append_assoc] using ih _ tail

theorem admission_fixed (k : ε → AtomKey) (auth : List ε → Bool) (weak : ε → ε → Prop)
    (xs : Family ε) (a : AntiKeys k weak xs) (s : (xs.map (keys k)).Pairwise (List.Lex (· < ·))) :
    admission k auth weak xs = xs := by
  classical
  have nd : (xs.map (keys k)).Nodup := s.imp (fun h eq => by subst_vars; exact List.lt_irrefl _ h)
  have g : xs.foldl (putRepresentative k auth) [] = xs := by
    simpa using grouped_on_unique k auth xs [] (by simpa using nd)
  simp only [admission,g,prune]
  rw [List.filter_eq_self.mpr (fun x hx => decide_eq_true (a x hx))]
  apply List.mergeSort_of_pairwise
  exact (List.pairwise_map.mp s).imp (fun h => decide_eq_true (List.le_of_lt h))

theorem constructor_to_constructor (k : ε → AtomKey) (auth : List ε → Bool) (weak : ε → ε → Prop)
    (left right : Family ε) (wl : Width m left) (wr : Width n right) :
    let l := admission k auth weak left
    let r := admission k auth weak right
    admission k auth weak (matrix l r) = matrix l r := by
  obtain ⟨w,a,s⟩ := constructor_invariants k auth weak left wl
  obtain ⟨_,b,t⟩ := constructor_invariants k auth weak right wr
  apply admission_fixed
  · exact evidence_absorption k w a b
  · rw [mapped_matrix]
    apply row_major_is_sorted (n := m) _ s t
    intro x hx
    obtain ⟨y,hy,rfl⟩ := List.mem_map.mp hx
    simpa [keys] using w y hy

inductive Source (α : Type) | leaf (value : α) | arrow (left right : Source α)

def leaves : Source α → List α
  | .leaf x => [x]
  | .arrow l r => leaves l ++ leaves r

def located : Source α → List (List Bool × α)
  | .leaf x => [([],x)]
  | .arrow l r => (located l).map (fun a => (false :: a.1,a.2)) ++
      (located r).map (fun a => (true :: a.1,a.2))

theorem source_occurrence_order (t : Source α) :
    (located t).map Prod.snd = leaves t := by
  induction t with
  | leaf => rfl
  | arrow l r ih jh => simp [located,leaves,List.map_map,Function.comp_def,←ih,←jh]

theorem source_leaf_multiplicity [DecidableEq α] (x : α) (l r : Source α) :
    ((located (.arrow l r)).map Prod.snd).count x =
    (leaves l).count x + (leaves r).count x := by
  rw [source_occurrence_order,leaves,List.count_append]

#print axioms grouped_on_unique
#print axioms admission_fixed
#print axioms constructor_to_constructor
#print axioms source_occurrence_order
#print axioms source_leaf_multiplicity

inductive Atomic | int | nominal (utf16 : List (Fin 65536))

def atomCode : Atomic → AtomKey | .int => intKey | .nominal s => nominalKey s

def javaLess : Atomic → Atomic → Prop
  | .int, .int => False
  | .int, .nominal _ => True
  | .nominal _, .int => False
  | .nominal s, .nominal t => s.map Fin.val < t.map Fin.val

theorem admitted_atomic_comparator (x y : Atomic) : javaLess x y ↔ atomCode x < atomCode y := by
  cases x <;> cases y <;> simp [javaLess,atomCode,intKey,nominalKey,List.cons_lt_cons_iff]

-- Compare the shared prefix by exact atomic key and break an equal-prefix
-- tie by length, as GraphType.compareTo does for two relation products.
def productLess : List AtomKey → List AtomKey → Prop
  | [], [] => False
  | [], _ :: _ => True
  | _ :: _, [] => False
  | x :: xs, y :: ys => x < y ∨ x = y ∧ productLess xs ys

theorem relation_product_comparator (x y : List AtomKey) : productLess x y ↔ x < y := by
  induction x generalizing y with
  | nil => cases y <;> simp [productLess]
  | cons a as ih => cases y <;> simp [productLess,List.cons_lt_cons_iff,ih]

theorem registered_complete_result (stream : List String) (acceptedStream : accepted stream = true)
    (k : ε → AtomKey) (auth : List ε → Bool) (weak : ε → ε → Prop)
    (left right : Family ε) (wl : Width m left) (wr : Width n right) :
    let l := admission k auth weak left
    let r := admission k auth weak right
    (execute stream l r).map (admission k auth weak) = some (matrix l r) := by
  dsimp only
  rw [accepted_compiler_stream_refines _ _ _ acceptedStream]
  exact congrArg some (constructor_to_constructor k auth weak left right wl wr)

#print axioms admitted_atomic_comparator
#print axioms relation_product_comparator
#print axioms registered_complete_result
end ACGN.Eighth.A223

def main (args : List String) : IO UInt32 := do
  let [path] := args | return 2
  let raw ← IO.FS.readFile path
  let lines := (raw.trimAsciiEnd.toString.splitOn "\n")
  if ACGN.Eighth.A223.accepted lines then
    IO.println "A223 compiler program verified"
    return 0
  IO.println "A223 compiler program rejected"
  return 1
