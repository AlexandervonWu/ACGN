import GuardedJoinChain

/- Actual-subtree segmentation. A cut retains the original binary skeleton;
   only its frontier is exposed as Seq ports. Equal final types alone are not
   a reassociation license. Java must additionally check exact intermediate
   types and authenticate the source/context of every retained port. -/
namespace JoinSegmentation
open ACGN.Section3.DependentChainSequence
open ACGN.ThirdFive.GuardedJoinChain

abbrev Syntax (α : Type) := SourceTree α .join

def expand : Syntax (Syntax α) -> Syntax α
  | .leaf t => t
  | .app _ l r => .app .join (expand l) (expand r)

def first : Syntax α -> α
  | .leaf a => a
  | .app _ l _ => first l

def last : Syntax α -> α
  | .leaf a => a
  | .app _ _ r => last r

def nodes : Syntax α -> Nat
  | .leaf _ => 1
  | .app _ l r => 1 + nodes l + nodes r

structure Plan (α : Type) where
  cut : Syntax (Syntax α)
  firstPort : Syntax α
  lastPort : Syntax α
  visits : Nat

def plan (arity : Syntax α -> Nat) : Syntax α -> Plan α
  | .leaf a => ⟨.leaf (.leaf a), .leaf a, .leaf a, 1⟩
  | .app _ l r =>
    let lp := plan arity l
    let rp := plan arity r
    let exposeLeft := 2 <= arity lp.lastPort
    let exposeRight := 2 <= arity rp.firstPort
    ⟨.app .join (if exposeLeft then lp.cut else .leaf l)
        (if exposeRight then rp.cut else .leaf r),
      if exposeLeft then lp.firstPort else l,
      if exposeRight then rp.lastPort else r,
      1 + lp.visits + rp.visits⟩

theorem plan_expands_to_source (arity : Syntax α -> Nat) (t : Syntax α) :
    expand (plan arity t).cut = t := by
  induction t with
  | leaf a => rfl
  | app l r hl hr =>
    simp only [plan]
    split <;> split <;> simp_all [expand]

theorem cached_endpoints (arity : Syntax α -> Nat) (t : Syntax α) :
    first (plan arity t).cut = (plan arity t).firstPort ∧
    last (plan arity t).cut = (plan arity t).lastPort := by
  induction t with
  | leaf a => exact ⟨rfl, rfl⟩
  | app l r hl hr =>
    simp only [plan]
    split <;> split <;> simp_all [first, last]

theorem plan_visits_once (arity : Syntax α -> Nat) (t : Syntax α) :
    (plan arity t).visits = nodes t := by
  induction t with
  | leaf a => rfl
  | app l r hl hr => simp [plan, nodes, hl, hr]

theorem nodes_positive (t : Syntax α) : 0 < nodes t := by
  cases t <;> simp [nodes] <;> omega

theorem cut_size_bound (arity : Syntax α -> Nat) (t : Syntax α) :
    nodes (plan arity t).cut <= nodes t := by
  induction t with
  | leaf a => exact Nat.le_refl _
  | app l r hl hr =>
    have := nodes_positive l
    have := nodes_positive r
    simp only [plan]
    split <;> split <;> simp_all [nodes] <;> omega

theorem ordered_occurrences (c : Syntax (Syntax α)) :
    sourceLeaves (expand c) = (sourceLeaves c).flatMap sourceLeaves := by
  induction c with
  | leaf a => simp [expand, sourceLeaves]
  | app l r hl hr => simp [expand, sourceLeaves, hl, hr]

theorem plan_preserves_occurrences (arity : Syntax α -> Nat) (t : Syntax α) :
    (sourceLeaves (plan arity t).cut).flatMap sourceLeaves = sourceLeaves t := by
  rw [← ordered_occurrences, plan_expands_to_source]

def pack (p : Tree Atom -> Operand Atom) : Syntax (Tree Atom) -> Tree Atom
  | .leaf t => .leaf (p t)
  | .app _ l r => .app .join (pack p l) (pack p r)

theorem packed_cut_semantics (p : Tree Atom -> Operand Atom) (c : Syntax (Tree Atom))
    (linked : ∀ t, t ∈ sourceLeaves c -> (p t).relation = eval t) :
    eval (pack p c) = eval (expand c) := by
  induction c with
  | leaf t => exact linked t (by simp [sourceLeaves])
  | app l r hl hr =>
    have left := hl (fun t h => linked t (by simp [sourceLeaves, h]))
    have right := hr (fun t h => linked t (by simp [sourceLeaves, h]))
    simp [pack, expand, eval, left, right]

