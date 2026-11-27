import CoursesPaidAlignmentTie
import CoursesRepairedNative

/- The fourth repair restricts the residual (not fixed) links of one source
   exchange block to each target block. A result includes its original native
   witness; the optimizer never constructs a new mapping or matrix program. -/
namespace SingleSourceClassMinimum

structure Choices (α : Type) where
  first : α
  rest : List α

def Choices.items (s : Choices α) := s.first :: s.rest

def Choices.map (s : Choices α) (f : α → β) : Choices β :=
  ⟨f s.first, s.rest.map f⟩

theorem Choices.items_map (s : Choices α) (f : α → β) :
    (s.map f).items = s.items.map f := rfl

/-- Larger matched-cardinality is primary; smaller matrix charge is secondary. -/
def AtLeast (matched cost : α → Nat) (a b : α) : Prop :=
  matched b ≤ matched a ∧ (matched a = matched b → cost a ≤ cost b)

theorem transitive (m c : α → Nat) {a b z : α}
    (h : AtLeast m c a b) (g : AtLeast m c b z) : AtLeast m c a z := by
  unfold AtLeast at *
  obtain ⟨h₁,h₂⟩ := h
  obtain ⟨g₁,g₂⟩ := g
  constructor
  · omega
  · intro eq
    have ab : m a = m b := by omega
    have bz : m b = m z := by omega
    exact Nat.le_trans (h₂ ab) (g₂ bz)

def prefer (m c : α → Nat) (incumbent next : α) : α :=
  if m incumbent < m next ∨ (m incumbent = m next ∧ c next < c incumbent)
  then next else incumbent

theorem step (m c : α → Nat) (a b : α) :
    (prefer m c a b = a ∨ prefer m c a b = b) ∧
    AtLeast m c (prefer m c a b) a ∧ AtLeast m c (prefer m c a b) b := by
  unfold prefer AtLeast
  split <;> rename_i h
  · exact ⟨Or.inr rfl, ⟨by omega, by omega⟩, ⟨by omega, by omega⟩⟩
  · exact ⟨Or.inl rfl, ⟨by omega, by omega⟩, ⟨by omega, by omega⟩⟩

def optimum (m c : α → Nat) (s : Choices α) : α :=
  s.rest.foldl (prefer m c) s.first

theorem fold_spec (m c : α → Nat) (a : α) (xs : List α) :
    let best := xs.foldl (prefer m c) a
    best ∈ a :: xs ∧ ∀ x ∈ a :: xs, AtLeast m c best x := by
  induction xs generalizing a with
  | nil =>
    simp [AtLeast]
  | cons b bs ih =>
    simp only [List.foldl_cons]
    obtain ⟨whereFrom, aboveA, aboveB⟩ := step m c a b
    obtain ⟨inside, dominates⟩ := ih (prefer m c a b)
    constructor
    · rcases List.mem_cons.mp inside with e | tail
      · rcases whereFrom with h | h
        · exact List.mem_cons.mpr (.inl (e.trans h))
        · exact List.mem_cons.mpr (.inr (List.mem_cons.mpr (.inl (e.trans h))))
      · exact List.mem_cons.mpr (.inr (List.mem_cons.mpr (.inr tail)))
    · intro x hx
      have abovePick := dominates _ List.mem_cons_self
      rcases List.mem_cons.mp hx with h | hx
      · rw [h]
        exact transitive m c abovePick aboveA
      rcases List.mem_cons.mp hx with h | hx
      · rw [h]
        exact transitive m c abovePick aboveB
      · exact dominates x (List.mem_cons.mpr (.inr hx))

theorem optimum_spec (m c : α → Nat) (s : Choices α) :
    optimum m c s ∈ s.items ∧ ∀ x ∈ s.items, AtLeast m c (optimum m c s) x :=
  fold_spec m c s.first s.rest

/-- Even if a witness appears in several restrictions, taking a winner in
    each restriction, then one among those winners, attains the global optimum. -/
def grouped (m c : α → Nat) (parts : Choices (Choices α)) : α :=
  optimum m c (parts.map (optimum m c))

