import SelectedDeclarationPathTransport

namespace JointDeclarationPathSelection
open SelectedDeclarationCompletion SelectedDeclarationPathTransport

-- Selection constraints are not charges or denotational equivalences. Retain
-- the complete bindings, including unequal domains on paid repair endpoints.
def outside (path : List Step) (link : Link) : Bool :=
  !(sources path).any (fun a => a.vectorIndex == link.1.vectorIndex) &&
  !(targets path).any (fun b => b.vectorIndex == link.2.vectorIndex)

def complete (path : List Step) (residual : List Link) : List Link :=
  links path ++ residual.filter (outside path)

theorem outside_avoids_source (path : List Step) (link : Link)
    (h : outside path link = true) :
    link.1.vectorIndex ∉ (sources path).map Binding.vectorIndex := by
  simp only [outside, Bool.and_eq_true] at h
  intro member
  rcases List.mem_map.mp member with ⟨a, ha, equal⟩
  have yes : (sources path).any (fun a => a.vectorIndex == link.1.vectorIndex) = true :=
    List.any_eq_true.mpr ⟨a, ha, by simpa using equal⟩
  have no := h.1
  rw [yes] at no
  contradiction

theorem outside_avoids_target (path : List Step) (link : Link)
    (h : outside path link = true) :
    link.2.vectorIndex ∉ (targets path).map Binding.vectorIndex := by
  simp only [outside, Bool.and_eq_true] at h
  intro member
  rcases List.mem_map.mp member with ⟨a, ha, equal⟩
  have yes : (targets path).any (fun a => a.vectorIndex == link.2.vectorIndex) = true :=
    List.any_eq_true.mpr ⟨a, ha, by simpa using equal⟩
  have no := h.2
  rw [yes] at no
  contradiction

theorem exact_source_links (path : List Step) (residual : List Link) (link : Link)
    (owned : link.1.vectorIndex ∈ (sources path).map Binding.vectorIndex) :
    link ∈ complete path residual ↔ link ∈ links path := by
  constructor
  · intro h
    rcases List.mem_append.mp h with old | extra
    · exact old
    · exact False.elim (outside_avoids_source path link (List.mem_filter.mp extra).2 owned)
  · exact fun h => List.mem_append_left _ h

theorem exact_target_links (path : List Step) (residual : List Link) (link : Link)
    (owned : link.2.vectorIndex ∈ (targets path).map Binding.vectorIndex) :
    link ∈ complete path residual ↔ link ∈ links path := by
  constructor
  · intro h
    rcases List.mem_append.mp h with old | extra
    · exact old
    · exact False.elim (outside_avoids_target path link (List.mem_filter.mp extra).2 owned)
  · exact fun h => List.mem_append_left _ h

theorem one_sided_source_stays_unmapped (path : List Step) (residual : List Link) (a : Binding)
    (owned : a.vectorIndex ∈ (sources path).map Binding.vectorIndex)
    (unpaired : a.vectorIndex ∉ (links path).map (fun p => p.1.vectorIndex)) :
    ∀ link ∈ complete path residual, link.1.vectorIndex ≠ a.vectorIndex := by
  intro link member equal
  have old := (exact_source_links path residual link (equal ▸ owned)).mp member
  exact unpaired (List.mem_map.mpr ⟨link, old, equal⟩)

theorem one_sided_target_stays_unmapped (path : List Step) (residual : List Link) (b : Binding)
    (owned : b.vectorIndex ∈ (targets path).map Binding.vectorIndex)
    (unpaired : b.vectorIndex ∉ (links path).map (fun p => p.2.vectorIndex)) :
    ∀ link ∈ complete path residual, link.2.vectorIndex ≠ b.vectorIndex := by
  intro link member equal
  have old := (exact_target_links path residual link (equal ▸ owned)).mp member
  exact unpaired (List.mem_map.mpr ⟨link, old, equal⟩)

theorem lookup_append_present (key : Link → Nat) (index : Nat) (left right : List Link) (link : Link)
    (found : lookup key index left = some link) : lookup key index (left ++ right) = some link := by
  induction left with
  | nil => simp [lookup] at found
  | cons head tail ih =>
    by_cases h : key head = index
    · simpa [lookup,h] using found
    · simpa [lookup,h] using ih (by simpa [lookup,h] using found)

theorem complete_roundtrip (path : List Step) (residual : List Link)
    (sourceUnique : ((sources path).map Binding.vectorIndex).Nodup)
    (targetUnique : ((targets path).map Binding.vectorIndex).Nodup)
    (a b : Binding) (member : (a,b) ∈ links path) :
    lookup (fun p => p.1.vectorIndex) a.vectorIndex (complete path residual) = some (a,b) ∧
    lookup (fun p => p.2.vectorIndex) b.vectorIndex (complete path residual) = some (a,b) := by
  have h := selected_roundtrip path sourceUnique targetUnique a b member
  exact ⟨lookup_append_present _ _ _ _ _ h.1, lookup_append_present _ _ _ _ _ h.2⟩

-- Every selected zero-cost pair remains a constraint; it never becomes a paid
-- update. Existing typed-read/owner admission theorems remain separate premises.
theorem zero_keep_retained_unpaid (path : List Step) (residual : List Link) (a b : Binding)
    (member : (a,b) ∈ links path) (zero : sameTuple a b = true) :
    (a,b) ∈ complete path residual ∧ (a,b) ∉ paid path :=
  ⟨List.mem_append_left _ member, zero_not_charged path a b zero⟩

theorem original_native_replay (path : List Step) :
    replay (sources path) path = some (targets path,cost path) := extracted_path_replays path

theorem charged_links_retained (path : List Step) (residual : List Link) (link : Link)
    (paidLink : link ∈ paid path) : link ∈ complete path residual :=
  List.mem_append_left _ (List.mem_filter.mp paidLink).1

end JointDeclarationPathSelection
