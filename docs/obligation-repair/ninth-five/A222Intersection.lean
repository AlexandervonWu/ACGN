import Std

namespace A222

/-- A carrier name, its direct-parent path (without the head), and the optional live module identity. -/
structure Col where
  head : Nat
  parents : List Nat
  authority : Option Nat
  deriving DecidableEq, Repr

def Col.path (c : Col) := c.head :: c.parents

def shared (l r : Col) : Prop := l.authority.isSome ∧ l.authority = r.authority

instance (l r : Col) : Decidable (shared l r) := by unfold shared; infer_instance

def firstCommon (l r : Col) := l.path.find? (fun x => r.path.contains x)

inductive Boundary where
  | exact | leftSubtype | rightSubtype | disjoint (common : Nat) | unsupported
  deriving DecidableEq, Repr

/-- Both directions true signals a cycle. Missing shared evidence yields no decision. -/
def classify (l r : Col) : Boundary :=
  if l.head = r.head then .exact
  else if shared l r then
    if r.head ∈ l.parents then
      if l.head ∈ r.parents then .unsupported else .leftSubtype
    else if l.head ∈ r.parents then .rightSubtype
    else match firstCommon l r with
      | some a => .disjoint a
      | none => .unsupported
  else .unsupported

theorem classify_exact (l r : Col) : classify l r = .exact ↔ l.head = r.head := by
  unfold classify
  by_cases h : l.head = r.head <;> by_cases hs : shared l r <;>
    by_cases hl : r.head ∈ l.parents <;> by_cases hr : l.head ∈ r.parents <;>
    cases hc : firstCommon l r <;> simp_all

theorem classify_leftSubtype (l r : Col) : classify l r = .leftSubtype ↔
    l.head ≠ r.head ∧ shared l r ∧ r.head ∈ l.parents ∧ l.head ∉ r.parents := by
  unfold classify
  by_cases h : l.head = r.head <;> by_cases hs : shared l r <;>
    by_cases hl : r.head ∈ l.parents <;> by_cases hr : l.head ∈ r.parents <;>
    cases hc : firstCommon l r <;> simp_all

theorem classify_rightSubtype (l r : Col) : classify l r = .rightSubtype ↔
    l.head ≠ r.head ∧ shared l r ∧ r.head ∉ l.parents ∧ l.head ∈ r.parents := by
  unfold classify
  by_cases h : l.head = r.head <;> by_cases hs : shared l r <;>
    by_cases hl : r.head ∈ l.parents <;> by_cases hr : l.head ∈ r.parents <;>
    cases hc : firstCommon l r <;> simp_all

theorem classify_disjoint (l r : Col) (a : Nat) : classify l r = .disjoint a ↔
    l.head ≠ r.head ∧ shared l r ∧ r.head ∉ l.parents ∧ l.head ∉ r.parents ∧ firstCommon l r = some a := by
  unfold classify
  by_cases h : l.head = r.head <;> by_cases hs : shared l r <;>
    by_cases hl : r.head ∈ l.parents <;> by_cases hr : l.head ∈ r.parents <;>
    cases hc : firstCommon l r <;> simp_all

theorem first_common_paths (l r : Col) (a : Nat) :
    firstCommon l r = some a ↔
      a ∈ r.path ∧ ∃ pre post, l.path = pre ++ a :: post ∧ ∀ x ∈ pre, x ∉ r.path := by
  simp [firstCommon, List.find?_eq_some_iff_append]

/-- The finite parent chain attached to a name has exactly the suffix attached to its
direct parent. This is a local adjacency requirement, independent of overlap. -/
structure Forest where
  parents : Nat → List Nat
  tail : ∀ {a p rest}, parents a = p :: rest → parents p = rest

def Forest.path (f : Forest) (a : Nat) := a :: f.parents a

def fits (f : Forest) (c : Col) : Prop := c.authority.isSome → c.parents = f.parents c.head

