import SelectedDeclarationCompletion

/- Extending a selected paid alignment must not reconstruct it from the read
   census. Declaration slots can remain semantically significant without reads.
   No declaration, payment, endpoint or source term is removed by this model. -/
namespace PaidAlignmentExtension
open SelectedDeclarationCompletion

def merge (retained added : Mapping) (x : Nat) : Option Nat :=
  match retained x with
  | some y => some y
  | none => added x

def Compatible (retained added : Mapping) : Prop :=
  ∀ x y z, retained x = some y → added x = some z → y = z

def Injective (m : Mapping) : Prop :=
  ∀ x z y, m x = some y → m z = some y → x = z

def Accepted (retained added : Mapping) : Prop :=
  Compatible retained added ∧ Injective (merge retained added)

theorem retains_paid (retained added : Mapping) (x y : Nat)
    (old : retained x = some y) : merge retained added x = some y := by
  simp [merge, old]

theorem retains_added (retained added : Mapping) (x y : Nat)
    (ok : Compatible retained added) (new : added x = some y) :
    merge retained added x = some y := by
  cases h : retained x with
  | none => simp [merge, h, new]
  | some z => simp [merge, h, ok x z y h new]

theorem conflict_rejected (retained added : Mapping) (x y z : Nat)
    (old : retained x = some y) (new : added x = some z) (different : y ≠ z) :
    ¬ Accepted retained added := by
  intro ok
  exact different (ok.1 x y z old new)

theorem collision_rejected (retained added : Mapping) (x z y : Nat)
    (old : retained x = some y) (new : added z = some y) (different : x ≠ z) :
    ¬ Accepted retained added := by
  intro ok
  exact different (ok.2 x z y (retains_paid retained added x y old)
    (retains_added retained added z y ok.1 new))

/- Both maps must come from the same selected path after its checked grouped
   transport. Compatible maps from different minimum paths are not authority. -/
def AuthorizedBy (selected : List (Nat × Nat)) (m : Mapping) : Prop :=
  ∀ x y, m x = some y → (x, y) ∈ selected

theorem same_path_union (selected : List (Nat × Nat)) (retained added : Mapping)
    (old : AuthorizedBy selected retained) (new : AuthorizedBy selected added) :
    AuthorizedBy selected (merge retained added) := by
  intro x y link
  cases h : retained x with
  | none => exact new x y (by simpa [merge, h] using link)
  | some z =>
    have equal : z = y := by simpa [merge, h] using link
    subst z
    exact old x y h

theorem foreign_path_link_rejected (selected : List (Nat × Nat))
    (retained added : Mapping) (x y : Nat)
    (compatible : Compatible retained added) (link : added x = some y)
    (foreign : (x, y) ∉ selected) : ¬ AuthorizedBy selected (merge retained added) := by
  intro authority
  exact foreign (authority x y (retains_added retained added x y compatible link))

def searchNames (locked : List Nat) (fixed : Mapping) : List Nat :=
  locked.filter (fun x => (fixed x).isNone)

/- Each pre-existing lock either came from a read descriptor or is fixed by
   its selected paid declaration path. New dependency locks are fixed too. -/
def Covered (locked reads : List Nat) (retained : Mapping) : Prop :=
  ∀ x ∈ locked, x ∈ reads ∨ ∃ y, retained x = some y

theorem search_has_descriptor (locked reads : List Nat) (retained added : Mapping)
    (covered : Covered locked reads retained) (x : Nat)
    (search : x ∈ searchNames locked (merge retained added)) : x ∈ reads := by
  have member := List.mem_filter.mp search
  rcases covered x member.1 with found | ⟨y, paid⟩
  · exact found
  · simp [retains_paid retained added x y paid] at member

theorem fixed_lock_not_searched (locked : List Nat) (retained added : Mapping)
    (x y : Nat) (paid : retained x = some y) :
    x ∉ searchNames locked (merge retained added) := by
  simp [searchNames, retains_paid retained added x y paid]

theorem search_extension (locked reads : List Nat) (retained added : Mapping)
    (covered : Covered locked reads retained) (fixed : Mapping)
    (extension : ∀ x y, merge retained added x = some y → fixed x = some y)
    (x : Nat) (search : x ∈ searchNames locked fixed) : x ∈ reads := by
  have member := List.mem_filter.mp search
  rcases covered x member.1 with found | ⟨y, paid⟩
  · exact found
  · simp [extension x y (retains_paid retained added x y paid)] at member

/- This is read charging, not source-form equivalence. The declaration action
   that paid for a link is retained separately and its charge is unchanged. -/
theorem paid_read_charge_unchanged (retained added : Mapping) (action : Action)
    (x y target : Nat) (query : readPair action = some (x, target))
    (paid : retained x = some y) :
    charge (merge retained added) action = charge retained action := by
  simp [charge, query, UnobservedDeclarationCompletion.variableCost,
    retains_paid retained added x y paid, paid]

/- Concrete domain witness from null-pointer-v1's checked observations.
   _q0 is read; _q1 is a retained ALL/disjoint/Grade declaration with no read.
   The source, declaration metadata and old/native receipts are bound externally.
   These numerals are slot coordinates, never production dispatch keys. -/
def originalPaid : Mapping := fun x => if x < 2 then some x else none
def newPaid : Mapping := fun x => if x = 0 then some 0 else none
def reads : List Nat := [0]
def locks : List Nat := [0, 1]

theorem original_paid_covered : Covered locks reads originalPaid := by
  intro x member
  simp [locks] at member
  rcases member with rfl | rfl
  · exact Or.inl (by simp [reads])
  · exact Or.inr ⟨1, by decide⟩

theorem old_search_uses_absent_descriptor :
    searchNames locks newPaid = [1] ∧ 1 ∉ reads := by decide

theorem new_search_is_total :
    searchNames locks (merge originalPaid newPaid) = [] ∧
    merge originalPaid newPaid 1 = some 1 := by decide

theorem witness_extension_accepted : Accepted originalPaid newPaid := by
  constructor
  · intro x y z old new
    by_cases zero : x = 0
    · subst x; simp [newPaid] at new; simp [originalPaid] at old; omega
    · simp [newPaid, zero] at new
  · intro x z y hx hz
    have identity : ∀ n v, merge originalPaid newPaid n = some v → n = v := by
      intro n v h
      by_cases small : n < 2
      · simpa [merge, originalPaid, small] using h
      · have nonzero : n ≠ 0 := by omega
        simp [merge, originalPaid, small, newPaid, nonzero] at h
    exact (identity x y hx).trans (identity z y hz).symm

#print axioms retains_paid
#print axioms retains_added
#print axioms conflict_rejected
#print axioms collision_rejected
#print axioms same_path_union
#print axioms foreign_path_link_rejected
#print axioms search_has_descriptor
#print axioms fixed_lock_not_searched
#print axioms search_extension
#print axioms paid_read_charge_unchanged
#print axioms original_paid_covered
#print axioms old_search_uses_absent_descriptor
#print axioms new_search_is_total
#print axioms witness_extension_accepted
end PaidAlignmentExtension
