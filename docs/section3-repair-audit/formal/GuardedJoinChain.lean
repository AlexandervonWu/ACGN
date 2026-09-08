import DependentChainSequence
import DependentJoinGuard
import PhaseA2DependentChains

/-!
A2-04. Set-valued relational JOIN, not equality of flattened operand lists.
Homogeneous means every source application has head JOIN. Relations may be
infinite or empty. Column predicates are explicit; no missing type means univ.
See third-five/join-notes.md for the compiler/execution correspondence boundary.
-/
namespace ACGN.ThirdFive.GuardedJoinChain
open ACGN.Section3.DependentChainSequence
open ACGN.BoundedFive.DependentJoinGuard (guard join_guard_iff)

abbrev Relation (Atom : Type) := List Atom -> Prop

def join (R S : Relation Atom) (out : List Atom) : Prop :=
  exists pre boundary suffix,
    R (pre ++ [boundary]) ∧ S (boundary :: suffix) ∧ out = pre ++ suffix

theorem join_congr {R R' S S' : Relation Atom}
    (left : ∀ x, R x ↔ R' x) (right : ∀ x, S x ↔ S' x) (out : List Atom) :
    join R S out ↔ join R' S' out := by
  simp only [join, left, right]

theorem join_rotation (R S T : Relation Atom)
    (wide : ∀ row, S row -> 2 <= row.length) (out : List Atom) :
    join (join R S) T out ↔ join R (join S T) out := by
  constructor
  · rintro ⟨ab, c, zs, ⟨xs, b, ys, hR, hS, eq⟩, hT, rfl⟩
    have hy : ys ≠ [] := by intro h; subst ys; have := wide _ hS; simp at this
    obtain ⟨mid, d, eqy⟩ := (List.eq_nil_or_concat ys).resolve_left hy
    simp only [List.concat_eq_append] at eqy
    subst ys
    have parts := List.append_inj' (eq.trans (List.append_assoc _ _ _).symm) rfl
    have dc : c = d := by simpa using parts.2
    subst d
    rw [parts.1]
    exact ⟨xs, b, mid ++ zs, hR,
      ⟨b :: mid, c, zs, hS, hT, rfl⟩, List.append_assoc _ _ _⟩
  · rintro ⟨xs, b, yz, hR, ⟨bs, c, zs, hS, hT, eq⟩, rfl⟩
    have hn : bs ≠ [] := by intro h; subst bs; have := wide _ hS; simp at this
    cases bs with
    | nil => exact False.elim (hn rfl)
    | cons d mid =>
      have parts : b = d ∧ yz = mid ++ zs := by simpa using eq
      rcases parts with ⟨rfl, rfl⟩
      exact ⟨xs ++ mid, c, zs,
        ⟨xs, b, mid ++ [c], hR, hS, List.append_assoc _ _ _⟩,
        hT, (List.append_assoc _ _ _).symm⟩

-- A correlated family can use any predicate, provided every admitted tuple
-- has its retained arity. Typed empty families satisfy this vacuously.
structure Operand (Atom : Type) where
  arity : Nat
  positive : 0 < arity
  relation : Relation Atom
  width : ∀ row, relation row -> row.length = arity

abbrev Tree (Atom : Type) := SourceTree (Operand Atom) .join

def eval : Tree Atom -> Relation Atom
  | .leaf a => a.relation
  | .app _ l r => join (eval l) (eval r)

def guarded (t : Tree Atom) : Prop :=
  ∀ pre a post, sourceLeaves t = pre ++ a :: post ->
    pre ≠ [] -> post ≠ [] -> 2 <= a.arity

theorem leaves_nonempty (t : SourceTree α k) : sourceLeaves t ≠ [] := by
  induction t with
  | leaf a => simp [sourceLeaves]
  | app l r hl _ => simp [sourceLeaves, hl]

theorem guarded_left {l r : Tree Atom} (h : guarded (.app .join l r)) : guarded l := by
  intro pre a post eq hp hs
  apply h pre a (post ++ sourceLeaves r)
  · simp [sourceLeaves, eq, List.append_assoc]
  · exact hp
  · simp [hs]

