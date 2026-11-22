import Std

/-! Structural projection of decoded public proof inputs. An ID denotes an already
    resolved object. This model does not decode bytes or prove injectivity of hashes. -/
namespace ACGN.Sixth.EvidenceCoverage

inductive Kind where
  | chain | flat | container
  deriving DecidableEq, Repr

inductive ChildSchema where
  | dependentSeq | seq | bag | set | other
  deriving DecidableEq, Repr

inductive Identity where
  | join | arrow | other
  deriving DecidableEq, Repr

structure Operator where
  id : Nat
  identity : Identity
  flatPath : Option (List Nat)
  schemas : List ChildSchema
  rootHasCheckedLaw : Bool
  deriving DecidableEq, Repr

/-- A non-application has no operator. A path here is the decoded schema path. -/
def requirement : Option Operator → Option (Kind × List Nat)
  | none => none
  | some op =>
    match op.flatPath with
    | some path => some (.flat, path)
    | none =>
      if (op.identity == .join || op.identity == .arrow) && op.schemas == [.dependentSeq]
      then some (.chain, [0, 0])
      else if op.rootHasCheckedLaw && (op.schemas == [.seq] || op.schemas == [.bag] ||
                  op.schemas == [.set] || op.schemas == [.dependentSeq]) then some (.container, [0, 0])
      else none

/-- Preimage of the source-owner hash reconstructed from an insertion and metadata. -/
structure Owner where
  inputIdentifier : Nat
  inputDigest : Nat
  event : Nat
  eclass : Nat
  deriving DecidableEq, Repr

structure KernelNeed where
  owner : Owner
  source : Nat
  operatorId : Nat
  kind : Kind
  path : List Nat
  deriving DecidableEq, Repr

def kernelNeeds (owner : Owner) (source : Nat) (op : Operator) : List KernelNeed :=
  match requirement (some op) with
  | some (kind, path) => [⟨owner, source, op.id, kind, path⟩]
  | none => []

structure BinderNeed where
  root : Nat
  source : Nat
  path : List Nat
  generator : List Nat
  deriving DecidableEq, Repr

/- Finite unfolding of the decoded term DAG. Reused children appear at each
    occurrence. Non-binders have no generators; a binder uses its checked descriptor. -/
mutual
  inductive Term where
    | node (id : Nat) (generators : List (List Nat)) (children : Children)
  inductive Children where
    | nil
    | cons (head : Term) (tail : Children)
end

mutual
  def walk (root : Nat) (path : List Nat) : Term → List BinderNeed
    | .node id gens children =>
      gens.map (fun g => ⟨root, id, path, g⟩) ++ walkChildren root path 0 children
  def walkChildren (root : Nat) (path : List Nat) (index : Nat) : Children → List BinderNeed
    | .nil => []
    | .cons t rest => walk root (path ++ [index]) t ++ walkChildren root path (index + 1) rest
end

/- A separate inductive occurrence specification. The child index advances
    exactly once when crossing a sibling, and the root is unchanged on descent. -/
inductive Position where
  | term (path : List Nat) (t : Term)
  | children (path : List Nat) (index : Nat) (cs : Children)

inductive At (root : Nat) : Position → BinderNeed → Prop where
  | here {p id gs cs g} : g ∈ gs → At root (.term p (.node id gs cs)) ⟨root, id, p, g⟩
  | descend {p id gs cs b} : At root (.children p 0 cs) b → At root (.term p (.node id gs cs)) b
  | head {p i t ts b} : At root (.term (p ++ [i]) t) b → At root (.children p i (.cons t ts)) b
  | tail {p i t ts b} : At root (.children p (i + 1) ts) b → At root (.children p i (.cons t ts)) b