/- `p t` contains the actual subtree semantics and its positive, exact tuple
   width (including typed empty relations). The guard is independently checked
   on the exposed frontier, not inferred from an equal output type. -/
theorem presentation_reification_sound (arity : Tree Atom -> Nat)
    (p : Tree Atom -> Operand Atom) (t target : Tree Atom)
    (linked : ∀ s, s ∈ sourceLeaves (plan arity t).cut -> (p s).relation = eval s)
    (samePorts : sourceLeaves (pack p (plan arity t).cut) =
      sourceLeaves target)
    (checked : ACGN.BoundedFive.DependentJoinGuard.guard .JOIN
      ((sourceLeaves (pack p (plan arity t).cut)).map Operand.arity) = true) :
    eval t = eval target := by
  have source := packed_cut_semantics p (plan arity t).cut linked
  rw [plan_expands_to_source] at source
  exact source.symm.trans (accepted_chain_relational_equality _ target samePorts checked)

/- This constructor needs width evidence only for the actual frontier. Values
   outside it are harmless defaults, never semantic claims about invalid trees. -/
noncomputable def portModel (arity : Tree Atom -> Nat) (c : Syntax (Tree Atom))
    (positive : ∀ t, t ∈ sourceLeaves c -> 0 < arity t)
    (width : ∀ t, t ∈ sourceLeaves c -> ∀ row, eval t row -> row.length = arity t)
    (t : Tree Atom) : Operand Atom := by
  classical
  exact if h : t ∈ sourceLeaves c then
    ⟨arity t, positive t h, eval t, width t h⟩ else emptyOperand 1 (by decide)

theorem portModel_linked (arity : Tree Atom -> Nat) (c : Syntax (Tree Atom))
    (positive : ∀ t, t ∈ sourceLeaves c -> 0 < arity t)
    (width : ∀ t, t ∈ sourceLeaves c -> ∀ row, eval t row -> row.length = arity t)
    (t : Tree Atom) (member : t ∈ sourceLeaves c) :
    (portModel arity c positive width t).relation = eval t ∧
    (portModel arity c positive width t).arity = arity t := by
  simp [portModel, member]

theorem typed_frontier_presentation (arity : Tree Atom -> Nat) (t target : Tree Atom)
    (positive : ∀ s, s ∈ sourceLeaves (plan arity t).cut -> 0 < arity s)
    (width : ∀ s, s ∈ sourceLeaves (plan arity t).cut ->
      ∀ row, eval s row -> row.length = arity s)
    (samePorts : sourceLeaves (pack (portModel arity (plan arity t).cut positive width)
      (plan arity t).cut) = sourceLeaves target)
    (checked : ACGN.BoundedFive.DependentJoinGuard.guard .JOIN
      ((sourceLeaves (pack (portModel arity (plan arity t).cut positive width)
        (plan arity t).cut)).map Operand.arity) = true) : eval t = eval target :=
  presentation_reification_sound arity _ t target
    (fun s hs => (portModel_linked arity _ positive width s hs).1) samePorts checked

def witnessArity : Syntax Nat -> Nat
  | .leaf i => if i = 1 then 1 else 2
  | .app _ l r => witnessArity l + witnessArity r - 2

theorem right_unary_barrier_preserved :
    sourceLeaves (plan witnessArity
      (.app .join (.leaf 0) (.app .join (.leaf 1) (.leaf 2)))).cut =
      [.leaf 0, .app .join (.leaf 1) (.leaf 2)] := by decide

theorem left_unary_barrier_preserved :
    sourceLeaves (plan witnessArity
      (.app .join (.app .join (.leaf 0) (.leaf 1)) (.leaf 2))).cut =
      [.app .join (.leaf 0) (.leaf 1), .leaf 2] := by decide

open ACGN.Section3.PhaseA2 (relationJoin)
theorem old_presentation_changes_relation :
    relationJoin [[0, 1]] (relationJoin [[1]] [[0, 2]]) = [] ∧
    relationJoin (relationJoin [[0, 1]] [[1]]) [[0, 2]] = [[2]] := by decide

def witnessR : Operand Nat :=
  ⟨2, by decide, fun row => row ∈ [[0, 1]], by
    intro row h
    have eq : row = [0, 1] := by simpa using h
    subst row; rfl⟩

