import Init

namespace ACGN.Ninth.A221
-- Shares the eighth A2-23 structural atom encoding, paired coordinate relation,
-- and exact lexicographic key order without importing its executable driver.
abbrev AtomKey := List Nat

def Weak (le : α → α → Prop) : List α → List α → Prop
  | [], [] => True
  | a :: as, b :: bs => le a b ∧ Weak le as bs
  | _, _ => False

def keyOrder (k : α → AtomKey) (x y : List α) := decide (x.map k ≤ y.map k)

noncomputable def maximal (D : ρ → ρ → Prop) (rows : List ρ) := by
  classical
  exact rows.filter fun p => decide (¬ ∃ q ∈ rows, D p q)

theorem member_maximal {D : ρ → ρ → Prop} {rows : List ρ} {p : ρ} :
    p ∈ maximal D rows ↔ p ∈ rows ∧ ¬ ∃ q ∈ rows, D p q := by
  classical
  simp [maximal]

-- Move to a strictly more general represented product until a maximal one is
-- reached. No transitivity or completeness of the implementation test is assumed.
theorem maximal_preserves_denotation {rows : List ρ} (D : ρ → ρ → Prop) (rank : ρ → Nat)
    (denotes : ρ → τ → Prop)
    (decreases : ∀ p ∈ rows, ∀ q ∈ rows, D p q → rank q < rank p)
    (sound : ∀ p ∈ rows, ∀ q ∈ rows, D p q → ∀ w, denotes p w → denotes q w)
    (w : τ) : (∃ p ∈ maximal D rows, denotes p w) ↔ ∃ p ∈ rows, denotes p w := by
  classical
  constructor
  · rintro ⟨p,hm,hd⟩
    exact ⟨p,(member_maximal.mp hm).1,hd⟩
  · rintro ⟨p,hp,hd⟩
    have descend : ∀ n, ∀ p ∈ rows, rank p = n → denotes p w → ∃ q ∈ maximal D rows, denotes q w := by
      intro n
      induction n using Nat.strongRecOn with
      | ind n ih =>
        intro x hx hn hw
        by_cases exc : ∃ y ∈ rows, D x y
        · obtain ⟨y,hy,hxy⟩ := exc
          exact ih (rank y) (hn ▸ decreases x hx y hy hxy) y hy rfl (sound x hx y hy hxy w hw)
        · exact ⟨x,member_maximal.mpr ⟨hx,exc⟩,hw⟩
    exact descend _ p hp rfl hd

structure Column where
  atom : AtomKey
  parents : List AtomKey
  moduleId : Option Nat
  deriving DecidableEq

abbrev Product := List Column
abbrev Key := List AtomKey
def key (r : Product) : Key := r.map Column.atom
def authenticated (c : Column) := c.moduleId.isSome

def pick (a b : Column) := if !authenticated a && authenticated b then b else a

theorem pick_origin (a b : Column) : pick a b = a ∨ pick a b = b := by
  unfold pick; split <;> simp

theorem pick_authority (a b : Column) :
    authenticated (pick a b) = (authenticated a || authenticated b) := by
  cases ha : authenticated a <;> cases hb : authenticated b <;> simp [pick,ha,hb]

def merge : Product → Product → Product
  | a :: as, b :: bs => pick a b :: merge as bs
  | [], _ => []
  | _ :: _, [] => []

theorem merge_key {a b : Product} (h : key a = key b) : key (merge a b) = key a := by
  induction a generalizing b with
  | nil => rfl
  | cons a as ih =>
    cases b with
    | nil => simp [key] at h
    | cons b bs =>
      obtain ⟨h₁,h₂⟩ := List.cons.inj h
      change (pick a b).atom :: key (merge as bs) = a.atom :: key as
      rcases pick_origin a b with hp|hp <;> simp [hp,h₁,ih h₂]

def covered (xs : Product) (i : Nat) : Bool :=
  (xs[i]?.map authenticated).getD false

theorem merge_covers {a b : Product} (h : key a = key b) (i : Nat) :
    covered (merge a b) i = (covered a i || covered b i) := by
  induction a generalizing b i with
  | nil => cases b <;> simp_all [key,merge,covered]
  | cons a as ih =>
    cases b with
    | nil => simp [key] at h
    | cons b bs =>
      obtain ⟨_,ht⟩ := List.cons.inj h
      cases i with
      | zero => exact pick_authority a b
      | succ j => exact ih ht j