def below (f : Forest) (atom carrier : Nat) : Prop := (f.path carrier).IsSuffix (f.path atom)

theorem member_suffix (f : Forest) (a b : Nat) :
    b ∈ f.path a → below f a b := by
  intro h
  have go : ∀ (rest : List Nat) (x : Nat), f.parents x = rest → b ∈ x :: rest → below f x b := by
    intro rest
    induction rest with
    | nil =>
      intro x hx hb
      simp at hb
      subst x
      exact ⟨[], rfl⟩
    | cons p rest ih =>
      intro x hx hb
      rcases List.mem_cons.mp hb with heq | hmem
      · subst x; exact ⟨[], rfl⟩
      · have hp := f.tail hx
        have sub := ih p hp hmem
        apply sub.trans
        exact ⟨[x], by simp [Forest.path, hx, hp]⟩
  exact go _ a rfl h

theorem suffix_member (f : Forest) (a b : Nat) (h : below f a b) : b ∈ f.path a :=
  h.sublist.subset (by simp [Forest.path])

theorem below_order_on_one_atom (f : Forest) {x a b : Nat} (ha : below f x a) (hb : below f x b) :
    below f a b ∨ below f b a := (List.suffix_or_suffix_of_suffix ha hb).symm

theorem diverging_concretes_at_univ (l r : Col) (univ : Nat)
    (hn : l.head ≠ r.head) (s : shared l r) (hl : r.head ∉ l.parents)
    (hr : l.head ∉ r.parents) (hc : firstCommon l r = some univ) :
    classify l r = .disjoint univ := (classify_disjoint ..).2 ⟨hn, s, hl, hr, hc⟩

theorem explicit_univ (l u : Col) (root : u.parents = []) (s : shared l u)
    (member : u.head ∈ l.parents) (ne : l.head ≠ u.head) :
    classify l u = .leftSubtype ∧ classify u l = .rightSubtype := by
  have rev : shared u l := by
    unfold shared at *
    exact ⟨s.2 ▸ s.1, s.2.symm⟩
  exact ⟨(classify_leftSubtype ..).2 ⟨ne, s, member, by simp [root]⟩,
    (classify_rightSubtype ..).2 ⟨ne.symm, rev, by simp [root], member⟩⟩

def chosen (l r : Col) : Boundary → Option Col
  | .exact => some (if l.authority.isNone && r.authority.isSome then r else l)
  | .leftSubtype => some l
  | .rightSubtype => some r
  | _ => none

