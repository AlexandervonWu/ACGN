import AdaptiveClassifier

namespace AdaptiveFiberWitness
open AdaptiveClassifier

theorem two_iff (r : Rel α) :
    (∃ a b, r a ∧ r b ∧ a ≠ b) ↔ ¬ loneOf r := by
  constructor
  · exact fun ⟨a,b,ha,hb,ne⟩ lone => ne (lone a b ha hb)
  · intro h
    apply Classical.byContradiction
    exact fun missing => h (fun a b ha hb => Classical.byContradiction
      (fun ne => missing ⟨a,b,ha,hb,ne⟩))

theorem some_not_one (r : Rel α) : (someOf r ∧ ¬oneOf r) ↔ ¬loneOf r := by
  constructor
  · exact fun ⟨yes,no⟩ lone => no ⟨yes,lone⟩
  · intro h
    obtain ⟨a,_,ha,_,_⟩ := (two_iff r).mpr h
    exact ⟨⟨a,ha⟩,fun one => h one.2⟩

inductive Need where | first | second | apart deriving DecidableEq

def holds (r : Rel α) (a b : α) : Need → Prop
  | .first => r a | .second => r b | .apart => a ≠ b

def complete (ns : List Need) := Need.first ∈ ns ∧ Need.second ∈ ns ∧ Need.apart ∈ ns

-- Domain membership can discharge a fiber read, and a declaration's disj
-- can discharge inequality. Neither permits omitting the other obligations.
theorem grouped (r d₁ d₂ : Rel α) (ns : List Need) (all : complete ns)
    (cover₁ : subset r d₁) (cover₂ : subset r d₂) :
    (∃ a b, d₁ a ∧ d₂ b ∧ ∀ n ∈ ns, holds r a b n) ↔ ¬loneOf r := by
  rw [← two_iff]
  constructor
  · rintro ⟨a,b,_,_,h⟩
    exact ⟨a,b,h .first all.1,h .second all.2.1,h .apart all.2.2⟩
  · rintro ⟨a,b,ha,hb,ne⟩
    refine ⟨a,b,cover₁ a ha,cover₂ b hb,?_⟩
    intro n _
    cases n <;> assumption

theorem pair_union (a b : α) (r : Rel α) :
    subset (union (singletonRel a) (singletonRel b)) r ↔ r a ∧ r b := by
  constructor
  · exact fun h => ⟨h a (Or.inl rfl),h b (Or.inr rfl)⟩
  · rintro ⟨ha,hb⟩ z (eq | eq)
    · exact eq ▸ ha
    · exact eq ▸ hb

theorem edge_spellings (f : BinaryRel α β) (x : α) (t : β) :
    (unaryRightJoin f (singletonRel t) x ↔ f x t) ∧
    (unaryLeftJoin (singletonRel x) f t ↔ f x t) ∧
    (subset (relationProduct (singletonRel t) (singletonRel x))
      (fun p => converseBinary f p.1 p.2) ↔ f x t) := by
  refine ⟨by simp [unaryRightJoin,singletonRel],by simp [unaryLeftJoin,singletonRel],?_⟩
  constructor
  · exact fun h => h (t,x) ⟨rfl,rfl⟩
  · rintro h ⟨s,y⟩ ⟨rfl,rfl⟩; exact h

-- Original 6P88zEvRaQqqYv2nB/inv5: two distinct tracks are chosen now.
-- Both lead to false, neither to true; Junction contains precisely false.
theorem station_instance :
    let f : BinaryRel Bool Bool := fun _ t => t = false
    let track : Rel Bool := fun _ => True
    let junction : Rel Bool := (· = false)
    classify track junction (fun t => ∃ a b, track a ∧ track b ∧ a ≠ b ∧
      subset (union (singletonRel a) (singletonRel b)) (unaryRightJoin f (singletonRel t))) ↔
    qAll track (fun t => (¬junction t) ↔ loneOf (unaryRightJoin f (singletonRel t))) := by
  intro f track junction
  have point (t) : (∃ a b, track a ∧ track b ∧ a ≠ b ∧
      subset (union (singletonRel a) (singletonRel b)) (unaryRightJoin f (singletonRel t))) ↔
      ¬loneOf (unaryRightJoin f (singletonRel t)) := by
    rw [← two_iff]
    simp only [pair_union]
    exact ⟨fun ⟨a,b,_,_,ne,h₁,h₂⟩ => ⟨a,b,h₁,h₂,ne⟩,
           fun ⟨a,b,h₁,h₂,ne⟩ => ⟨a,b,trivial,trivial,ne,h₁,h₂⟩⟩
  exact ⟨fun h t ht => (member_iff true _ _).mpr ((h t ht).trans (point t)),
         fun h t ht => ((member_iff true _ _).mp (h t ht)).trans (point t).symm⟩

