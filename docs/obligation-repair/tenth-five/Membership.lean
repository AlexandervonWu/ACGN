import P506SourceNonempty

namespace ACGN.Tenth.Membership
open P506SourceNonempty

inductive Engine | raw | normal | saturation deriving DecidableEq, Repr
inductive Polarity | positive | negative deriving DecidableEq, Repr
inductive Head | empty | universal | ordinary deriving DecidableEq, Repr
inductive Result | literal (b : Bool) | original | cardinality deriving DecidableEq, Repr

def Polarity.apply (pol : Polarity) (p : Prop) : Prop := match pol with
  | .positive => p
  | .negative => ¬ p

def Polarity.bool (pol : Polarity) (b : Bool) : Bool := match pol with
  | .positive => b
  | .negative => !b

def flip : Result → Result
  | .literal b => .literal (!b)
  | r => r

/-- The canonical authority fast path runs before cardinality expansion.
    Saturation uses builtins or expansion but carries no lexical proof map.
    The raw tree retains unknown membership as written. -/
def choose (engine : Engine) (pol : Polarity) (left right : Head)
    (sameArity authority canExpand : Bool) : Result :=
  if engine = .normal && right == .empty && authority then .literal (pol.bool false)
  else if engine != .raw && right == .empty && canExpand then .cardinality
  else if left == .empty && (right == .empty || (engine != .raw && sameArity)) then .literal (pol.bool true)
  else if right == .empty && engine != .saturation && authority then .literal (pol.bool false)
  else if right == .universal then .literal (pol.bool true)
  else .original

def means (pol : Polarity) (value : Result) (left right : Rel α) : Prop :=
  match value with
  | .literal b => b = true
  | .original => pol.apply (subset left right)
  | .cardinality => match pol with
    | .positive => ¬ relNonempty left
    | .negative => relNonempty left

def models : Head → Rel α → Prop
  | .empty, r => r = noneRel
  | .universal, r => r = univRel
  | .ordinary, _ => True

theorem compiled_polarities_choose_duals (e : Engine) (l r : Head) (w a x : Bool) :
    choose e .negative l r w a x = flip (choose e .positive l r w a x) := by
  cases e <;> cases l <;> cases r <;> cases w <;> cases a <;> cases x <;> rfl

theorem literal_polarity (pol : Polarity) (b : Bool) :
    (pol.bool b = true) ↔ pol.apply (b = true) := by cases pol <;> cases b <;> simp [Polarity.bool, Polarity.apply]

theorem exact_literal (pol : Polarity) (b : Bool) (p : Prop) (correspondence : (b = true) ↔ p) :
    (pol.bool b = true) ↔ pol.apply p := by
  rw [literal_polarity]
  cases pol with
  | positive => exact correspondence
  | negative => exact not_congr correspondence

theorem empty_constant {l r : Rel α} (pol : Polarity) (empty : r = noneRel)
    (nonempty : relNonempty l) : (pol.bool false = true) ↔ pol.apply (subset l r) := by
  subst r
  exact exact_literal pol false _ (by simp [nonempty_in_none_is_false nonempty])

theorem left_constant {l r : Rel α} (pol : Polarity) (empty : l = noneRel) :
    (pol.bool true = true) ↔ pol.apply (subset l r) := by
  subst l
  exact exact_literal pol true _ (by simp [none_subset])

theorem univ_constant {l r : Rel α} (pol : Polarity) (all : r = univRel) :
    (pol.bool true = true) ↔ pol.apply (subset l r) := by
  subst r
  exact exact_literal pol true _ (by simp [every_relation_in_univ])

theorem cardinality_correct {l r : Rel α} (pol : Polarity) (empty : r = noneRel) :
    means pol .cardinality l r ↔ pol.apply (subset l r) := by
  subst r
  cases pol with
  | positive => exact (subset_none_iff_no_members l).symm
  | negative => exact (not_subset_none_iff_some_member l).symm

/-- The only binding premise is satisfaction of the original parsed declaration.
    No nonemptiness, duality or Boolean-answer premise is supplied. -/
