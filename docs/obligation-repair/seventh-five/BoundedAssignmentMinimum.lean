import Std

namespace ACGN.Seventh.BoundedAssignment

-- The Alloy parser and producer projection supply these two field observations in
-- certified occurrence order. This model does not refine that JVM boundary.
structure Operand where
  negative : Bool
  field : String
  relationType : String
  deriving DecidableEq

abbrev Sides := Fin 2 → Operand
abbrev Map2 := Fin 3 × Fin 3

-- Target numbers 0 and 1 denote matches, 2 denotes deletion. An unused
-- target must be inserted. A live target can be assigned at most once.
def admissible (m : Map2) : Prop := m.1 = 2 ∨ m.1 ≠ m.2
instance (m : Map2) : Decidable (admissible m) := inferInstanceAs (Decidable (_ ∨ _))
def maps : List Map2 := [(2,2), (2,0), (2,1), (0,2), (0,1), (1,2), (1,0)]

theorem maps_exact (m : Map2) : m ∈ maps ↔ admissible m := by
  rcases m with ⟨a,b⟩
  revert a b
  decide

theorem maps_once : maps.Nodup := by decide

-- The certified SET solver uses a padded square with two dummy rows and
-- columns. These four column selections describe a permutation precisely when
-- no two rows use the same column. Only the real-real matches survive.
def toChoice (c : Fin 4) : Fin 3 := if c = 0 then 0 else if c = 1 then 1 else 2
def padded (a b c d : Fin 4) : Prop := [a,b,c,d].Nodup
instance (a b c d : Fin 4) : Decidable (padded a b c d) := inferInstanceAs (Decidable ([_ ,_ ,_ ,_].Nodup))

theorem padded_maps_exact (m : Map2) :
    admissible m ↔ ∃ a b c d : Fin 4, padded a b c d ∧ (toChoice a,toChoice b) = m := by
  rcases m with ⟨i,j⟩
  revert i j
  decide

inductive Address
  | predicate | conjunction | operand (i : Fin 2) | field (i : Fin 2)
  deriving DecidableEq

inductive Action
  | emptyDeclarations
  | pair (source target : Address) (charge : Nat)
  | delete (source : Address) (charge : Nat)
  | insert (target : Address) (charge : Nat)
  deriving DecidableEq

def Action.cost : Action → Nat
  | .emptyDeclarations => 0
  | .pair _ _ c | .delete _ c | .insert _ c => c

def edits (left right : Sides) (i : Fin 2) (choice : Fin 3) : List Action :=
  if h : choice.val < 2 then
    let j : Fin 2 := ⟨choice.val,h⟩
    let x := left i
    let y := right j
    [.pair (.operand i) (.operand j) (if x.negative = y.negative then 0 else 1),
     .pair (.field i) (.field j) (if x.field = y.field ∧ x.relationType = y.relationType then 0 else 1)]
  else [.delete (.operand i) 2]

def insertion (m : Map2) (j : Fin 2) : List Action :=
  if m.1.val = j.val ∨ m.2.val = j.val then [] else [.insert (.operand j) 2]

def program (left right : Sides) (m : Map2) : List Action :=
  [.emptyDeclarations, .pair .predicate .predicate 0, .pair .conjunction .conjunction 0] ++
  edits left right 0 m.1 ++ edits left right 1 m.2 ++ insertion m 0 ++ insertion m 1

def charge (xs : List Action) : Nat := (xs.map Action.cost).sum
def minimum (l r : Sides) : Option Nat := (maps.map (fun m => charge (program l r m))).min?

theorem minimum_over_all_admissible (l r : Sides) (n : Nat) :
    minimum l r = some n ↔
    (∃ m, admissible m ∧ charge (program l r m) = n) ∧
    (∀ m, admissible m → n ≤ charge (program l r m)) := by
  rw [minimum, List.min?_eq_some_iff]
  constructor
  · rintro ⟨hn, hall⟩
    obtain ⟨m, hm, he⟩ := List.mem_map.mp hn
    exact ⟨⟨m, (maps_exact m).mp hm, he⟩,
      fun m ha => hall _ (List.mem_map.mpr ⟨m, (maps_exact m).mpr ha, rfl⟩)⟩
  · rintro ⟨⟨m, ha, he⟩, hall⟩
    refine ⟨List.mem_map.mpr ⟨m, (maps_exact m).mpr ha, he⟩, ?_⟩
    intro x hx
    obtain ⟨m', hm', rfl⟩ := List.mem_map.mp hx
    exact hall m' ((maps_exact m').mp hm')

structure Owner where
  sourceDigest : String
  selectedPredicate : String
  observationDigest : String
  deriving DecidableEq

structure Receipt where
  source : Owner
  target : Owner
  actions : List Action

def accepts (s t : Owner) (l r : Sides) (x : Receipt) : Bool :=
  decide (x.source = s ∧ x.target = t) &&
  maps.any (fun m => decide (x.actions = program l r m ∧ minimum l r = some (charge x.actions)))

theorem accepts_exact (s t : Owner) (l r : Sides) (x : Receipt) :
    accepts s t l r x = true ↔ x.source = s ∧ x.target = t ∧
      ∃ m, admissible m ∧ x.actions = program l r m ∧
        ∀ k, admissible k → charge x.actions ≤ charge (program l r k) := by
  simp only [accepts, Bool.and_eq_true, decide_eq_true_eq, List.any_eq_true]
  constructor
  · rintro ⟨⟨hs, ht⟩, m, hm, hx, hmin⟩
    exact ⟨hs, ht, m, (maps_exact m).mp hm, hx, ((minimum_over_all_admissible l r _).mp hmin).2⟩
  · rintro ⟨hs, ht, m, ha, hx, hall⟩
    exact ⟨⟨hs, ht⟩, m, (maps_exact m).mpr ha, hx,
      (minimum_over_all_admissible l r _).mpr ⟨⟨m, ha, congrArg charge hx.symm⟩, hall⟩⟩

theorem foreign_owner_rejected (s t : Owner) (l r : Sides) (x : Receipt)
    (h : x.source ≠ s ∨ x.target ≠ t) : accepts s t l r x ≠ true := by
  intro hx
  obtain ⟨hs, ht, _⟩ := (accepts_exact s t l r x).mp hx
  exact h.elim (fun hn => hn hs) (fun hn => hn ht)

theorem incomplete_or_foreign_actions_rejected (s t : Owner) (l r : Sides) (x : Receipt)
    (h : ∀ m, admissible m → x.actions ≠ program l r m) : accepts s t l r x ≠ true := by
  intro hx
  obtain ⟨_, _, m, ha, he, _⟩ := (accepts_exact s t l r x).mp hx
  exact h m ha he

theorem suboptimal_rejected (s t : Owner) (l r : Sides) (x : Receipt) (k : Map2)
    (hk : admissible k) (hc : charge (program l r k) < charge x.actions) :
    accepts s t l r x ≠ true := by
  intro hx
  obtain ⟨_, _, _, _, _, hall⟩ := (accepts_exact s t l r x).mp hx
  exact (Nat.not_lt_of_ge (hall k hk)) hc

#print axioms maps_exact
#print axioms maps_once
#print axioms padded_maps_exact
#print axioms minimum_over_all_admissible
#print axioms accepts_exact
#print axioms foreign_owner_rejected
#print axioms incomplete_or_foreign_actions_rejected
#print axioms suboptimal_rejected

end ACGN.Seventh.BoundedAssignment
