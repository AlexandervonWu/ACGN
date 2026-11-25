import AdaptiveCardinality

namespace AdaptiveDifferenceCount

theorem split_length (xs : List α) (inS : α → Bool) :
    (xs.filter (fun x => !(inS x))).length + (xs.filter inS).length = xs.length := by
  induction xs with
  | nil => rfl
  | cons x xs ih => cases h : inS x <;> simp [h] <;> omega

-- The counts of R and R-S may both overflow. Only the removed tuples matter.
theorem count_residue (w : Nat) (xs : List α) (inS : α → Bool) :
    BitVec.ofNat w (xs.filter (fun x => !(inS x))).length = BitVec.ofNat w xs.length ↔
    (xs.filter inS).length % 2^w = 0 := by
  let a := (xs.filter (fun x => !(inS x))).length
  let b := (xs.filter inS).length
  change BitVec.ofNat w a = BitVec.ofNat w xs.length ↔ b % 2^w = 0
  rw [show xs.length = a+b from (split_length xs inS).symm, BitVec.ofNat_add]
  calc
    _ ↔ BitVec.ofNat w b = (0 : BitVec w) := by simp
    _ ↔ _ := by rw [← BitVec.toNat_inj]; simp

theorem bounded_difference (w : Nat) (xs kept : List α) (r : Rel α) (inS : α → Bool)
    (ur : xs.Nodup) (uk : kept.Nodup) (source : ∀ x, x ∈ xs ↔ r x)
    (difference : ∀ x, x ∈ kept ↔ r x ∧ inS x = false)
    (cap : (xs.filter inS).length < 2^w) :
    BitVec.ofNat w kept.length = BitVec.ofNat w xs.length ↔
      noOf (intersection r (fun x => inS x = true)) := by
  have same := AdaptiveCardinality.same_relation_count kept (xs.filter (fun x => !(inS x)))
    uk (List.Pairwise.filter _ ur) (fun x => by simp [difference, source])
  rw [same, count_residue, Nat.mod_eq_of_lt cap]
  simp [noOf, someOf, intersection, List.filter_eq_nil_iff, source]

def grid (left : List α) (right : List β) : List (α × β) :=
  left.flatMap fun x => right.map fun y => (x,y)

theorem grid_length (left : List α) (right : List β) :
    (grid left right).length = left.length * right.length := by
  induction left with
  | nil => simp [grid]
  | cons x xs ih => simpa [grid, Nat.succ_mul, Nat.add_comm] using ih

-- Either field's typed carrier can bound the overlap, not just the minuend.
theorem typed_overlap_bound (xs : List (α × β)) (inS : α × β → Bool)
    (left : List α) (right : List β) (unique : xs.Nodup)
    (typed : ∀ p ∈ xs, inS p = true → p.1 ∈ left ∧ p.2 ∈ right) :
    (xs.filter inS).length ≤ left.length * right.length := by
  rw [← grid_length]
  apply List.Nodup.length_le_of_subset (List.Pairwise.filter inS unique)
  intro p hp
  obtain ⟨hx, hy⟩ := typed p (List.mem_filter.mp hp).1 (List.mem_filter.mp hp).2
  exact List.mem_flatMap.mpr ⟨p.1,hx,List.mem_map.mpr ⟨p.2,hy,rfl⟩⟩

theorem counted_asymmetry (w : Nat) (nodes : List α)
    (edges kept : List (α × α)) (r : α → α → Bool)
    (ue : edges.Nodup) (uk : kept.Nodup)
    (source : ∀ p, p ∈ edges ↔ r p.1 p.2 = true)
    (subtract : ∀ p, p ∈ kept ↔ r p.1 p.2 = true ∧ r p.2 p.1 = false)
    (typed : ∀ p ∈ edges, p.1 ∈ nodes ∧ p.2 ∈ nodes)
    (safe : nodes.length * nodes.length < 2^w) :
    BitVec.ofNat w kept.length = BitVec.ofNat w edges.length ↔
      noOf (intersection (fun p : α × α => r p.1 p.2 = true) (fun p => r p.2 p.1 = true)) :=
  bounded_difference w edges kept _ (fun p => r p.2 p.1) ue uk source subtract
    (Nat.lt_of_le_of_lt (typed_overlap_bound edges _ nodes nodes ue (fun p h _ => typed p h)) safe)

theorem same_frames (fs : List AdaptivePhaseAlgebra.TimeFrame) (w t : Nat)
    (xs kept : Nat → List α) (r : Nat → Rel α) (inS : Nat → α → Bool)
    (ur : ∀ i, (xs i).Nodup) (uk : ∀ i, (kept i).Nodup)
    (source : ∀ i x, x ∈ xs i ↔ r i x)
    (difference : ∀ i x, x ∈ kept i ↔ r i x ∧ inS i x = false)
    (cap : ∀ i, ((xs i).filter (inS i)).length < 2^w) :
    AdaptivePhaseAlgebra.inFrames fs (fun i => BitVec.ofNat w (kept i).length =
      BitVec.ofNat w (xs i).length) t ↔
    AdaptivePhaseAlgebra.inFrames fs (fun i => noOf (intersection (r i)
      (fun x => inS i x = true))) t := by
  apply Iff.of_eq
  congr 2
  funext i
  exact propext (bounded_difference w (xs i) (kept i) (r i) (inS i)
    (ur i) (uk i) (source i) (difference i) (cap i))

theorem complete_graph_control :
    let edges := grid (List.range 4) (List.range 4)
    let rev := fun p : Nat × Nat => decide ((p.2,p.1) ∈ edges)
    (edges.filter rev).length = 16 ∧
    BitVec.ofNat 4 (edges.filter (fun p => !(rev p))).length = BitVec.ofNat 4 edges.length ∧
    BitVec.ofNat 5 (edges.filter (fun p => !(rev p))).length ≠ BitVec.ofNat 5 edges.length := by
  decide

end AdaptiveDifferenceCount