theorem guarded_right {l r : Tree Atom} (h : guarded (.app .join l r)) : guarded r := by
  intro pre a post eq hp hs
  apply h (sourceLeaves l ++ pre) a post
  · simp [sourceLeaves, eq, List.append_assoc]
  · simp [hp]
  · exact hs

theorem wide_eval (t : Tree Atom)
    (wide : ∀ a, a ∈ sourceLeaves t -> 2 <= a.arity) :
    ∀ row, eval t row -> 2 <= row.length := by
  induction t with
  | leaf a =>
    intro row h
    rw [a.width row h]
    exact wide a (by simp [sourceLeaves])
  | app l r hl hr =>
    intro row h
    obtain ⟨pre, b, suffix, hL, hR, rfl⟩ := h
    have left := hl (fun a ha => wide a (by simp [sourceLeaves, ha])) _ hL
    have right := hr (fun a ha => wide a (by simp [sourceLeaves, ha])) _ hR
    simp only [List.length_append, List.length_cons, List.length_nil] at *
    omega

theorem middle_wide {l m r : Tree Atom}
    (h : guarded (.app .join (.app .join l m) r)) :
    ∀ a, a ∈ sourceLeaves m -> 2 <= a.arity := by
  intro a ha
  obtain ⟨pre, post, eq⟩ := List.eq_append_cons_of_mem ha
  apply h (sourceLeaves l ++ pre) a (post ++ sourceLeaves r)
  · simp [sourceLeaves, eq, List.append_assoc]
  · simp [leaves_nonempty l]
  · simp [leaves_nonempty r]