theorem grouped_spec (m c : α → Nat) (whole : Choices α) (parts : Choices (Choices α))
    (covers : ∀ x, x ∈ whole.items ↔ ∃ part ∈ parts.items, x ∈ part.items) :
    grouped m c parts ∈ whole.items ∧
    ∀ x ∈ whole.items, AtLeast m c (grouped m c parts) x := by
  obtain ⟨selected, best⟩ := optimum_spec m c (parts.map (optimum m c))
  rw [Choices.items_map] at selected best
  obtain ⟨p,hp,he⟩ := List.mem_map.mp selected
  have inside : optimum m c (parts.map (optimum m c)) ∈ p.items := by
    rw [← he]
    exact (optimum_spec m c p).1
  refine ⟨(covers _).mpr ⟨p,hp,inside⟩, ?_⟩
  intro x hx
  obtain ⟨part,member,inside⟩ := (covers x).mp hx
  exact transitive m c (best _ (List.mem_map.mpr ⟨part,member,rfl⟩))
    ((optimum_spec m c part).2 _ inside)

/-- The charge tie is resolved only between already attained optima.
    Admitted empty-residual mappings still carry all already fixed links. -/
theorem same_objective_as_unpartitioned (m c : α → Nat) (whole : Choices α)
    (parts : Choices (Choices α))
    (covers : ∀ x, x ∈ whole.items ↔ ∃ part ∈ parts.items, x ∈ part.items) :
    m (grouped m c parts) = m (optimum m c whole) ∧
    c (grouped m c parts) = c (optimum m c whole) := by
  obtain ⟨hm, ha⟩ := optimum_spec m c whole
  obtain ⟨hg, hb⟩ := grouped_spec m c whole parts covers
  obtain ⟨u, p⟩ := ha _ hg
  obtain ⟨v, q⟩ := hb _ hm
  have h : m (grouped m c parts) = m (optimum m c whole) := by omega
  exact ⟨h, Nat.le_antisymm (q h) (p h.symm)⟩

theorem fixed_links_do_not_change_objective (fixed : Nat) (m c : α → Nat) (a b : α) :
    AtLeast (fun x => fixed + m x) c a b ↔ AtLeast m c a b := by
  simp [AtLeast]

/-- An incumbent that attains the best objective survives every subsequent
    tie. Thus block traversal in increasing source-authorized target order can
    choose the earliest attaining block without paying for that choice. -/
theorem first_attaining_survives (m c : α → Nat) (a : α) (xs : List α)
    (dominates : ∀ x ∈ xs, AtLeast m c a x) :
    xs.foldl (prefer m c) a = a := by
  induction xs with
  | nil => rfl
  | cons b bs ih =>
    have hb := dominates b List.mem_cons_self
    have stay : prefer m c a b = a := by
      obtain ⟨hm,hc⟩ := hb
      unfold prefer
      split <;> rename_i h
      · exfalso; rcases h with h | ⟨h,lt⟩
        · omega
        · have := hc h; omega
      · rfl
    simp only [List.foldl_cons, stay]
    exact ih (fun x hx => dominates x (List.mem_cons.mpr (.inr hx)))

/-- Per residual mapping, the monotone one-source-block restriction means
    that its matched target classes, if any, agree. -/
def Fits (block : κ) (targets : List κ) : Prop := ∀ k ∈ targets, k = block

/-- Respect for exchange classes maps every residual link from the sole
    source class to one target class. This concerns residual links only. -/
theorem single_target_of_one_source (links : List τ) (sourceClass : τ → σ)
    (targetClass : τ → κ) (sole : σ)
    (oneSource : ∀ e ∈ links, sourceClass e = sole)
    (classRespect : ∀ e ∈ links, ∀ f ∈ links,
      sourceClass e = sourceClass f → targetClass e = targetClass f) :
    ∀ i ∈ links.map targetClass, ∀ j ∈ links.map targetClass, i = j := by
  intro i hi j hj
  obtain ⟨e,he,rfl⟩ := List.mem_map.mp hi
  obtain ⟨f,hf,rfl⟩ := List.mem_map.mp hj
  exact classRespect e he f hf ((oneSource e he).trans (oneSource f hf).symm)

