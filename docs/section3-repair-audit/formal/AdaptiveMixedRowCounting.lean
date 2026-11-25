import AdaptiveHomogeneousRows
import AdaptiveDifferenceCount

namespace AdaptiveMixedRowCounting
open AdaptiveCardinality

structure Reads (row : Rel α) (selected : α → Bool) where
  full : List α
  yes : List α
  no : List α
  fullUnique : full.Nodup
  yesUnique : yes.Nodup
  noUnique : no.Nodup
  fullRead : ∀ p, p ∈ full ↔ row p
  yesRead : ∀ p, p ∈ yes ↔ row p ∧ selected p = true
  noRead : ∀ p, p ∈ no ↔ row p ∧ selected p = false

def clean (row : Rel α) (selected : α → Bool) :=
  someOf (intersection row (fun p => selected p = true)) →
    noOf (intersection row (fun p => selected p = false))

theorem every_row (f : BinaryRel α β) (c : β → Bool) :
    AdaptiveHomogeneousRows.uniform f (fun p => c p = true) ↔ ∀ u, clean (f u) c := by
  constructor
  · rintro h u witness ⟨p,hp,hc⟩
    exact Bool.noConfusion (hc.symm.trans (h u witness p hp))
  · intro h u witness p hp
    cases hc : c p with
    | true => rfl
    | false => exact False.elim (h u witness ⟨p,hp,hc⟩)

theorem difference_zero (s : Reads r c) (wide : 2 < 2^w) (bound : s.no.length < 2^w) :
    (someOf (intersection r (fun p => c p = true)) → counted .eqZero w s.no.length) ↔ clean r c := by
  unfold clean
  rw [rewrite_iff .eqZero w s.no.length wide (intersection r (fun p => c p = false))
    s.no s.noUnique s.noRead (Nat.le_refl _) bound]
  rfl

theorem occupied_nonzero (s : Reads r c) (wide : 2 < 2^w) (bound : s.yes.length < 2^w) :
    (¬counted .eqZero w s.yes.length → noOf (intersection r (fun p => c p = false))) ↔ clean r c := by
  unfold clean
  rw [rewrite_iff .eqZero w s.yes.length wide (intersection r (fun p => c p = true))
    s.yes s.yesUnique s.yesRead (Nat.le_refl _) bound]
  simp [multiplicity,noOf]

-- The total need not fit a signed integer. The sign test sees only selected
-- tuples; equality of two machine counts can hide only the removed tuples.
theorem positive_and_total (s : Reads r c) (wide : 2 < 2^w)
    (sign : 2*s.yes.length < 2^w) (alias : s.no.length < 2^w) :
    (counted .gtZero w s.yes.length → BitVec.ofNat w s.yes.length = BitVec.ofNat w s.full.length)
      ↔ clean r c := by
  have size := same_relation_count (s.full.filter (fun p => !(c p))) s.no
    (List.Pairwise.filter _ s.fullUnique) s.noUnique
    (fun p => by simp [s.fullRead,s.noRead])
  have eq := AdaptiveDifferenceCount.bounded_difference w s.full s.yes r (fun p => !(c p))
    s.fullUnique s.yesUnique s.fullRead (fun p => by simpa using s.yesRead p) (by rwa [size])
  unfold clean
  rw [rewrite_iff .gtZero w s.yes.length wide (intersection r (fun p => c p = true))
    s.yes s.yesUnique s.yesRead (Nat.le_refl _) sign, eq]
  simp [multiplicity]

theorem wrap_controls :
    counted .eqZero 4 16 ∧ ¬counted .gtZero 4 8 ∧
    BitVec.ofNat 4 1 = BitVec.ofNat 4 (1+16) ∧
    BitVec.ofNat 6 1 ≠ BitVec.ofNat 6 (1+16) := by unfold counted; decide

inductive GuardedForm where
  | differenceZero | selectedNonzero | positiveAndTotal
  deriving DecidableEq

-- y and n partition *one* row of the same owner at the same state.
def GuardedForm.holds (f : GuardedForm) (w y n : Nat) : Prop :=
  match f with
  | .differenceZero => y ≠ 0 → counted .eqZero w n
  | .selectedNonzero => ¬counted .eqZero w y → n = 0
  | .positiveAndTotal => counted .gtZero w y →
      BitVec.ofNat w y = BitVec.ofNat w (y+n)

def GuardedForm.maxTotal (f : GuardedForm) (bitsBelowSign : Nat) : Nat :=
  match f with
  | .positiveAndTotal => 2^bitsBelowSign
  | _ => 2^(bitsBelowSign+1)

private theorem parts (s : Reads r c) : s.yes.length + s.no.length = s.full.length := by
  have part := AdaptiveDifferenceCount.split_length s.full c
  have y := same_relation_count (s.full.filter c) s.yes
    (List.Pairwise.filter _ s.fullUnique) s.yesUnique (fun p => by simp [s.fullRead,s.yesRead])
  have n := same_relation_count (s.full.filter (fun p => !(c p))) s.no
    (List.Pairwise.filter _ s.fullUnique) s.noUnique (fun p => by simp [s.fullRead,s.noRead])
  omega

private theorem has_tuple (xs : List α) : (∃ p, p ∈ xs) ↔ xs.length ≠ 0 := by
  cases xs <;> simp