theorem narrow_domain :
    let r : Rel Bool := fun _ => True
    ¬loneOf r ∧ ¬(∃ a b, a = false ∧ b = false ∧ r a ∧ r b ∧ a ≠ b) := by
  intro r
  exact ⟨(two_iff r).mp ⟨true,false,trivial,trivial,by decide⟩,fun ⟨_,_,rfl,rfl,_,_,ne⟩ => ne rfl⟩

-- Excluding an initial segment of bit patterns reads the *unsigned residue*.
-- This is neither a signed order comparison nor an unbounded tuple count.
def covers (ks : List Nat) (k : Nat) := ∀ j, j ∈ ks ↔ j ≤ k
def excluded (ks : List Nat) (w n : Nat) :=
  ∀ j ∈ ks, BitVec.ofNat w n ≠ BitVec.ofNat w j

theorem source_exclusions (ks : List Nat) (w n k : Nat) (all : covers ks k) (fit : 2*k < 2^w) :
    (∀ j ∈ ks, (BitVec.ofNat w n).toInt ≠ (j : Int)) ↔ excluded ks w n := by
  have lit (j) (hj : j ∈ ks) := AdaptiveCardinality.signed_exact w j
    (show 2*j < 2^w by have := (all j).mp hj; omega)
  constructor
  · exact fun h j hj eq => h j hj ((congrArg BitVec.toInt eq).trans (lit j hj))
  · intro h j hj eq
    exact h j hj (BitVec.toInt_inj.mp (eq.trans (lit j hj).symm))

theorem excluded_unsigned (ks : List Nat) (w n k : Nat) (all : covers ks k) (fit : k < 2^w) :
    excluded ks w n ↔ k < (BitVec.ofNat w n).toNat := by
  let v := (BitVec.ofNat w n).toNat
  have fits : v < 2^w := (BitVec.ofNat w n).isLt
  constructor
  · intro h
    apply Nat.lt_of_not_ge
    intro le
    exact h v ((all v).mpr le) (BitVec.eq_of_toNat_eq (Nat.mod_eq_of_lt fits).symm)
  · intro gt j hj eq
    have small : j < 2^w := Nat.lt_of_le_of_lt ((all j).mp hj) fit
    have h := congrArg BitVec.toNat eq
    have hj' : (BitVec.ofNat w j).toNat = j := Nat.mod_eq_of_lt small
    rw [hj'] at h
    exact (Nat.not_lt_of_ge ((all j).mp hj)) (h ▸ gt)

theorem excluded_tuple (ks : List Nat) (w n k cap : Nat) (all : covers ks k) (fit : k < 2^w)
    (within : n ≤ cap) (safe : cap < 2^w) : excluded ks w n ↔ k < n := by
  rw [excluded_unsigned ks w n k all fit,BitVec.toNat_ofNat,Nat.mod_eq_of_lt (by omega)]

theorem excluded_signed (ks : List Nat) (w n k cap : Nat) (all : covers ks k) (fit : k < 2^w)
    (within : n ≤ cap) (safe : 2*cap < 2^w) :
    excluded ks w n ↔ (k : Int) < (BitVec.ofNat w n).toInt := by
  rw [excluded_tuple ks w n k cap all fit within (by omega), AdaptiveCardinality.signed_exact w n (by omega)]
  omega

theorem excluded_controls :
    excluded [1,0] 4 8 ∧ ¬(1 < (BitVec.ofNat 4 8).toInt) ∧ ¬excluded [1,0] 4 16 := by
  simp [excluded,BitVec.toInt]

-- The nonnegative SOURCE literals fit; the observed count itself need not fit
-- the signed range. This is why the natural two-disequality row survives at 8.
theorem excluded_not_lone (r : Rel α) (xs : List α) (nd : xs.Nodup)
    (read : ∀ a, a ∈ xs ↔ r a) (w cap : Nat) (width : 2 < 2^w)
    (bound : xs.length ≤ cap) (safe : cap < 2^w) :
    ((BitVec.ofNat w xs.length).toInt ≠ 1 ∧ (BitVec.ofNat w xs.length).toInt ≠ 0) ↔ ¬loneOf r := by
  have all : covers [1,0] 1 := by intro j; simp; omega
  have obs := (source_exclusions [1,0] w xs.length 1 all (by omega)).trans
    (excluded_tuple [1,0] w xs.length 1 cap all (by omega) bound safe)
  simp at obs
  have same : r = fun a => a ∈ xs := funext fun a => propext (read a).symm
  rw [obs,same,← AdaptiveCardinality.length_lone_iff xs nd]
  omega

end AdaptiveFiberWitness
