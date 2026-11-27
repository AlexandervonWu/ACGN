import DeclarationReplay

namespace CoalescedDeclarationFrames

/-- An issued frame associates one normalized binder with a position in one
    particular original declaration. The normalizer may retain several frames
    for one binder. Source authentication is a premise of this finite model. -/
structure Frame where
  owner : Nat
  declaration : Nat
  binderId : Nat
  slot : Nat
  deriving DecidableEq

def positions (frames : List Frame) (owner declaration : Nat) : List (Nat × Nat) :=
  frames.filterMap fun f =>
    if f.owner = owner ∧ f.declaration = declaration then some (f.binderId, f.slot)
    else none

/-- Equality up to list order includes multiplicities, so omitting or
    duplicating a slot cannot supply the complete issued declaration. -/
def Complete (frames : List Frame) (owner declaration : Nat) (binders : List Nat) : Prop :=
  (positions frames owner declaration).Perm binders.zipIdx

theorem reads_original_slot {frames : List Frame} {o d : Nat} {binders : List Nat}
    (census : Complete frames o d binders) (v s : Nat) :
    (v,s) ∈ positions frames o d ↔ (v,s) ∈ binders.zipIdx :=
  census.mem_iff

theorem requires_complete_arity {frames : List Frame} {o d : Nat} {binders : List Nat}
    (census : Complete frames o d binders) :
    (positions frames o d).length = binders.length := by
  simpa using census.length_eq

/-- A representative's one lexical slot cannot encode the two positions
    owned by distinct occurrences of the same normalized binder. -/
theorem one_key_cannot_encode_both (key : Nat → Nat) (v a b : Nat) (different : a ≠ b) :
    ¬ (key v = a ∧ key v = b) := by
  rintro ⟨ha,hb⟩
  exact different (ha.symm.trans hb)

/-- Coordinates are local to each declaration. Here binder 3 occupies
    slot 0 of a singleton and slot 1 of an ordinary two-binder group. -/
def issued : List Frame := [⟨8,20,3,0⟩, ⟨8,21,7,0⟩, ⟨8,21,3,1⟩]

theorem two_complete_occurrences :
    Complete issued 8 20 [3] ∧ Complete issued 8 21 [7,3] :=
  ⟨List.Perm.refl _, List.Perm.refl _⟩

theorem rejects_foreign_or_missing_frame :
    positions issued 9 21 = [] ∧ positions issued 8 22 = [] ∧
    (3,0) ∉ positions issued 8 21 ∧
    ¬ Complete [⟨8,21,7,0⟩] 8 21 [7,3] := by
  refine ⟨rfl, rfl, by decide, ?_⟩
  intro h
  have arity := requires_complete_arity h
  change 1 = 2 at arity
  omega

open DeclarationReplay

private def numberedAtom (n : Nat) : Atom := ⟨n, 0⟩
private def insertThenKeep (a b c : Nat) : List Edit :=
  [.insert (numberedAtom a), .pair (numberedAtom 0) (numberedAtom b), .pair (numberedAtom 1) (numberedAtom c)]

/-- The 52- and 71-edit examples use two source User binders and three
    target User binders. The displayed slot permutations change both the
    inserted occurrence and the surviving links while charging one edit. -/
theorem equal_charge_different_occurrences :
    let run := replay [numberedAtom 0, numberedAtom 1]
    run (insertThenKeep 0 1 2) = some ([numberedAtom 0, numberedAtom 1, numberedAtom 2], 1) ∧
    run (insertThenKeep 2 1 0) = some ([numberedAtom 2, numberedAtom 1, numberedAtom 0], 1) ∧
    run (insertThenKeep 1 2 0) = some ([numberedAtom 1, numberedAtom 2, numberedAtom 0], 1) ∧
    insertThenKeep 0 1 2 ≠ insertThenKeep 2 1 0 ∧
    insertThenKeep 0 1 2 ≠ insertThenKeep 1 2 0 := by
  simp [replay, insertThenKeep, numberedAtom]


/-- When declarations consist of unit insertions, deletions and updates, the
    difference in endpoint lengths is a lower bound. Attaining it leaves only
    insertions on a growing prefix and only deletions on a shrinking one. -/