-- In the map semantics each lookup is independent, so missing queries never
-- affect other keys. Insertion order is unobservable after structural sorting.
def update (q : Key) (s : Option Product) (p : Product) : Option Product :=
  if key p = q then some (s.elim p (fun previous => merge previous p)) else s

def representative (q : Key) (rows : List Product) := rows.foldl (update q) none

theorem fold_presence (q : Key) (rows : List Product) (s : Option Product) :
    (rows.foldl (update q) s).isSome = true ↔ s.isSome = true ∨ ∃ p ∈ rows, key p = q := by
  induction rows generalizing s with
  | nil => simp
  | cons p ps ih =>
    simp only [List.foldl_cons,ih]
    by_cases hit : key p = q <;> simp [update,hit]

theorem fold_key (q : Key) (rows : List Product) {s : Option Product}
    (h : ∀ p, s = some p → key p = q) :
    ∀ p, rows.foldl (update q) s = some p → key p = q := by
  induction rows generalizing s with
  | nil => exact h
  | cons r rs ih =>
    apply ih
    intro x hx
    by_cases he : key r = q
    · cases s with
      | none => simp [update,he] at hx; simpa [←hx] using he
      | some prior =>
        have hp := h prior rfl
        simp [update,he] at hx
        simpa [←hx,merge_key (hp.trans he.symm)] using hp
    · exact h x (by simpa [update,he] using hx)

def hasAt (s : Option Product) (i : Nat) : Bool := s.elim false (covered · i)

theorem fold_coverage (q : Key) (i : Nat) (rows : List Product) {s : Option Product}
    (h : ∀ p, s = some p → key p = q) :
    hasAt (rows.foldl (update q) s) i = true ↔
      hasAt s i = true ∨ ∃ p ∈ rows, key p = q ∧ covered p i = true := by
  induction rows generalizing s with
  | nil => simp
  | cons r rs ih =>
    have next : ∀ p, update q s r = some p → key p = q := fold_key q [r] h
    simp only [List.foldl_cons,ih next]
    by_cases he : key r = q
    · cases s with
      | none => simp [update,he,hasAt]
      | some prior =>
        have hp := h prior rfl
        simp [update,he,hasAt,merge_covers (hp.trans he.symm),or_assoc]
    · simp [update,he]

def weak (a b : Column) : Prop :=
  a.atom = b.atom ∨ (∃ owner, a.moduleId = some owner ∧ b.moduleId = some owner ∧ b.atom ∈ a.parents)
def strict (p q : Product) : Prop := Weak weak p q ∧ key p ≠ key q

-- Distinct key enumeration. The insertion order used by LinkedHashMap does
-- not affect the group lookup or the final structural sort.
def distinct [DecidableEq α] : List α → List α
  | [] => []
  | p :: ps => if p ∈ ps then distinct ps else p :: distinct ps

theorem mem_distinct [DecidableEq α] (l : List α) (x : α) : x ∈ distinct l ↔ x ∈ l := by
  induction l with
  | nil => simp [distinct]
  | cons h t ih =>
    by_cases hh : h ∈ t
    · simp only [distinct,ite_eq_left hh,ih,List.mem_cons]
      exact ⟨Or.inr,fun a => a.elim (fun e => e ▸ hh) id⟩
    · simp [distinct,hh,ih]

theorem distinct_keys [DecidableEq α] (l : List α) : (distinct l).Nodup := by
  induction l with
  | nil => simp [distinct]
  | cons h t ih => by_cases hh : h ∈ t <;> simp [distinct,hh,ih,mem_distinct]

noncomputable def groups (raw : List Product) := (distinct (raw.map key)).filterMap (fun q => representative q raw)
noncomputable def normalize (raw : List Product) :=
  (maximal strict (groups raw)).mergeSort (keyOrder Column.atom)

theorem representative_present (raw : List Product) (q : Key) :
    (representative q raw).isSome = true ↔ ∃ p ∈ raw, key p = q := by
  simpa [representative] using fold_presence q raw none

theorem representative_coverage (raw : List Product) (q : Key) (i : Nat) :
    hasAt (representative q raw) i = true ↔ ∃ p ∈ raw, key p = q ∧ covered p i = true := by
  simpa [representative,hasAt] using fold_coverage q i raw (s:=none) (by simp)