def witnessS : Operand Nat :=
  ⟨1, by decide, fun row => row ∈ [[1]], by
    intro row h
    have eq : row = [1] := by simpa using h
    subst row; rfl⟩

def witnessT : Operand Nat :=
  ⟨2, by decide, fun row => row ∈ [[0, 2]], by
    intro row h
    have eq : row = [0, 2] := by simpa using h
    subst row; rfl⟩

def witnessInner : Tree Nat := .app .join (.leaf witnessS) (.leaf witnessT)
def witnessSource : Tree Nat := .app .join (.leaf witnessR) witnessInner
def witnessTarget : Tree Nat := .app .join (.leaf witnessR) (.leaf (emptyOperand 1 (by decide)))

def typedArity : Tree Atom -> Nat
  | .leaf a => a.arity
  | .app _ l r => typedArity l + typedArity r - 2

def witnessModel : Tree Nat -> Operand Nat
  | .leaf a => a
  | .app _ _ _ => emptyOperand 1 (by decide)

theorem witness_frontier : sourceLeaves (plan typedArity witnessSource).cut =
    [.leaf witnessR, witnessInner] := by rfl

theorem witness_inner_empty : eval witnessInner = (fun _ => False) := by
  funext row
  apply propext
  change join (fun x => x ∈ [[1]]) (fun x => x ∈ [[0, 2]]) row ↔ False
  rw [← finite_join_refines_relation]
  have empty : relationJoin [[1]] [[0, 2]] = [] := by decide
  rw [empty]
  simp

theorem witness_linked : ∀ s, s ∈ sourceLeaves (plan typedArity witnessSource).cut ->
    (witnessModel s).relation = eval s := by
  intro s member
  rw [witness_frontier] at member
  simp only [List.mem_cons, List.not_mem_nil, or_false] at member
  rcases member with rfl | rfl
  · rfl
  · exact witness_inner_empty.symm

theorem witness_exact_widths : ∀ s, s ∈ sourceLeaves (plan typedArity witnessSource).cut ->
    0 < typedArity s ∧ ∀ row, eval s row -> row.length = typedArity s := by
  intro s member
  rw [witness_frontier] at member
  simp only [List.mem_cons, List.not_mem_nil, or_false] at member
  rcases member with rfl | rfl
  · exact ⟨by decide, witnessR.width⟩
  · refine ⟨by decide, ?_⟩
    intro row h
    rw [witness_inner_empty] at h
    exact False.elim h

theorem concrete_typed_presentation_sound : eval witnessSource = eval witnessTarget := by
  apply presentation_reification_sound typedArity witnessModel witnessSource witnessTarget
  · exact witness_linked
  · rfl
  · decide

/- Pre-multiply admission used by FastBinderOrbit. Products are computed only
   after the division guard; no fixed-width factorial can overflow first. -/
def cappedMultiply (cap acc factor : Nat) : Option Nat :=
  if acc <= cap / factor then some (acc * factor) else none

theorem cappedMultiply_exact (cap acc factor : Nat) (positive : 0 < factor) :
    cappedMultiply cap acc factor = some (acc * factor) ↔ acc * factor <= cap := by
  simp only [cappedMultiply]
  split
  · next h => simp [Nat.le_div_iff_mul_le positive |>.mp h]
  · next h => simp [show ¬ acc * factor <= cap from fun hm => h ((Nat.le_div_iff_mul_le positive).mpr hm)]

theorem cappedMultiply_exhausted (cap acc factor : Nat) (positive : 0 < factor) :
    cappedMultiply cap acc factor = none ↔ cap < acc * factor := by
  simp only [cappedMultiply]
  split
  · next h => simp [show ¬ cap < acc * factor from Nat.not_lt.mpr ((Nat.le_div_iff_mul_le positive).mp h)]
  · next h => simp [show cap < acc * factor from Nat.lt_of_not_ge (fun hm => h ((Nat.le_div_iff_mul_le positive).mpr hm))]

theorem admitted_product_fits (cap acc factor : Nat) (positive : 0 < factor)
    (guard : acc <= cap / factor) (capFits : cap <= 2147483647) :
    acc * factor <= 2147483647 :=
  Nat.le_trans ((Nat.le_div_iff_mul_le positive).mp guard) capFits

theorem orbit_seventh_factor_stops : cappedMultiply 4096 720 7 = none := by decide
theorem orbit_cross_group_product_stops : cappedMultiply 4096 720 6 = none := by decide

end JoinSegmentation