/-- A carrier denotes all potential atoms whose complete ancestry ends in its path.
Two suffixes of a single potential atom are necessarily comparable. -/
theorem column_semantics (f : Forest) (l r : Col) (fl : fits f l) (fr : fits f r)
    (ok : classify l r ≠ .unsupported) (x : Nat) :
    (∃ c, chosen l r (classify l r) = some c ∧ below f x c.head) ↔
      below f x l.head ∧ below f x r.head := by
  cases e : classify l r with
  | exact =>
    have same := (classify_exact ..).1 e
    simp only [chosen]
    split <;> simp [same]
  | leftSubtype =>
    obtain ⟨_, s, ancestor, _⟩ := (classify_leftSubtype ..).1 e
    rw [fl s.1] at ancestor
    have sub := member_suffix f l.head r.head (List.mem_cons_of_mem _ ancestor)
    simp only [chosen, Option.some.injEq, exists_eq_left']
    exact ⟨fun h => ⟨h, sub.trans h⟩, And.left⟩
  | rightSubtype =>
    obtain ⟨_, s, _, ancestor⟩ := (classify_rightSubtype ..).1 e
    rw [fr (s.2 ▸ s.1)] at ancestor
    have sub := member_suffix f r.head l.head (List.mem_cons_of_mem _ ancestor)
    simp only [chosen, Option.some.injEq, exists_eq_left']
    exact ⟨fun h => ⟨sub.trans h, h⟩, And.right⟩
  | disjoint a =>
    obtain ⟨ne, s, notL, notR, _⟩ := (classify_disjoint ..).1 e
    rw [fl s.1] at notL
    rw [fr (s.2 ▸ s.1)] at notR
    simp [chosen]
    intro hl hr
    rcases below_order_on_one_atom f hl hr with h | h
    · exact notL ((List.mem_cons.mp (suffix_member f _ _ h)).resolve_left ne.symm)
    · exact notR ((List.mem_cons.mp (suffix_member f _ _ h)).resolve_left ne)
  | unsupported => exact (ok e).elim


inductive Outcome where
  | keep (row : List Col) | dropped | unsupported
  deriving DecidableEq, Repr

def prepend (c : Col) : Outcome → Outcome
  | .keep rest => .keep (c :: rest)
  | .dropped => .dropped
  | .unsupported => .unsupported

def product : List Col → List Col → Outcome
  | [], [] => .keep []
  | l :: ls, r :: rs =>
    let b := classify l r
    match chosen l r b with
    | some c => prepend c (product ls rs)
    | none => match b with
      | .disjoint _ => .dropped
      | _ => .unsupported
  | _, _ => .unsupported

def inhabits (f : Forest) : List Col → List Nat → Prop
  | [], [] => True
  | c :: cs, x :: xs => below f x c.head ∧ inhabits f cs xs
  | _, _ => False

def denotes (f : Forest) (ws : List Nat) : Outcome → Prop
  | .keep cs => inhabits f cs ws
  | _ => False

def allFit (f : Forest) (cs : List Col) : Prop := ∀ c ∈ cs, fits f c

theorem prepend_supported {c : Col} {out : Outcome}
    (ok : prepend c out ≠ .unsupported) : out ≠ .unsupported := by
  rintro rfl; exact ok rfl

theorem prepend_matches (f : Forest) (x : Nat) (xs : List Nat) (c : Col) (o : Outcome) :
    denotes f (x :: xs) (prepend c o) ↔ below f x c.head ∧ denotes f xs o := by
  cases o <;> simp [denotes, prepend, inhabits]

theorem none_is_disjoint {l r : Col} {b : Boundary}
    (hc : chosen l r b = none) (ok : b ≠ .unsupported) : ∃ a, b = .disjoint a := by
  cases b <;> simp_all [chosen]

theorem product_semantics (f : Forest) (ls rs : List Col) (fl : allFit f ls)
    (fr : allFit f rs) (ok : product ls rs ≠ .unsupported) (ws : List Nat) :
    denotes f ws (product ls rs) ↔ inhabits f ls ws ∧ inhabits f rs ws := by
  induction ls generalizing rs ws with
  | nil => cases rs <;> cases ws <;> simp_all [product, denotes, inhabits]
  | cons l ls ih =>
    cases rs with
    | nil => simp [product] at ok
    | cons r rs =>
      have hl := fl l (by simp)
      have hr := fr r (by simp)
      have fl' : allFit f ls := fun c h => fl c (List.mem_cons_of_mem _ h)
      have fr' : allFit f rs := fun c h => fr c (List.mem_cons_of_mem _ h)
      have bok : classify l r ≠ .unsupported := by
        intro hu; simp [product, hu, chosen] at ok
      have sem := column_semantics f l r hl hr bok
      cases hc : chosen l r (classify l r) with
      | none =>
        obtain ⟨a, eq⟩ := none_is_disjoint hc bok
        cases ws with
        | nil => simp [product, eq, chosen, denotes, inhabits]
        | cons x xs =>
          have impossible : ¬ (below f x l.head ∧ below f x r.head) := by
            rintro hp; obtain ⟨c, h, _⟩ := (sem x).2 hp; simp [hc] at h
          simp only [product, eq, chosen, denotes, inhabits]
          exact ⟨False.elim, fun h => impossible ⟨h.1.1,h.2.1⟩⟩
      | some c =>
        simp only [product, hc] at ok ⊢
        have tail := ih rs fl' fr' (prepend_supported ok)
        cases ws with
        | nil => cases product ls rs <;> simp [prepend, denotes, inhabits]
        | cons x xs =>
          have head : below f x c.head ↔ below f x l.head ∧ below f x r.head := by
            simpa [hc] using sem x
          rw [prepend_matches, head, tail]
          simp only [inhabits]
          grind

/-- Successful omission names an actual coordinate reached by the loop. The
prefix condition encodes the same short circuit as the public implementation. -/
inductive OmittedAt : List Col → List Col → Prop where
  | here {l r ls rs a} : classify l r = .disjoint a → OmittedAt (l :: ls) (r :: rs)
  | later {l r ls rs c} : chosen l r (classify l r) = some c → OmittedAt ls rs →
      OmittedAt (l :: ls) (r :: rs)

theorem product_omission (ls rs : List Col) : product ls rs = .dropped ↔ OmittedAt ls rs := by
  constructor
  · intro om
    induction ls generalizing rs with
    | nil => cases rs <;> simp [product] at om
    | cons l ls ih =>
      cases rs with
      | nil => simp [product] at om
      | cons r rs =>
        cases hc : chosen l r (classify l r) with
        | some c =>
          simp only [product, hc] at om
          apply OmittedAt.later hc
          apply ih
          cases h : product ls rs <;> simp_all [prepend]
        | none =>
          cases hb : classify l r <;> simp_all [product, chosen]
          exact OmittedAt.here hb
  · intro hm
    induction hm with
    | here h => simp [product, h, chosen]
    | later h _ ih => simp [product, h, ih, prepend]

abbrev Row := List Col
def pairs (left right : List Row) := left.flatMap fun l => right.map fun r => (l,r)

def gather : List (Row × Row) → Option (List Row)
  | [] => some []
  | (l,r) :: tail =>
    match product l r with
    | .unsupported => none
    | .dropped => gather tail
    | .keep row => (gather tail).map (row :: ·)

def familyContains (f : Forest) (rows : List Row) (ws : List Nat) : Prop :=
  ∃ row ∈ rows, inhabits f row ws

theorem gather_semantics (f : Forest) (ps : List (Row × Row)) (out : List Row)
    (wf : ∀ pair ∈ ps, allFit f pair.1 ∧ allFit f pair.2) (hg : gather ps = some out) (ws : List Nat) :
    familyContains f out ws ↔ ∃ p ∈ ps, inhabits f p.1 ws ∧ inhabits f p.2 ws := by
  induction ps generalizing out with
  | nil => simp [gather] at hg; subst out; simp [familyContains]
  | cons pair tail ih =>
    obtain ⟨l,r⟩ := pair
    have ⟨fl,fr⟩ := wf (l,r) (by simp)
    have wf' : ∀ pair ∈ tail, allFit f pair.1 ∧ allFit f pair.2 :=
      fun p hp => wf p (List.mem_cons_of_mem _ hp)
    cases hp : product l r with
    | unsupported => simp [gather, hp] at hg
    | dropped =>
      simp only [gather, hp] at hg
      have sem := product_semantics f l r fl fr (by simp [hp]) ws
      simp only [hp, denotes, false_iff] at sem
      rw [ih out wf' hg]
      simp only [List.mem_cons, exists_eq_or_imp]
      simp [sem]
    | keep row =>
      cases ht : gather tail with
      | none => simp [gather, hp, ht] at hg
      | some rest =>
        simp [gather, hp, ht] at hg
        subst out
        have sem := product_semantics f l r fl fr (by simp [hp]) ws
        simp only [hp, denotes] at sem
        simp only [List.mem_cons, exists_eq_or_imp, familyContains] at *
        rw [sem, ih rest wf' ht]

theorem family_semantics (f : Forest) (left right out : List Row) (ws : List Nat)
    (hl : ∀ p ∈ left, allFit f p) (hr : ∀ p ∈ right, allFit f p)
    (success : gather (pairs left right) = some out) :
    familyContains f out ws ↔ familyContains f left ws ∧ familyContains f right ws := by
  apply Iff.trans (gather_semantics f (pairs left right) out ?_ success ws)
  · simp [pairs, familyContains]
    grind
  · intro p hp
    simp [pairs] at hp
    obtain ⟨l, hl', r, hr', rfl⟩ := hp
    exact ⟨hl l hl',hr r hr'⟩


/-- A finite acyclic primitive-signature parent relation. The decreasing measure exists on
every finite acyclic parser hierarchy; the parser need not supply the measure. -/
structure ParserParents where
  parent : Nat → Option Nat
  depth : Nat → Nat
  decreases : ∀ {x p}, parent x = some p → depth p < depth x

def ParserParents.collect (g : ParserParents) (x : Nat) : List Nat :=
  match _h : g.parent x with
  | none => []
  | some p => p :: g.collect p
termination_by g.depth x
decreasing_by exact g.decreases _h

def ParserParents.forest (g : ParserParents) : Forest where
  parents := g.collect
  tail := by
    intro x p rest hx
    rw [ParserParents.collect] at hx
    split at hx
    · contradiction
    · exact (List.cons.inj hx).1 ▸ (List.cons.inj hx).2

/-- The source while-loop includes the starting node and appends each direct parent,
stopping only at the root. This relational form is independent of the choice of rank. -/
inductive ParentWalk (parent : Nat → Option Nat) : Nat → List Nat → Prop where
  | root {x} : parent x = none → ParentWalk parent x [x]
  | up {x p rest} : parent x = some p → ParentWalk parent p rest → ParentWalk parent x (x :: rest)

theorem parser_path_refines (g : ParserParents) {x path} (walk : ParentWalk g.parent x path) :
    path = g.forest.path x := by
  induction walk with
  | root h =>
    rename_i x
    change [x] = x :: g.collect x
    rw [ParserParents.collect,h]
  | up h rest ih =>
    rename_i x p chain
    change x :: chain = x :: g.collect x
    rw [ParserParents.collect,h]
    exact congrArg (x :: ·) ih

theorem parser_path_exists (g : ParserParents) (x : Nat) :
    ParentWalk g.parent x (g.forest.path x) := by
  cases h : g.parent x with
  | none =>
    have eq : g.forest.path x = [x] := by
      change x :: g.collect x = [x]
      rw [ParserParents.collect,h]
    rw [eq]
    exact ParentWalk.root h
  | some p =>
    have eq : g.forest.path x = x :: g.forest.path p := by
      change x :: g.collect x = x :: p :: g.collect p
      rw [ParserParents.collect,h]
    rw [eq]
    exact ParentWalk.up h (parser_path_exists g p)
termination_by g.depth x
decreasing_by exact g.decreases h

theorem source_column_fits (g : ParserParents) {x parents module}
    (walk : ParentWalk g.parent x (x :: parents)) :
    fits g.forest ⟨x,parents,some module⟩ := by
  intro _
  exact (List.cons.inj (parser_path_refines g walk)).2

#print axioms parser_path_refines
#print axioms parser_path_exists
#print axioms source_column_fits

#print axioms classify_exact
#print axioms classify_leftSubtype
#print axioms classify_rightSubtype
#print axioms classify_disjoint
#print axioms first_common_paths
#print axioms member_suffix
#print axioms suffix_member
#print axioms below_order_on_one_atom
#print axioms diverging_concretes_at_univ
#print axioms explicit_univ
#print axioms column_semantics
#print axioms prepend_supported
#print axioms prepend_matches
#print axioms none_is_disjoint
#print axioms product_semantics
#print axioms product_omission
#print axioms gather_semantics
#print axioms family_semantics
end A222