theorem exact_group (raw : List Product) {r : Product} :
    r ∈ groups raw ↔ representative (key r) raw = some r := by
  constructor
  · intro h
    obtain ⟨q,_,hv⟩ := List.mem_filterMap.mp h
    have hkey := fold_key q raw (s:=none) (by simp) r hv
    simpa [hkey] using hv
  · intro hv
    have hp : (representative (key r) raw).isSome = true := by simp [hv]
    obtain ⟨p,hp,he⟩ := (representative_present raw _).mp hp
    exact List.mem_filterMap.mpr ⟨key r,(mem_distinct _ _).mpr (List.mem_map.mpr ⟨p,hp,he⟩),hv⟩

theorem exact_survival (raw : List Product) (r : Product) :
    r ∈ normalize raw ↔ representative (key r) raw = some r ∧
      ¬ ∃ q, representative (key q) raw = some q ∧ strict r q := by
  simp only [normalize,List.mem_mergeSort,member_maximal,exact_group]

theorem absent_key_iff_strict (raw : List Product) {k : Key} {r : Product}
    (rep : representative k raw = some r) :
    (¬ ∃ p ∈ normalize raw, key p = k) ↔
       ∃ q, representative (key q) raw = some q ∧ strict r q := by
  classical
  have rk := fold_key k raw (s:=none) (by simp) r rep
  constructor
  · intro h
    apply Classical.byContradiction
    intro absent
    exact h ⟨r,(exact_survival raw r).mpr ⟨by simpa [rk] using rep,absent⟩,rk⟩
  · rintro ⟨q,hq,hd⟩ ⟨p,hp,pk⟩
    obtain ⟨ps,hn⟩ := (exact_survival raw p).mp hp
    have eq : r = p := Option.some.inj (rep.symm.trans (pk ▸ ps))
    exact hn ⟨q,hq,eq ▸ hd⟩

theorem different_coordinates (p q : Product) : strict p q → key p ≠ key q := And.right

theorem survivors_incomparable (raw : List Product) {p q : Product}
    (hp : p ∈ normalize raw) (hq : q ∈ normalize raw) : ¬ strict p q := by
  intro hd
  exact ((exact_survival raw p).mp hp).2 ⟨q,((exact_survival raw q).mp hq).1,hd⟩

theorem no_duplicate_keys (raw : List Product) : ((normalize raw).map key).Nodup := by
  classical
  have grouped : (groups raw).Pairwise (fun a b => key a ≠ key b) := by
    apply List.Pairwise.filterMap _ _ (distinct_keys (raw.map key))
    intro k l h a ha b hb hEq
    exact h (((fold_key k raw (s:=none) (by simp) a ha).symm.trans hEq).trans
      (fold_key l raw (s:=none) (by simp) b hb))
  have subsets : (maximal strict (groups raw)).Pairwise (fun a b => key a ≠ key b) :=
    grouped.sublist (List.filter_sublist)
  have perm := (List.mergeSort_perm (maximal strict (groups raw)) (keyOrder Column.atom)).map key
  exact perm.nodup_iff.mpr (List.pairwise_map.mpr subsets)

theorem fold_foreign (k : Key) (rows : List Product) (h : ∀ p ∈ rows, key p ≠ k)
    (s : Option Product) : rows.foldl (update k) s = s := by
  induction rows generalizing s with
  | nil => rfl
  | cons r rs ih =>
    have hf := h r (List.mem_cons_self ..)
    simp [update,hf,ih (fun p hp => h p (List.mem_cons_of_mem _ hp))]

theorem single_occurrence (before after : List Product) (r : Product)
    (first : ∀ p ∈ before, key p ≠ key r) (last : ∀ p ∈ after, key p ≠ key r) :
    representative (key r) (before ++ r :: after) = some r := by
  simp [representative,List.foldl_append,fold_foreign _ before first,update,
    fold_foreign _ after last]

theorem unique_row_survival (before after : List Product) (r : Product)
    (first : ∀ p ∈ before, key p ≠ key r) (last : ∀ p ∈ after, key p ≠ key r) :
    r ∈ normalize (before ++ r :: after) ↔
    ¬ ∃ q ∈ groups (before ++ r :: after), strict r q := by
  simp only [exact_survival,single_occurrence before after r first last,exact_group,true_and]

theorem weak_unequal_iff_authenticated {a b : Column} (h : a.atom ≠ b.atom) :
    weak a b ↔ ∃ owner, a.moduleId = some owner ∧ b.moduleId = some owner ∧ b.atom ∈ a.parents := by
  simp [weak,h]