theorem matched_class_is_unique {links : List κ} {i j : κ}
    (nonempty : ∃ k, k ∈ links) (hi : Fits i links) (hj : Fits j links) : i = j := by
  obtain ⟨k,hk⟩ := nonempty
  exact (hi k hk).symm.trans (hj k hk)

theorem unmatched_fits_every_restriction (i : κ) : Fits i [] := by simp [Fits]

/-- Each class restriction contains precisely the original admitted mappings
    whose residual targets fit this block. The empty residual fits every
    nonempty target-class domain; witness duplication does not affect coverage. -/
theorem restrict_cover (whole : Choices α) (blocks : Choices κ) (fiber : κ → Choices α)
    (targets : α → List κ)
    (exactDomain : ∀ k ∈ blocks.items, ∀ x,
      x ∈ (fiber k).items ↔ x ∈ whole.items ∧ Fits k (targets x))
    (single : ∀ x ∈ whole.items, ∀ i ∈ targets x, ∀ j ∈ targets x, i = j)
    (available : ∀ x ∈ whole.items, ∀ k ∈ targets x, k ∈ blocks.items) :
    ∀ x, x ∈ whole.items ↔ ∃ part ∈ (blocks.map fiber).items, x ∈ part.items := by
  intro x
  rw [Choices.items_map]
  constructor
  · intro hx
    cases h : targets x with
    | nil =>
      have firstFits : Fits blocks.first (targets x) := h ▸ unmatched_fits_every_restriction _
      have firstIn : blocks.first ∈ blocks.items := List.mem_cons_self
      exact ⟨fiber blocks.first, List.mem_map.mpr ⟨_,firstIn,rfl⟩,
        (exactDomain _ firstIn x).mpr ⟨hx,firstFits⟩⟩
    | cons k tail =>
      have hmem : k ∈ targets x := by rw [h]; exact List.mem_cons_self
      have key := available x hx k hmem
      exact ⟨fiber k,List.mem_map.mpr ⟨k,key,rfl⟩,
        (exactDomain k key x).mpr ⟨hx,fun j hj => single x hx j hj k hmem⟩⟩
  · rintro ⟨_,hp,hx⟩
    obtain ⟨k,hk,rfl⟩ := List.mem_map.mp hp
    exact ((exactDomain k hk x).mp hx).1

/-- Direct specialization of the lexicographic optimum theorem to the
    residual target-block search used by the fourth repair. -/
theorem split_single_source_preserves_minimum (m c : α → Nat)
    (whole : Choices α) (blocks : Choices κ) (fiber : κ → Choices α)
    (targets : α → List κ)
    (exactDomain : ∀ k ∈ blocks.items, ∀ x,
      x ∈ (fiber k).items ↔ x ∈ whole.items ∧ Fits k (targets x))
    (single : ∀ x ∈ whole.items, ∀ i ∈ targets x, ∀ j ∈ targets x, i = j)
    (available : ∀ x ∈ whole.items, ∀ k ∈ targets x, k ∈ blocks.items) :
    let repaired := grouped m c (blocks.map fiber)
    repaired ∈ whole.items ∧ m repaired = m (optimum m c whole) ∧
      c repaired = c (optimum m c whole) := by
  have h := restrict_cover whole blocks fiber targets exactDomain single available
  exact ⟨(grouped_spec m c whole _ h).1, same_objective_as_unpartitioned m c whole _ h⟩

/-- If the original domain has an unmatched candidate (the already fixed
    mapping), every target class restriction is nonempty. No dummy optimum
    is introduced for classes with zero compatible residual links. -/
theorem empty_residual_witness_in_every_fiber (raw : List α) (residual : α → List κ)
    (x : α) (belongs : x ∈ raw) (unmatched : residual x = []) :
    ∀ k : κ, ∃ y ∈ raw, Fits k (residual y) := by
  intro k
  exact ⟨x,belongs,unmatched ▸ unmatched_fits_every_restriction k⟩