theorem parsed_decision_sound {α : Type} (e : Engine) (pol : Polarity) (lh rh : Head)
    (root : Root) (scope : List Frame) (name : Nat) (read : Option Slot)
    (saved : List Projection) (now : Nat → Option Projection) (sameArity expand : Bool)
    (domain l r : Rel α) (lv : models lh l) (rv : models rh r)
    (binding : ∀ s d, read = some s → Issued root s d → admits (effective d) domain l) :
    means pol (choose e pol lh rh sameArity (consistent saved now && authorize root scope name read) expand) l r
      ↔ pol.apply (subset l r) := by
  let auth := consistent saved now && authorize root scope name read
  have positive : auth = true → relNonempty l := by
    intro h
    cases hr : read with
    | none => simp [auth,hr,missing_read_never_authorizes] at h
    | some slot =>
      have h' : (consistent saved now && authorize root scope name (some slot)) = true := by simpa [auth,hr] using h
      exact (current_authorized_value_is_nonempty root scope name slot domain l saved now h'
        (fun d hd => binding slot d hr hd)).2
  change means pol (choose e pol lh rh sameArity auth expand) l r ↔ _
  unfold choose
  split
  · rename_i h
    have : rh = .empty ∧ auth = true := by simp at h; exact ⟨h.1.2,h.2⟩
    exact empty_constant pol (by simpa [this.1,models] using rv) (positive this.2)
  split
  · rename_i h
    have : rh = .empty := by simp at h; exact h.1.2
    exact cardinality_correct pol (by simpa [this,models] using rv)
  split
  · rename_i h
    have : lh = .empty := by simp at h; exact h.1
    exact left_constant pol (by simpa [this,models] using lv)
  split
  · rename_i h
    have : rh = .empty ∧ auth = true := by simp at h; exact ⟨h.1.1,h.2⟩
    exact empty_constant pol (by simpa [this.1,models] using rv) (positive this.2)
  split
  · rename_i h
    have : rh = .universal := by simpa using h
    exact univ_constant pol (by simpa [this,models] using rv)
  · rfl

theorem positive_in_none_has_issuing_slot (e : Engine) (root : Root) (scope : List Frame) (name : Nat)
    (read : Option Slot) (saved : List Projection) (now : Nat → Option Projection) (width expand : Bool)
    (folded : choose e .positive .ordinary .empty width (consistent saved now && authorize root scope name read) expand =
      .literal false) :
    ∃ slot d, read = some slot ∧ Visible name slot scope ∧ Issued root slot d ∧
      (effective d = .one ∨ effective d = .some) := by
  apply authorized_has_original
  cases ha : authorize root scope name read with
  | true => rfl
  | false => cases e <;> cases expand <;> simp [choose, ha] at folded

theorem nullable_branches_preserved (e : Engine) (expand w : Bool) :
    choose e .positive .ordinary .empty w false expand ≠ .literal false ∧
    choose e .negative .ordinary .empty w false expand ≠ .literal true := by
  cases e <;> cases expand <;> cases w <;> decide


/-- A canonical subset fact retains an independently derivable inclusion witness. -/
inductive Structural : Rel α → Rel α → Prop where
  | same (r : Rel α) : Structural r r
  | empty (r : Rel α) : Structural noneRel r
  | fullRight (r : Rel α) : Structural r univRel
  | unionLeft {a b c : Rel α} : Structural a c → Structural b c → Structural (union a b) c
  | interRight {a b c : Rel α} : Structural a b → Structural a c → Structural a (intersection b c)
  | unionRight {a b c : Rel α} : Structural a b → Structural a (union b c)
  | unionRightOther {a b c : Rel α} : Structural a c → Structural a (union b c)
  | interLeft {a b c : Rel α} : Structural a c → Structural (intersection a b) c
  | interLeftOther {a b c : Rel α} : Structural b c → Structural (intersection a b) c
  | difference {a b c : Rel α} : Structural a c → Structural (fun x => a x ∧ ¬ b x) c
  | restrict {a b : Rel α} {kept : α → Prop} : Structural a b → Structural (fun x => a x ∧ kept x) b

theorem structural_sound {l r : Rel α} (cert : Structural l r) : subset l r := by
  induction cert with
  | same _ => exact relation_subset_reflexive _
  | empty _ => exact none_subset _
  | fullRight _ => exact every_relation_in_univ _
  | unionLeft _ _ ha hb => exact (union_subset_iff ..).2 ⟨ha,hb⟩
  | interRight _ _ ha hb => exact (subset_intersection_iff ..).2 ⟨ha,hb⟩
  | unionRight _ ha => exact fun x hx => Or.inl (ha x hx)
  | unionRightOther _ ha => exact fun x hx => Or.inr (ha x hx)
  | interLeft _ ha => exact fun x hx => ha x hx.1
  | interLeftOther _ ha => exact fun x hx => ha x hx.2
  | difference _ ha => exact fun x hx => ha x hx.1
  | restrict _ ha => exact fun x hx => ha x hx.1