theorem row_partition_clean (s : Reads r c) :
    clean r c ↔ s.yes.length = 0 ∨ s.no.length = 0 := by
  unfold clean someOf noOf intersection
  simp only [someOf, ← s.yesRead, ← s.noRead, has_tuple]
  omega

theorem guarded_iff (f : GuardedForm) (b y n : Nat) (h : y+n ≤ f.maxTotal b) :
    f.holds (b+1) y n ↔ y = 0 ∨ n = 0 := by
  by_cases hy : y = 0
  · subst y; cases f <;> simp [GuardedForm.holds,counted]
  by_cases hn : n = 0
  · subst n; cases f <;> simp [GuardedForm.holds,counted]
  have m : 2^(b+1) = 2^b * 2 := Nat.pow_succ ..
  cases f <;> simp only [GuardedForm.maxTotal] at h
  · have e := exact_threshold (b+1) n 0 n (Nat.two_pow_pos _) (Nat.le_refl _) (by omega)
    simpa [GuardedForm.holds,counted,hy,hn] using e
  · have e := exact_threshold (b+1) y 0 y (Nat.two_pow_pos _) (Nat.le_refl _) (by omega)
    simp [GuardedForm.holds,counted,e,hy,hn]
  · have sign := signed_exact (b+1) y (by omega)
    have e := exact_threshold (b+1) n 0 n (Nat.two_pow_pos _) (Nat.le_refl _) (by omega)
    simp only [GuardedForm.holds,counted,sign,BitVec.ofNat_add]
    have notZero : BitVec.ofNat (b+1) n ≠ 0 := fun eq => hn (e.mp eq)
    simp [hy,hn]
    exact ⟨by omega,notZero⟩

theorem guarded_row (f : GuardedForm) (s : Reads r c) (b : Nat)
    (cap : s.full.length ≤ f.maxTotal b) :
    f.holds (b+1) s.yes.length s.no.length ↔ clean r c := by
  rw [guarded_iff f b _ _ (by rwa [parts s]), row_partition_clean s]

def GuardedForm.source (f : GuardedForm) (s : Reads r c) (w : Nat) : Prop :=
  match f with
  | .differenceZero => ∀ p, r p → c p = true → counted .eqZero w s.no.length
  | .selectedNonzero => ¬counted .eqZero w s.yes.length → ∀ p, r p → c p = true
  | .positiveAndTotal => counted .gtZero w s.yes.length →
      BitVec.ofNat w s.yes.length = BitVec.ofNat w s.full.length

theorem guarded_source (f : GuardedForm) (s : Reads r c) (b : Nat)
    (cap : s.full.length ≤ f.maxTotal b) : f.source s (b+1) ↔ clean r c := by
  rw [← guarded_row f s b cap]
  cases f <;> simp only [GuardedForm.source, GuardedForm.holds, ← parts s, ← has_tuple]
  · exact ⟨fun h ⟨p,hp⟩ => h p ((s.yesRead p).mp hp).1 ((s.yesRead p).mp hp).2,
      fun h p hr hc => h ⟨p,(s.yesRead p).mpr ⟨hr,hc⟩⟩⟩
  · have none : (∀ p, r p → c p = true) ↔ s.no.length = 0 := by
      constructor
      · intro h
        apply Decidable.byContradiction; intro nz
        obtain ⟨p,hp⟩ := (has_tuple s.no).mpr nz
        obtain ⟨hr,hc⟩ := (s.noRead p).mp hp
        simp [h p hr] at hc
      · intro zero p hr
        cases hc : c p with
        | true => rfl
        | false => exact False.elim ((has_tuple s.no).mp ⟨p,(s.noRead p).mpr ⟨hr,hc⟩⟩ zero)
    rw [none]

-- Sharp for a total-only cap; a separate subtype bound can still do better.
theorem guarded_sharp (f : GuardedForm) (b cap : Nat) :
    (∀ y n, y+n ≤ cap → (f.holds (b+1) y n ↔ y=0 ∨ n=0)) ↔ cap ≤ f.maxTotal b := by
  refine ⟨fun all => ?_, fun h y n bound => guarded_iff _ _ _ _ (Nat.le_trans bound h)⟩
  apply Decidable.byContradiction
  intro tooLarge
  have m : 2^(b+1) = 2^b * 2 := Nat.pow_succ ..
  have positive : 0 < 2^b := Nat.two_pow_pos _
  have wrap : BitVec.ofNat (b+1) (2^(b+1)) = BitVec.ofNat (b+1) 0 := by
    rw [← BitVec.toNat_inj]; simp
  cases f <;> simp only [GuardedForm.maxTotal] at tooLarge
  · have bad := (all 1 (2^(b+1)) (by omega)).mp (fun _ => wrap)
    omega
  · have bad := (all (2^(b+1)) 1 (by omega)).mp (fun h => False.elim (h wrap))
    omega
  · have half : (BitVec.ofNat (b+1) (2^b)).toNat = 2^b := Nat.mod_eq_of_lt (by omega)
    have notPositive : ¬0 < (BitVec.ofNat (b+1) (2^b)).toInt := by
      rw [BitVec.toInt_eq_toNat_cond, half]; split <;> omega
    have bad := (all (2^b) 1 (by omega)).mp (by simp [GuardedForm.holds,counted,notPositive])
    omega

end AdaptiveMixedRowCounting
