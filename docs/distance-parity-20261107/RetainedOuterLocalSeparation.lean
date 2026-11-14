import RetainedBothLocalWitnesses

namespace RetainedOuterLocalSeparation
open RetainedBothLocalPaid

/- One lexical route. Sibling routes are independent and may reuse aliases.
   This models copying visible before inserting a fresh local declaration. -/
inductive Scope (outer : List String) : List String → List String → Prop where
  | root : Scope outer outer []
  | enter {visible locals} (prior : Scope outer visible locals)
      (name : String) (fresh : name ∉ visible) :
      Scope outer (name :: visible) (name :: locals)

theorem outer_remains_visible {outer visible locals : List String}
    (scope : Scope outer visible locals) : ∀ name ∈ outer, name ∈ visible := by
  induction scope with
  | root => intro name member; exact member
  | enter prior name fresh ih =>
      intro other member
      exact List.mem_cons_of_mem name (ih other member)

theorem local_does_not_shadow_outer {outer visible locals : List String}
    (scope : Scope outer visible locals) : ∀ name ∈ locals, name ∉ outer := by
  induction scope with
  | root => simp
  | enter prior name fresh ih =>
      intro other member
      rcases List.mem_cons.mp member with same | earlier
      · subst other
        intro outerMember
        exact fresh (outer_remains_visible prior name outerMember)
      · exact ih other earlier

/- Paid DP diagonals and their checked grouped permutations select members of
   the two original outer vectors. The property does not depend on enumeration
   order, tuple cost, or a name prefix. Native incidence still checks payment. -/
inductive OuterLinks (left right : List String) : Mapping → Prop where
  | empty : OuterLinks left right []
  | add {mapping} (prior : OuterLinks left right mapping)
      (source target : String) (a : source ∈ left) (b : target ∈ right) :
      OuterLinks left right ((source, target) :: mapping)

theorem outer_link_endpoints {left right : List String} {mapping : Mapping}
    (built : OuterLinks left right mapping) :
    ∀ entry ∈ mapping, entry.1 ∈ left ∧ entry.2 ∈ right := by
  induction built with
  | empty => simp
  | add prior source target a b ih =>
      intro entry member
      rcases List.mem_cons.mp member with same | earlier
      · subst entry; exact ⟨a, b⟩
      · exact ih entry earlier

theorem derived_separation {left right av al bv bl : List String}
    {mapping : Mapping} (aScope : Scope left av al) (bScope : Scope right bv bl)
    (built : OuterLinks left right mapping) (source target : String)
    (aLocal : source ∈ al) (bLocal : target ∈ bl) :
    source ∉ mapping.map Prod.fst ∧ target ∉ mapping.map Prod.snd := by
  constructor
  · intro member
    obtain ⟨entry, inside, named⟩ := List.mem_map.mp member
    exact local_does_not_shadow_outer aScope source aLocal
      (named ▸ (outer_link_endpoints built entry inside).1)
  · intro member
    obtain ⟨entry, inside, named⟩ := List.mem_map.mp member
    exact local_does_not_shadow_outer bScope target bLocal
      (named ▸ (outer_link_endpoints built entry inside).2)

theorem find_absent (mapping : Mapping) (name : String)
    (absent : name ∉ mapping.map Prod.fst) :
    mapping.find? (fun entry => entry.1 == name) = none := by
  apply List.find?_eq_none.mpr
  intro entry member same
  have equal : entry.1 = name := by simpa using same
  exact absent (List.mem_map.mpr ⟨entry, member, equal⟩)

theorem lookup_extension_away (paid base : Mapping) (name : String)
    (absent : name ∉ paid.map Prod.fst) :
    lookup (paid ++ base) name = lookup base name := by
  simp [lookup, List.find?_append, find_absent paid name absent]

theorem local_charge_extension (paid base : Mapping) (source target : Variable)
    (sourceLocal : source.isLocal = true) (targetLocal : target.isLocal = true)
    (noSource : source.name ∉ paid.map Prod.fst)
    (noTarget : target.name ∉ paid.map Prod.snd) :
    variableCost (paid ++ base) source target = variableCost base source target := by
  have same := lookup_extension_away paid base source.name noSource
  have image : (target.name ∉ (paid ++ base).map Prod.snd) ↔
      target.name ∉ base.map Prod.snd := by
    rw [List.map_append, List.mem_append, not_or]
    exact ⟨fun h => h.2, fun h => ⟨noTarget, h⟩⟩
  simp only [variableCost, sourceLocal, targetLocal, and_self, not_true_eq_false,
    false_and, and_false, ite_false, nameCost, same]
  cases lookup base source.name with
  | none =>
      dsimp only
      by_cases h : source.name = target.name ∧ target.name ∉ base.map Prod.snd
      · have hp : source.name = target.name ∧ target.name ∉ (paid ++ base).map Prod.snd :=
          ⟨h.1, image.mpr h.2⟩
        simp only [h, hp]
      · have hp : ¬ (source.name = target.name ∧ target.name ∉ (paid ++ base).map Prod.snd) :=
          fun p => h ⟨p.1, image.mp p.2⟩
        simp only [h, hp, ite_false]
  | some name => rfl

theorem source_scopes_preserve_local_charge
    {left right av al bv bl : List String} {paid : Mapping}
    (aScope : Scope left av al) (bScope : Scope right bv bl)
    (built : OuterLinks left right paid) (base : Mapping) (source target : Variable)
    (sourceLocal : source.isLocal = true) (targetLocal : target.isLocal = true)
    (aLocal : source.name ∈ al) (bLocal : target.name ∈ bl) :
    variableCost (paid ++ base) source target = variableCost base source target := by
  have separated := derived_separation aScope bScope built source.name target.name aLocal bLocal
  exact local_charge_extension paid base source target sourceLocal targetLocal separated.1 separated.2

-- Nonseparated base mappings remain legal and retain their true native costs.
def localX : Variable := ⟨"x", true, true⟩
theorem occupied_base_target_stays_charged :
    variableCost [("outerA", "outerB"), ("z", "x")] localX localX = 1 ∧
    variableCost [("z", "x")] localX localX = 1 := by decide

theorem local_base_diagonal_stays_free :
    variableCost [("outerA", "outerB"), ("x", "x")] localX localX = 0 := by decide

theorem arbitrary_outer_target_collision_changes_cost :
    variableCost [] localX localX = 0 ∧
    variableCost [("z", "x")] localX localX = 1 := by decide

theorem arbitrary_local_source_collision_changes_cost :
    variableCost [] localX localX = 0 ∧
    variableCost [("x", "y")] localX localX = 1 := by decide

theorem outer_shadow_cannot_be_generated {outer visible locals : List String}
    (scope : Scope outer visible locals) (name : String) (member : name ∈ outer) :
    ¬ (name ∉ visible) := by
  intro fresh
  exact fresh (outer_remains_visible scope name member)

end RetainedOuterLocalSeparation