def allLeft (xs : List (Rel α)) : Rel α := fun v => ∃ x ∈ xs, x v
def allRight (ys : List (Rel α)) : Rel α := fun v => ∀ y ∈ ys, y v

theorem positive_lattice (xs ys : List (Rel α)) :
    subset (allLeft xs) (allRight ys) ↔ ∀ x ∈ xs, ∀ y ∈ ys, subset x y := by
  constructor
  · intro h x hx y hy v hv
    exact h v ⟨x,hx,hv⟩ y hy
  · intro h v hv y hy
    obtain ⟨x,hx,hv⟩ := hv
    exact h x hx y hy v hv

theorem negative_lattice (xs ys : List (Rel α)) :
    (¬ subset (allLeft xs) (allRight ys)) ↔ ∃ x ∈ xs, ∃ y ∈ ys, ¬ subset x y := by
  classical
  rw [positive_lattice]
  constructor
  · intro denied
    apply Classical.byContradiction
    intro nowhere
    apply denied
    intro x hx y hy
    apply Classical.byContradiction
    intro miss
    exact nowhere ⟨x,hx,y,hy,miss⟩
  · rintro ⟨x,hx,y,hy,miss⟩ all
    exact miss (all x hx y hy)

theorem lattice_without_proved_pairs (xs ys : List (Rel α)) (proved : Rel α → Rel α → Bool)
    (witness : ∀ x y, proved x y = true → Structural x y) :
    (subset (allLeft xs) (allRight ys) ↔ ∀ x ∈ xs, ∀ y ∈ ys, proved x y = false → subset x y) ∧
    ((¬ subset (allLeft xs) (allRight ys)) ↔ ∃ x ∈ xs, ∃ y ∈ ys, proved x y = false ∧ ¬ subset x y) := by
  constructor
  · rw [positive_lattice]
    constructor
    · exact fun h x hx y hy _ => h x hx y hy
    · intro h x hx y hy
      cases hp : proved x y with
      | false => exact h x hx y hy hp
      | true => exact structural_sound (witness _ _ hp)
  · rw [negative_lattice]
    constructor
    · rintro ⟨x,hx,y,hy,miss⟩
      cases hp : proved x y with
      | false => exact ⟨x,hx,y,hy,hp,miss⟩
      | true => exact False.elim (miss (structural_sound (witness _ _ hp)))
    · rintro ⟨x,hx,y,hy,_,miss⟩
      exact ⟨x,hx,y,hy,miss⟩

/-- Directness is semantic: a retained membership and an equivalent NO/SOME
    cardinality expansion can have distinct canonical representatives. -/
theorem parsed_results_are_semantic_duals {α : Type} (e : Engine) (lh rh : Head)
    (root : Root) (scope : List Frame) (name : Nat) (read : Option Slot)
    (saved : List Projection) (now : Nat → Option Projection) (sameArity expand : Bool)
    (domain l r : Rel α) (lv : models lh l) (rv : models rh r)
    (binding : ∀ s d, read = some s → Issued root s d → admits (effective d) domain l) :
    let hasSlot := consistent saved now && authorize root scope name read
    means .negative (choose e .negative lh rh sameArity hasSlot expand) l r ↔
      ¬ means .positive (choose e .positive lh rh sameArity hasSlot expand) l r := by
  dsimp only
  rw [parsed_decision_sound e .negative lh rh root scope name read saved now sameArity expand domain l r lv rv binding,
    parsed_decision_sound e .positive lh rh root scope name read saved now sameArity expand domain l r lv rv binding]
  rfl

end ACGN.Tenth.Membership
#print axioms ACGN.Tenth.Membership.compiled_polarities_choose_duals
#print axioms ACGN.Tenth.Membership.parsed_decision_sound
#print axioms ACGN.Tenth.Membership.positive_in_none_has_issuing_slot
#print axioms ACGN.Tenth.Membership.nullable_branches_preserved
#print axioms ACGN.Tenth.Membership.structural_sound
#print axioms ACGN.Tenth.Membership.positive_lattice
#print axioms ACGN.Tenth.Membership.negative_lattice
#print axioms ACGN.Tenth.Membership.lattice_without_proved_pairs
#print axioms ACGN.Tenth.Membership.parsed_results_are_semantic_duals
#print axioms ACGN.Tenth.Membership.literal_polarity
#print axioms ACGN.Tenth.Membership.exact_literal
#print axioms ACGN.Tenth.Membership.empty_constant
#print axioms ACGN.Tenth.Membership.left_constant
#print axioms ACGN.Tenth.Membership.univ_constant
#print axioms ACGN.Tenth.Membership.cardinality_correct