-- Unconditional *syntactic* rotations. Semantic preservation below is guarded.
inductive Reassociate : SourceTree α .join -> SourceTree α .join -> Prop where
  | refl (t) : Reassociate t t
  | rotate (l m r) : Reassociate (.app .join (.app .join l m) r)
      (.app .join l (.app .join m r))
  | left {l l'} (r) : Reassociate l l' ->
      Reassociate (.app .join l r) (.app .join l' r)
  | right (l) {r r'} : Reassociate r r' ->
      Reassociate (.app .join l r) (.app .join l r')
  | symm {s t} : Reassociate s t -> Reassociate t s
  | trans {s t u} : Reassociate s t -> Reassociate t u -> Reassociate s u

theorem reassociate_leaves {s t : SourceTree α .join} (h : Reassociate s t) :
    sourceLeaves s = sourceLeaves t := by
  induction h with
  | refl => rfl
  | rotate => simp [sourceLeaves, List.append_assoc]
  | left _ _ ih => simp [sourceLeaves, ih]
  | right _ _ ih => simp [sourceLeaves, ih]
  | symm _ ih => exact ih.symm
  | trans _ _ ih ij => exact ih.trans ij

theorem reassociate_guard {s t : Tree Atom} (h : Reassociate s t) :
    guarded s ↔ guarded t := by
  unfold guarded
  rw [reassociate_leaves h]

theorem rotations_preserve_relations {s t : Tree Atom} (h : Reassociate s t)
    (licensed : guarded s) (out : List Atom) : eval s out ↔ eval t out := by
  induction h generalizing out with
  | refl => rfl
  | rotate l m r => exact join_rotation _ _ _ (wide_eval m (middle_wide licensed)) out
  | left r _ ih =>
    exact join_congr (fun x => ih (guarded_left licensed) x) (fun _ => Iff.rfl) out
  | right l _ ih =>
    exact join_congr (fun _ => Iff.rfl) (fun x => ih (guarded_right licensed) x) out
  | symm h ih => exact (ih ((reassociate_guard h).mpr licensed) out).symm
  | trans h j ih ij => exact (ih licensed out).trans (ij ((reassociate_guard h).mp licensed) out)

def foldTree (xs : List α) (tail : SourceTree α .join) : SourceTree α .join :=
  xs.foldr (fun a r => .app .join (.leaf a) r) tail

theorem append_to_fold (l r : SourceTree α .join) :
    Reassociate (.app .join l r) (foldTree (sourceLeaves l) r) := by
  induction l generalizing r with
  | leaf a => exact .refl _
  | app l m hl hm =>
    have h := (Reassociate.rotate l m r).trans
      ((Reassociate.right l (hm r)).trans (hl _))
    simpa [sourceLeaves, foldTree, List.foldr_append] using h

theorem has_normal_form (t : SourceTree α .join) :
    ∃ pre last, sourceLeaves t = pre ++ [last] ∧
      Reassociate t (foldTree pre (.leaf last)) := by
  induction t with
  | leaf a => exact ⟨[], a, rfl, .refl _⟩
  | app l r _ hr =>
    obtain ⟨pre, last, eq, hr⟩ := hr
    refine ⟨sourceLeaves l ++ pre, last, ?_, ?_⟩
    · simp [sourceLeaves, eq, List.append_assoc]
    · have h := (Reassociate.right l hr).trans (append_to_fold l _)
      simpa [foldTree, List.foldr_append] using h

theorem rotations_complete (s t : SourceTree α .join)
    (same : sourceLeaves s = sourceLeaves t) : Reassociate s t := by
  obtain ⟨ps, a, hs, rs⟩ := has_normal_form s
  obtain ⟨pt, b, ht, rt⟩ := has_normal_form t
  have parts := List.append_inj' (hs.symm.trans (same.trans ht)) rfl
  have ab : a = b := by simpa using parts.2
  rw [parts.1, ab] at rs
  exact rs.trans rt.symm

theorem arbitrary_chain_relational_equality (s t : Tree Atom)
    (same : sourceLeaves s = sourceLeaves t) (licensed : guarded s) :
    eval s = eval t := by
  funext out
  exact propext (rotations_preserve_relations (rotations_complete s t same) licensed out)

-- The executable source guard is connected to the semantic hypothesis for
-- arbitrary arity lists, not just the bounded generated observations.
theorem guard_supplies_license (t : Tree Atom)
    (accepted : guard .JOIN ((sourceLeaves t).map Operand.arity) = true) : guarded t := by
  intro pre a post eq hp hs
  have all := (join_guard_iff _).mp accepted |>.2
  have bound : pre.length + 1 < ((sourceLeaves t).map Operand.arity).length := by
    simp [eq]
    have := List.length_pos_iff.mpr hs
    omega
  have checked := all pre.length (by have := List.length_pos_iff.mpr hp; omega) bound
  simpa [eq] using checked

theorem accepted_chain_relational_equality (s t : Tree Atom)
    (same : sourceLeaves s = sourceLeaves t)
    (accepted : guard .JOIN ((sourceLeaves s).map Operand.arity) = true) :
    eval s = eval t :=
  arbitrary_chain_relational_equality s t same (guard_supplies_license s accepted)

theorem guard_executable (arities : List Nat) : guard .JOIN arities =
    (decide (2 <= arities.length) &&
      ((arities.drop 1).dropLast.all fun arity => decide (2 <= arity))) := by
  apply Bool.eq_iff_iff.mpr
  rw [ACGN.BoundedFive.DependentJoinGuard.join_guard_iff_slice]
  simp only [Bool.and_eq_true, decide_eq_true_eq]

-- Exact column predicates refine Operand without weakening tuple semantics.
def typed (meaning : Col -> Atom -> Prop) : List Col -> List Atom -> Prop
  | [], [] => True
  | c :: cs, a :: rest => meaning c a ∧ typed meaning cs rest
  | _, _ => False

theorem typed_length (meaning : Col -> Atom -> Prop) (columns : List Col) (row : List Atom)
    (h : typed meaning columns row) : columns.length = row.length := by
  induction columns generalizing row with
  | nil => cases row <;> simp_all [typed]
  | cons c cs ih =>
    cases row with
    | nil => exact False.elim h
    | cons a rest => exact congrArg Nat.succ (ih rest h.2)

theorem typed_dropLast (meaning : Col -> Atom -> Prop) (cs : List Col) (row : List Atom)
    (h : typed meaning cs row) : typed meaning cs.dropLast row.dropLast := by
  induction cs generalizing row with
  | nil => cases row <;> simp_all [typed]
  | cons c cs ih =>
    cases row with
    | nil => exact False.elim h
    | cons a rest =>
      cases cs with
      | nil => cases rest <;> simp_all [typed]
      | cons d ds =>
        cases rest with
        | nil => exact False.elim h.2
        | cons b bs => exact ⟨h.1, ih _ h.2⟩

theorem typed_tail (meaning : Col -> Atom -> Prop) (cs : List Col) (row : List Atom)
    (h : typed meaning cs row) : typed meaning cs.tail row.tail := by
  cases cs <;> cases row <;> simp_all [typed]

theorem typed_append (meaning : Col -> Atom -> Prop) (cs ds : List Col) (xs ys : List Atom)
    (h : typed meaning cs xs) (j : typed meaning ds ys) : typed meaning (cs ++ ds) (xs ++ ys) := by
  induction cs generalizing xs with
  | nil => cases xs <;> simp_all [typed]
  | cons c cs ih =>
    cases xs with
    | nil => exact False.elim h
    | cons a rest => exact ⟨h.1, ih rest h.2⟩

theorem join_exact_columns (meaning : Col -> Atom -> Prop) (cs ds : List Col)
    (R S : Relation Atom) (left : ∀ row, R row -> typed meaning cs row)
    (right : ∀ row, S row -> typed meaning ds row) (out : List Atom)
    (h : join R S out) : typed meaning (cs.dropLast ++ ds.tail) out := by
  obtain ⟨pre, b, suffix, hR, hS, rfl⟩ := h
  have hl := typed_dropLast meaning cs _ (left _ hR)
  have hr := typed_tail meaning ds _ (right _ hS)
  simp only [List.dropLast_concat, List.tail_cons] at hl hr
  exact typed_append meaning _ _ _ _ hl hr

def resultColumns (columns : Operand Atom -> List Col) : Tree Atom -> List Col
  | .leaf a => columns a
  | .app _ l r => (resultColumns columns l).dropLast ++ (resultColumns columns r).tail

-- Alloy excludes nullary relation results. This side condition is separate
-- from the arity guard; the semantic theorem even holds for nullary outputs.
def wellTyped (columns : Operand Atom -> List Col) : Tree Atom -> Prop
  | .leaf a => (columns a).length = a.arity
  | .app _ l r => wellTyped columns l ∧ wellTyped columns r ∧
      0 < (resultColumns columns (.app .join l r)).length

theorem eval_exact_columns (meaning : Col -> Atom -> Prop) (columns : Operand Atom -> List Col)
    (t : Tree Atom) (leaves : ∀ a, a ∈ sourceLeaves t ->
      ∀ row, a.relation row -> typed meaning (columns a) row) (out : List Atom)
    (h : eval t out) : typed meaning (resultColumns columns t) out := by
  induction t generalizing out with
  | leaf a => exact leaves a (by simp [sourceLeaves]) out h
  | app l r hl hr =>
    exact join_exact_columns meaning _ _ _ _
      (hl (fun a ha => leaves a (by simp [sourceLeaves, ha])))
      (hr (fun a ha => leaves a (by simp [sourceLeaves, ha]))) out h

theorem well_typed_chain_equality (meaning : Col -> Atom -> Prop)
    (columns : Operand Atom -> List Col) (s t : Tree Atom)
    (sourceTyped : wellTyped columns s) (targetTyped : wellTyped columns t)
    (same : sourceLeaves s = sourceLeaves t)
    (accepted : guard .JOIN ((sourceLeaves s).map Operand.arity) = true)
    (leaves : ∀ a, a ∈ sourceLeaves s ->
      ∀ row, a.relation row -> typed meaning (columns a) row) :
    wellTyped columns s ∧ wellTyped columns t ∧ eval s = eval t ∧
      ∀ row, eval s row -> typed meaning (resultColumns columns s) row ∧
        typed meaning (resultColumns columns t) row := by
  have eq := accepted_chain_relational_equality s t same accepted
  refine ⟨sourceTyped, targetTyped, eq, fun row h => ⟨eval_exact_columns meaning columns s leaves row h, ?_⟩⟩
  apply eval_exact_columns meaning columns t
  · simpa [same] using leaves
  · rw [← eq]; exact h

def exactOperand (meaning : Col -> Atom -> Prop) (columns : List Col)
    (positive : 0 < columns.length) (R : Relation Atom)
    (checked : ∀ row, R row -> typed meaning columns row) : Operand Atom :=
  ⟨columns.length, positive, R, fun row h => (typed_length meaning columns row (checked row h)).symm⟩

def emptyOperand (arity : Nat) (positive : 0 < arity) : Operand Atom :=
  ⟨arity, positive, fun _ => False, fun _ h => False.elim h⟩

theorem empty_join_left (R : Relation Atom) (out : List Atom) :
    ¬ join (fun _ => False) R out := by simp [join]

theorem empty_join_right (R : Relation Atom) (out : List Atom) :
    ¬ join R (fun _ => False) out := by simp [join]

theorem empty_leaf_annihilates (t : Tree Atom) (a : Operand Atom)
    (member : a ∈ sourceLeaves t) (empty : ∀ row, ¬ a.relation row)
    (out : List Atom) : ¬ eval t out := by
  induction t generalizing out with
  | leaf b =>
    have eq : a = b := by simpa [sourceLeaves] using member
    subst b
    exact empty out
  | app l r hl hr =>
    intro h
    obtain ⟨pre, b, suffix, hL, hR, _⟩ := h
    have cases : a ∈ sourceLeaves l ∨ a ∈ sourceLeaves r := by simpa [sourceLeaves] using member
    rcases cases with hm | hm
    · exact hl hm _ hL
    · exact hr hm _ hR

theorem explicit_univ_column (row : List Atom) :
    typed (fun (_ : Unit) (_ : Atom) => True) [()] row ↔ row.length = 1 := by
  cases row with
  | nil => simp [typed]
  | cons a tail => cases tail <;> simp [typed]

open ACGN.Section3.PhaseA2 (splitLast tupleJoin relationJoin)

theorem splitLast_spec (row pre : List Atom) (b : Atom) :
    splitLast row = some (pre, b) ↔ row = pre ++ [b] := by
  induction row generalizing pre b with
  | nil => simp [splitLast]
  | cons a rest ih =>
    cases rest with
    | nil => cases pre <;> simp [splitLast]
    | cons c cs =>
      cases e : splitLast (c :: cs) with
      | none =>
        have hn : ∀ xs : List Atom, xs ≠ [] -> splitLast xs ≠ none := by
          intro xs hx
          cases xs with
          | nil => contradiction
          | cons x xs => simp only [splitLast]; split <;> simp
        exact False.elim (hn _ (by simp) e)
      | some pair =>
        obtain ⟨ps, d⟩ := pair
        rw [splitLast, e]
        cases pre with
        | nil => simp
        | cons x xs =>
          simp only [Option.some.injEq, Prod.mk.injEq, List.cons_append,
            List.cons.injEq]
          rw [← ih]
          simp [e, eq_comm, and_assoc]

theorem tupleJoin_spec (left right out : List Nat) :
    tupleJoin left right = some out ↔
      ∃ pre b suffix, left = pre ++ [b] ∧ right = b :: suffix ∧ out = pre ++ suffix := by
  cases e : splitLast left with
  | none =>
    simp only [tupleJoin, e]
    simp only [reduceCtorEq, false_iff]
    rintro ⟨pre, b, suffix, eq, _, _⟩
    have := (splitLast_spec left pre b).mpr eq
    simp_all
  | some pair =>
    obtain ⟨pre, b⟩ := pair
    have hl := (splitLast_spec left pre b).mp e
    cases right with
    | nil => simp [tupleJoin, e]
    | cons c suffix =>
      simp only [tupleJoin, e]
      constructor
      · split
        next h =>
          intro eq
          have bc : b = c := by simpa using h
          exact ⟨pre, b, suffix, hl, by simp [bc], by simpa using eq.symm⟩
        next h => simp
      · rintro ⟨ps, d, zs, eq, hr, rfl⟩
        have parts := List.append_inj' (hl.symm.trans eq) rfl
        have bd : b = d := by simpa using parts.2
        have rest : c = d ∧ suffix = zs := by simpa using hr
        simp [parts.1, bd, rest.1, rest.2]

theorem finite_join_refines_relation (R S : List (List Nat)) (out : List Nat) :
    out ∈ relationJoin R S ↔ join (fun x => x ∈ R) (fun x => x ∈ S) out := by
  simp only [relationJoin, List.mem_flatMap, List.mem_filterMap, tupleJoin_spec]
  constructor
  · rintro ⟨left, hR, right, hS, pre, b, suffix, rfl, rfl, rfl⟩
    exact ⟨pre, b, suffix, hR, hS, rfl⟩
  · rintro ⟨pre, b, suffix, hR, hS, rfl⟩
    exact ⟨pre ++ [b], hR, b :: suffix, hS, pre, b, suffix, rfl, rfl, rfl⟩

def finiteEval (relations : List (List (List Nat))) : SourceTree Nat .join -> List (List Nat)
  | .leaf i => relations[i]?.getD []
  | .app _ l r => relationJoin (finiteEval relations l) (finiteEval relations r)

def interpret (values : Nat -> Operand Nat) : SourceTree Nat .join -> Tree Nat
  | .leaf i => .leaf (values i)
  | .app _ l r => .app .join (interpret values l) (interpret values r)

theorem finite_tree_refines_relation (relations : List (List (List Nat)))
    (values : Nat -> Operand Nat)
    (linked : ∀ (i : Nat) (row : List Nat), (values i).relation row ↔ row ∈ relations[i]?.getD [])
    (t : SourceTree Nat .join) (out : List Nat) :
    out ∈ finiteEval relations t ↔ eval (interpret values t) out := by
  induction t generalizing out with
  | leaf i => exact (linked i out).symm
  | app l r hl hr =>
    exact (finite_join_refines_relation _ _ out).trans (join_congr hl hr out)

def sameRelation (left right : List (List Nat)) : Bool :=
  left.all (fun row => decide (row ∈ right)) && right.all (fun row => decide (row ∈ left))

theorem sameRelation_iff (left right : List (List Nat)) :
    sameRelation left right = true ↔ ∀ row, row ∈ left ↔ row ∈ right := by
  simp only [sameRelation, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq]
  constructor
  · intro h row; exact ⟨h.1 row, h.2 row⟩
  · intro h; exact ⟨fun row => (h row).mp, fun row => (h row).mpr⟩

theorem unary_interior_counterexample :
    ¬ (ACGN.Section3.PhaseA2.relationJoin
      (ACGN.Section3.PhaseA2.relationJoin ACGN.Section3.PhaseA2.counterR ACGN.Section3.PhaseA2.counterS)
      ACGN.Section3.PhaseA2.counterT = ACGN.Section3.PhaseA2.relationJoin ACGN.Section3.PhaseA2.counterR
      (ACGN.Section3.PhaseA2.relationJoin ACGN.Section3.PhaseA2.counterS ACGN.Section3.PhaseA2.counterT)) :=
  ACGN.Section3.PhaseA2.unguarded_join_is_not_associative

#print axioms join_congr
#print axioms join_rotation
#print axioms leaves_nonempty
#print axioms guarded_left
#print axioms guarded_right
#print axioms wide_eval
#print axioms middle_wide
#print axioms reassociate_leaves
#print axioms reassociate_guard
#print axioms rotations_preserve_relations
#print axioms append_to_fold
#print axioms has_normal_form
#print axioms rotations_complete
#print axioms arbitrary_chain_relational_equality
#print axioms guard_supplies_license
#print axioms accepted_chain_relational_equality
#print axioms guard_executable
#print axioms typed_length
#print axioms typed_dropLast
#print axioms typed_tail
#print axioms typed_append
#print axioms join_exact_columns
#print axioms eval_exact_columns
#print axioms well_typed_chain_equality
#print axioms empty_join_left
#print axioms empty_join_right
#print axioms empty_leaf_annihilates
#print axioms explicit_univ_column
#print axioms splitLast_spec
#print axioms tupleJoin_spec
#print axioms finite_join_refines_relation
#print axioms finite_tree_refines_relation
#print axioms sameRelation_iff
#print axioms unary_interior_counterexample

end ACGN.ThirdFive.GuardedJoinChain