theorem sibling_retained {raw : List Product} {r : Product}
    (present : r ∈ groups raw) (uncontested : ∀ q ∈ groups raw, ¬ strict r q) :
    r ∈ normalize raw := by
  exact (exact_survival raw r).mpr ⟨(exact_group raw).mp present,fun ⟨q,h,d⟩ =>
    uncontested q ((exact_group raw).mpr h) d⟩

theorem normalized_key_from_input {raw : List Product} {r : Product} (h : r ∈ normalize raw) :
    ∃ p ∈ raw, key p = key r := by
  apply (representative_present raw _).mp
  simp [((exact_survival raw r).mp h).1]

theorem structural_order (raw : List Product) :
    ((normalize raw).map key).Pairwise (List.Lex (· < ·)) := by
  have ordered : (normalize raw).Pairwise (fun x y => key x ≤ key y) := by
    apply List.Pairwise.imp (fun h => of_decide_eq_true h)
    apply List.pairwise_mergeSort
    · intro x y z h1 h2
      exact decide_eq_true (Std.le_trans (of_decide_eq_true h1) (of_decide_eq_true h2))
    · intro x y
      simp only [Bool.or_eq_true,decide_eq_true_eq]
      exact Std.le_total
  have mapped : ((normalize raw).map key).Pairwise (· ≤ ·) := List.pairwise_map.mpr ordered
  exact (mapped.and (no_duplicate_keys raw)).imp (fun h => Std.lt_of_le_of_ne h.1 h.2)

#print axioms sibling_retained
#print axioms normalized_key_from_input
#print axioms structural_order

theorem merge_origin {a b : Product} (h : key a = key b) (i : Nat) {c : Column}
    (hm : (merge a b)[i]? = some c) : a[i]? = some c ∨ b[i]? = some c := by
  induction a generalizing b i with
  | nil => simp [merge] at hm
  | cons a as ih =>
    cases b with
    | nil => simp [key] at h
    | cons b bs =>
      obtain ⟨_,ht⟩ := List.cons.inj h
      cases i with
      | zero =>
        change some (pick a b) = some c at hm
        cases Option.some.inj hm
        rcases pick_origin a b with e|e <;> simp [e]
      | succ j => exact ih ht j hm

theorem fold_origin (k : Key) (rows : List Product) {s : Option Product}
    (valid : ∀ p, s = some p → key p = k) (i : Nat) {r : Product} {c : Column}
    (rep : rows.foldl (update k) s = some r) (atPort : r[i]? = some c) :
    (∃ p, s = some p ∧ p[i]? = some c) ∨ (∃ p ∈ rows, key p = k ∧ p[i]? = some c) := by
  induction rows generalizing s with
  | nil => exact Or.inl ⟨r,rep,atPort⟩
  | cons a as ih =>
    have next : ∀ p, update k s a = some p → key p = k := fold_key k [a] valid
    rcases ih next rep with h|⟨p,hp,hk,hi⟩
    · obtain ⟨p,hp,hi⟩ := h
      by_cases matchK : key a = k
      · cases s with
        | none =>
          simp [update,matchK] at hp
          exact Or.inr ⟨a,List.mem_cons_self ..,matchK,hp ▸ hi⟩
        | some old =>
          simp [update,matchK] at hp
          have merged := merge_origin ((valid old rfl).trans matchK.symm) i (hp ▸ hi)
          exact merged.elim (fun h => Or.inl ⟨old,rfl,h⟩)
            (fun h => Or.inr ⟨a,List.mem_cons_self ..,matchK,h⟩)
      · exact Or.inl ⟨p,by simpa [update,matchK] using hp,hi⟩
    · exact Or.inr ⟨p,List.mem_cons_of_mem _ hp,hk,hi⟩

theorem representative_origin (raw : List Product) {k : Key} {r : Product} {c : Column}
    (rep : representative k raw = some r) (i : Nat) (atPort : r[i]? = some c) :
    ∃ p ∈ raw, key p = k ∧ p[i]? = some c := by
  simpa using fold_origin k raw (s:=none) (by simp) i rep atPort

#print axioms merge_origin
#print axioms fold_origin
#print axioms representative_origin

-- Executable coordinate comparison. The nonexact branch can succeed only for
-- one live module and a positive parent position. A different key in at least
-- one port makes the product comparison strict.
def edge (a b : Column) : Bool :=
  if a.atom = b.atom then true else
  match a.moduleId, b.moduleId with
  | some x, some y => decide (x = y ∧ b.atom ∈ a.parents)
  | _, _ => false