mutual
  theorem walk_exact (root : Nat) (p : List Nat) (t : Term) (b : BinderNeed) :
      b ∈ walk root p t ↔ At root (.term p t) b := by
    cases t with
    | node id gs cs =>
      rw [walk, List.mem_append, List.mem_map, children_exact root p 0 cs b]
      constructor
      · rintro (⟨g, hg, rfl⟩ | h)
        · exact .here hg
        · exact .descend h
      · intro h
        cases h with
        | here hg => exact Or.inl ⟨_, hg, rfl⟩
        | descend hb => exact Or.inr hb
  theorem children_exact (root : Nat) (p : List Nat) (i : Nat) (cs : Children) (b : BinderNeed) :
      b ∈ walkChildren root p i cs ↔ At root (.children p i cs) b := by
    cases cs with
    | nil =>
      constructor <;> intro h <;> cases h
    | cons t ts =>
      rw [walkChildren, List.mem_append, walk_exact root (p ++ [i]) t b,
        children_exact root p (i + 1) ts b]
      constructor
      · rintro (h | h)
        · exact .head h
        · exact .tail h
      · intro h
        cases h with
        | head ha => exact Or.inl ha
        | tail hs => exact Or.inr hs
end

/-- Equality of key sets, as in requireExactCoverage. It does not compare counts. -/
def SameKeys {α : Type} (left right : List α) : Prop :=
  ∀ key, key ∈ left ↔ key ∈ right

theorem orbit_omission_rejected {r p t b supplied}
    (derives : At r (.term p t) b) (omitted : b ∉ supplied) :
    ¬ SameKeys (walk r p t) supplied := by
  intro ok
  exact omitted ((ok b).mp ((walk_exact r p t b).mpr derives))

theorem orbit_surplus_rejected {r p t b supplied}
    (absent : ¬ At r (.term p t) b) (extra : b ∈ supplied) :
    ¬ SameKeys (walk r p t) supplied := by
  intro ok
  exact absent ((walk_exact r p t b).mp ((ok b).mpr extra))

theorem kernel_owner_substitution_rejected {a b source op k path}
    (required : requirement (some op) = some (k, path)) (distinct : a ≠ b) :
    ¬ SameKeys (kernelNeeds a source op) (kernelNeeds b source op) := by
  intro same
  have h := (same ⟨a, source, op.id, k, path⟩).mp
  simp [kernelNeeds, required] at h
  exact distinct h

theorem repeated_reference_preserves_key_set {α : Type} (x : α) (xs : List α) :
    SameKeys (x :: x :: xs) (x :: xs) := by
  intro y
  simp

private def sharedBinder : Term := .node 8 [[1, 0, 2], [0, 2, 1]] .nil
private def repeatedTree : Term :=
  .node 1 [] (.cons sharedBinder (.cons (.node 2 [] (.cons sharedBinder .nil)) .nil))

theorem shared_child_path_and_generator_witness :
    walk 1 [] repeatedTree =
      [⟨1, 8, [0], [1, 0, 2]⟩, ⟨1, 8, [0], [0, 2, 1]⟩,
       ⟨1, 8, [1, 0], [1, 0, 2]⟩, ⟨1, 8, [1, 0], [0, 2, 1]⟩] := by decide

private def remaining : List BinderNeed :=
  [⟨1, 8, [0], [1, 0, 2]⟩, ⟨1, 8, [0], [0, 2, 1]⟩, ⟨1, 8, [1, 0], [1, 0, 2]⟩]

/-- Both supplied ledgers omit the second generator at the nested occurrence.
    Their agreement holds, yet they cannot cover the independent traversal. -/
theorem coordinated_omission_witness :
    SameKeys remaining remaining ∧ ¬ SameKeys (walk 1 [] repeatedTree) remaining := by
  constructor
  · intro _
    exact Iff.rfl
  · apply orbit_omission_rejected (b := ⟨1, 8, [1, 0], [0, 2, 1]⟩)
    · apply (walk_exact ..).mp
      decide
    · decide

#print axioms walk_exact
#print axioms children_exact
#print axioms orbit_omission_rejected
#print axioms orbit_surplus_rejected
#print axioms kernel_owner_substitution_rejected
#print axioms repeated_reference_preserves_key_set
#print axioms shared_child_path_and_generator_witness
#print axioms coordinated_omission_witness

end ACGN.Sixth.EvidenceCoverage
