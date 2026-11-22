import A224BoundaryBridge
import A222Normalized

namespace A224

/-- The ninth normalizer can merge witnesses coordinate by coordinate. Its retained
types still denote exactly the union of the individually authenticated projections. -/
theorem normalized_join_denotation (f : A222.Forest) (code : ACGN.Ninth.A221.AtomKey → Nat)
    (inj : ∀ {a b}, code a = code b → a = b)
    {m n : Nat} {l : Nat → Left ACGN.Ninth.A221.Column} {r : Nat → Right ACGN.Ninth.A221.Column}
    {es : List (Entry ACGN.Ninth.A221.Column A222.Boundary)}
    (ok : replay m n (decideCell (fun a b => toDecision (A222.Normalized.project code a)
      (A222.Normalized.project code b)) l r) = some es)
    (fl : ∀ i<m, ∀ a ∈ (l i).initial, A222.fits f (A222.Normalized.project code a))
    (fr : ∀ j<n, ∀ b ∈ (r j).suffix, A222.fits f (A222.Normalized.project code b)) (ws : List Nat) :
    A222.familyContains f ((ACGN.Ninth.A221.normalize (products es)).map (A222.Normalized.rowOf code)) ws ↔
    ∃ i<m, ∃ j<n, ∃ b,
      toDecision (A222.Normalized.project code (l i).endpoint) (A222.Normalized.project code (r j).endpoint) = some b ∧
      b.rule ≠ .disjoint ∧ A222.inhabits f (A222.Normalized.rowOf code (joined (l i) (r j))) ws := by
  have fit : ∀ p ∈ products es, ∀ col ∈ p, A222.fits f (A222.Normalized.project code col) := by
    intro p hp col hc
    obtain ⟨i,hi,j,hj,b,_,_,rfl⟩ := (candidate_iff_index ok p).mp hp
    rcases List.mem_append.mp hc with left | right
    · exact fl i hi col left
    · exact fr j hj col right
  rw [A222.Normalized.normalized_denotation f code inj _ fit ws]
  constructor
  · rintro ⟨row,hm,contains⟩
    obtain ⟨p,hp,rfl⟩ := List.mem_map.mp hm
    obtain ⟨i,hi,j,hj,b,hb,hd,rfl⟩ := (candidate_iff_index ok p).mp hp
    exact ⟨i,hi,j,hj,b,hb,hd,contains⟩
  · rintro ⟨i,hi,j,hj,b,hb,hd,contains⟩
    have mem := (candidate_iff_index ok (joined (l i) (r j))).mpr ⟨i,hi,j,hj,b,hb,hd,rfl⟩
    exact ⟨_,List.mem_map.mpr ⟨_,mem,rfl⟩,contains⟩

#print axioms normalized_join_denotation

end A224