theorem edge_weak (a b : Column) : edge a b = true ↔ weak a b := by
  by_cases eq : a.atom = b.atom
  · simp [edge,weak,eq]
  · cases hx : a.moduleId <;> cases hy : b.moduleId <;>
      simp [edge,weak,eq,hx,hy] <;> exact fun _ => eq_comm

def weakRows : Product → Product → Bool
  | [], [] => true
  | a :: as, b :: bs => edge a b && weakRows as bs
  | _, _ => false

theorem weakRows_spec (p q : Product) : weakRows p q = true ↔ Weak weak p q := by
  induction p generalizing q with
  | nil => cases q <;> simp [weakRows,Weak]
  | cons a as ih => cases q <;> simp [weakRows,Weak,edge_weak,ih]

def strictRows (p q : Product) := weakRows p q && decide (key p ≠ key q)

theorem strictRows_spec (p q : Product) : strictRows p q = true ↔ strict p q := by
  simp [strictRows,strict,weakRows_spec]

def run (raw : List Product) : List Product :=
  let rows := (distinct (raw.map key)).filterMap fun k => representative k raw
  (rows.filter fun p => !(rows.any (strictRows p))).mergeSort (keyOrder Column.atom)

theorem run_normalizes (raw : List Product) : run raw = normalize raw := by
  classical
  dsimp only [run,normalize,maximal,groups]
  apply congrArg (fun xs : List Product => xs.mergeSort (keyOrder Column.atom))
  apply List.filter_congr
  intro p _
  apply Bool.eq_iff_iff.mpr
  change ((!List.any _ (strictRows p)) = true) ↔ (decide _ = true)
  rw [decide_eq_true_eq]
  change (!(List.any _ (strictRows p))) = true ↔ ¬ _
  rw [Bool.not_eq_true']
  rw [Bool.eq_false_iff]
  simp only [ne_eq,List.any_eq_true,strictRows_spec]

#print axioms edge_weak
#print axioms weakRows_spec
#print axioms strictRows_spec
#print axioms run_normalizes
#print axioms mem_distinct
#print axioms distinct_keys
#print axioms different_coordinates
#print axioms survivors_incomparable
#print axioms no_duplicate_keys
#print axioms fold_foreign
#print axioms single_occurrence
#print axioms unique_row_survival
#print axioms weak_unequal_iff_authenticated
#print axioms member_maximal
#print axioms maximal_preserves_denotation
#print axioms pick_origin
#print axioms pick_authority
#print axioms merge_key
#print axioms merge_covers
#print axioms fold_presence
#print axioms fold_key
#print axioms fold_coverage
#print axioms representative_present
#print axioms representative_coverage
#print axioms exact_group
#print axioms exact_survival
#print axioms absent_key_iff_strict
end ACGN.Ninth.A221


-- The witness supplies a local, order-preserving rank for each distinct exact
-- graph type and its own module token. Column boundaries remain explicit.
private def readColumn (s : String) : Option ACGN.Ninth.A221.Column := do
  let [a, m, ancestors] := s.splitOn "/" | none
  let id ← a.toNat?
  let mod ← m.toNat?
  let owner ← if mod = 0 then some none else if mod = 1 then some (some 0) else none
  let parents ← if ancestors = "_" then some [] else (ancestors.splitOn ",").mapM String.toNat?
  return ⟨[id],parents.map (fun x => [x]),owner⟩

private def readRows (s : String) : Option (List ACGN.Ninth.A221.Product) :=
  if s = "-" then some [] else (s.splitOn ";").mapM fun r => (r.splitOn "|").mapM readColumn

private def checkTrace (line : String) : Bool := Id.run do
  let [_, ins, outs] := line.splitOn "\t" | return false
  let some input := readRows ins | return false
  let some result := readRows outs | return false
  return decide (ACGN.Ninth.A221.run input = result)

def main (args : List String) : IO UInt32 := do
  let [p] := args | return 2
  let lines := (← IO.FS.readFile p).splitOn "\n"
  let rows := lines.dropLast
  if lines.getLast? = some "" && !rows.isEmpty && rows.all checkTrace then
    IO.println s!"A221 typed normalization traces verified {rows.length}"
    return 0
  IO.println "A221 typed normalization trace rejected"
  return 1
