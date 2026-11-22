import A223ArrowFamilies
import A224Join

namespace A224
open ACGN.Eighth.A223

/-- Coordinate-wise authority merging preserves the entire ordered product key. -/
theorem admitted_representative_origin (k : α → AtomKey) (auth : α → Bool)
    {xs : List (List α)} {r a : List α} (h : a ∈ putRepresentative k auth xs r) :
    keys k a ∈ xs.map (keys k) ∨ keys k a = keys k r := by
  have present := List.mem_map_of_mem (f:=keys k) h
  rw [put_keys] at present
  split at present
  · exact Or.inl present
  · simpa using present

theorem grouped_origin (k : α → AtomKey) (auth : α → Bool)
    (raw acc : List (List α)) (q : List AtomKey)
    (h : q ∈ (raw.foldl (putRepresentative k auth) acc).map (keys k)) :
    q ∈ acc.map (keys k) ∨ q ∈ raw.map (keys k) := by
  induction raw generalizing acc with
  | nil => exact Or.inl h
  | cons r rs ih =>
    obtain present | rest := ih _ h
    · obtain ⟨a,ha,rfl⟩ := List.mem_map.mp present
      rcases admitted_representative_origin k auth ha with old | incoming
      · exact Or.inl old
      · exact Or.inr (by simp [incoming])
    · exact Or.inr (by simp [rest])

theorem normalized_origin (k : α → AtomKey) (auth : α → Bool) (weak : α → α → Prop)
    (es : List (Entry α ω)) (a : List α) (h : a ∈ admission k auth weak (products es)) :
    ∃ e ∈ es, ∃ projected, e.result = some projected ∧ keys k a = keys k projected := by
  classical
  unfold admission at h
  have kept := List.mem_mergeSort.mp h
  have grouped : a ∈ (products es).foldl (putRepresentative k auth) [] := (List.mem_filter.mp kept).1
  have raw := grouped_origin k auth (products es) [] (keys k a) (List.mem_map_of_mem grouped)
  obtain ⟨projected,hp,eq⟩ := List.mem_map.mp (raw.resolve_left (by simp))
  obtain ⟨e,he,ret⟩ := List.mem_filterMap.mp hp
  exact ⟨e,he,projected,ret,eq.symm⟩

theorem surviving_product_from_address {m n : Nat}
    {c : α → α → Option (Boundary ω)} {l : Nat → Left α} {r : Nat → Right α}
    {es : List (Entry α ω)} (ok : replay m n (decideCell c l r) = some es)
    (k : α → AtomKey) (auth : α → Bool) (weak : α → α → Prop) {a : List α}
    (h : a ∈ admission k auth weak (products es)) :
    ∃ i<m, ∃ j<n, ∃ b, c (l i).endpoint (r j).endpoint = some b ∧
      b.rule ≠ .disjoint ∧ keys k a = keys k ((l i).initial ++ (r j).suffix) := by
  obtain ⟨e,he,row,ret,eq⟩ := normalized_origin k auth weak es a h
  obtain ⟨i,hi,j,hj,b,hb,hd,projection⟩ :=
    (candidate_iff_index ok row).mp (List.mem_filterMap.mpr ⟨e,he,ret⟩)
  exact ⟨i,hi,j,hj,b,hb,hd,eq.trans (congrArg (keys k) projection)⟩

#print axioms admitted_representative_origin
#print axioms grouped_origin
#print axioms normalized_origin
#print axioms surviving_product_from_address

end A224