theorem gap_minimum_allows_only_length_edits (source target ins del upd : Nat)
    (balance : target + del = source + ins)
    (charge : ins + del + upd = max source target - min source target) :
    (source ≤ target → del = 0 ∧ upd = 0) ∧
    (target ≤ source → ins = 0 ∧ upd = 0) := by
  constructor
  · intro grows
    rw [Nat.max_eq_right grows, Nat.min_eq_left grows] at charge
    omega
  · intro shrinks
    rw [Nat.max_eq_left shrinks, Nat.min_eq_right shrinks] at charge
    omega

private def reverse71 : List Edit :=
  [.delete (numberedAtom 1), .pair (numberedAtom 0) (numberedAtom 1),
   .pair (numberedAtom 2) (numberedAtom 0)]

/-- In the reverse distance-71 receipt, deleting reference position 1 and
    retaining 0→1 and 2→0 uses both certified endpoint permutations.
    These links are the very same links used in the matrix decision. -/
theorem reverse_71_replays_at_selected_links :
    replay [numberedAtom 1, numberedAtom 0, numberedAtom 2] reverse71 =
      some ([numberedAtom 1, numberedAtom 0], 1) ∧
    reverse71.filterMap (fun e => match e with
      | .pair a b => some (a.occurrence, b.occurrence)
      | _ => none) = [(0,1),(2,0)] := by decide

/-- Within one carrier type, every original frame must agree on its domain
    and have no free dependency to admit the coalesced exchange.
    Source authentication and a valid automorphism are separate premises. -/
def exchangeGuard (expected : Nat) (frames : List (Nat × List Nat)) : Bool :=
  frames.all fun (domain, deps) => decide (domain = expected) && deps.isEmpty

theorem exchange_checks_every_frame {frames : List (Nat × List Nat)} {expected : Nat}
    (checked : exchangeGuard expected frames = true) {domain : Nat} {deps : List Nat}
    (member : (domain,deps) ∈ frames) : domain = expected ∧ deps = [] := by
  have h := List.all_eq_true.mp checked _ member
  simpa using h

theorem blocks_a_dependency_or_different_domain :
    exchangeGuard 2 [(2,[]),(2,[0])] = false ∧
    exchangeGuard 2 [(2,[]),(3,[])] = false ∧
    exchangeGuard 2 [(2,[]),(2,[])] = true := by decide

/-- A matrix decision keeps its measured charge, outer mapping and native
    program. Link equality is extensional equality of the model's map type. -/
structure Matrix (Map Program : Type) where
  charge : Nat
  links : Map
  program : Program

structure Prefix (Map Path : Type) where
  matrixCharge : Nat
  matrixLinks : Map
  extraPayments : Nat
  path : Path

/-- Complete an absent declaration path on an already selected matrix.
    The caller has checked both endpoint orders, every surviving link, and
    the source evidence. The prefix cost attains the length lower bound. -/
def complete {Map Program Path : Type} [DecidableEq Map]
    (selected : Matrix Map Program) (candidate : Prefix Map Path) (authenticated : Bool) :
    Matrix Map Program × Option Path :=
  (selected, if authenticated = true ∧ candidate.matrixCharge = selected.charge ∧
                candidate.extraPayments = 0 ∧ candidate.matrixLinks = selected.links
             then some candidate.path else none)

theorem preserves_matrix_program_and_charge {Map Program Path : Type} [DecidableEq Map]
    (selected : Matrix Map Program) (candidate : Prefix Map Path) (valid : Bool) :
    (complete selected candidate valid).1 = selected := rfl

theorem attaches_exactly_an_attaining_linked_path {Map Program Path : Type} [DecidableEq Map]
    (selected : Matrix Map Program) (candidate : Prefix Map Path) (valid : Bool) :
    (complete selected candidate valid).2 = some candidate.path ↔
    valid = true ∧ candidate.matrixCharge = selected.charge ∧ candidate.extraPayments = 0 ∧
    candidate.matrixLinks = selected.links := by
  simp [complete]

#print axioms reads_original_slot
#print axioms requires_complete_arity
#print axioms one_key_cannot_encode_both
#print axioms two_complete_occurrences
#print axioms rejects_foreign_or_missing_frame
#print axioms equal_charge_different_occurrences
#print axioms gap_minimum_allows_only_length_edits
#print axioms reverse_71_replays_at_selected_links
#print axioms exchange_checks_every_frame
#print axioms blocks_a_dependency_or_different_domain
#print axioms preserves_matrix_program_and_charge
#print axioms attaches_exactly_an_attaining_linked_path
end CoalescedDeclarationFrames