namespace Incident
open CoursesPaidAlignmentTie

/-- The ordered class restrictions in the two inv5 examples. The middle
    SOME Person block admits no residual match; its unmatched option is real. -/
def scopes : Choices (Choices ScopeChoice) :=
  ⟨⟨.project,[.unassigned]⟩,[⟨.unassigned,[]⟩,⟨.person,[.unassigned]⟩]⟩

def scopeCost (matchedCost unmatchedCost : Nat) : ScopeChoice → Nat
  | .unassigned => unmatchedCost
  | .project | .person => matchedCost

theorem repaired_prior_selects_project (matchedCost unmatchedCost : Nat) :
    grouped kept (scopeCost matchedCost unmatchedCost) scopes = .project := by
  simp [grouped, optimum, Choices.map, scopes, kept, scopeCost, prefer]

def priorBits (s : ScopeChoice) (paidWitnessBits : List Bool) : List Bool :=
  (paidWitnessBits.set 2 (s == .person)).set 4 (s == .project)

/-- Leave the paid paths' existing flags unchanged. For the empty-paid
    cases, use the actual first winning scope. Both repaired winners then
    match the previously measured Certified programs. -/
theorem repaired_inv5_programs (unmatchedCost : Nat) :
    let fast783 := priorBits (grouped kept (scopeCost 22 unmatchedCost) scopes)
      CoursesPaidData.p783FastExisting
    let fast826 := priorBits (grouped kept (scopeCost 21 unmatchedCost) scopes)
      CoursesPaidData.p826FastExisting
    winner CoursesPaidData.p783Costs fast783 =
      winner CoursesPaidData.p783Costs CoursesPaidData.p783CertifiedExisting ∧
    winner CoursesPaidData.p826Costs fast826 =
      winner CoursesPaidData.p826Costs CoursesPaidData.p826CertifiedExisting ∧
    winner CoursesPaidData.p783Costs fast783 = .keepProject ∧
    winner CoursesPaidData.p826Costs fast826 = .twoUpdates := by
  simp only [repaired_prior_selects_project]
  decide

def wireEdit : DeclarationReplay.Edit → String × Option Nat × Option Nat × Nat
  | .insert b => ("insert", none, some b.occurrence, 1)
  | .delete a => ("delete", some a.occurrence, none, 1)
  | .pair a b =>
    if a.tuple = b.tuple then ("keep", some a.occurrence, some b.occurrence, 0)
    else ("update", some a.occurrence, some b.occurrence, 1)

/-- Check the newly emitted Fast matrix and declaration actions against the
    protected Certified choices and matrix programs, in original order. -/
theorem measured_repair_reproduces_the_certified_programs :
    CoursesRepairedNative.p783Declaration = (prefixProgram
      (winner CoursesPaidData.p783Costs CoursesPaidData.p783CertifiedExisting)).map wireEdit ∧
    CoursesRepairedNative.p783Fast = CoursesPaidData.p783CertifiedMatrix ∧
    CoursesRepairedNative.p826Declaration = (prefixProgram
      (winner CoursesPaidData.p826Costs CoursesPaidData.p826CertifiedExisting)).map wireEdit ∧
    CoursesRepairedNative.p826Fast = CoursesPaidData.p826CertifiedMatrix := by decide

end Incident

#print axioms fold_spec
#print axioms grouped_spec
#print axioms same_objective_as_unpartitioned
#print axioms fixed_links_do_not_change_objective
#print axioms first_attaining_survives
#print axioms single_target_of_one_source
#print axioms matched_class_is_unique
#print axioms restrict_cover
#print axioms split_single_source_preserves_minimum
#print axioms empty_residual_witness_in_every_fiber
#print axioms Incident.repaired_prior_selects_project
#print axioms Incident.repaired_inv5_programs
#print axioms Incident.measured_repair_reproduces_the_certified_programs

end SingleSourceClassMinimum
