import Std

namespace Seventh.G08

/-- A primitive signature is its resolved declaration name in the selected module. -/
inductive Tree where
  | sig (name : String)
  | arrow (left right : Tree)
  deriving DecidableEq

abbrev Address := List Bool
abbrev Role := Address × String

def descend (side : Bool) (row : Role) : Role := (side :: row.1, row.2)

def roles : Tree → List Role
  | .sig n => [([], n)]
  | .arrow l r => (roles l).map (descend false) ++ (roles r).map (descend true)

def lookup : Tree → Address → Option String
  | .sig n, [] => some n
  | .arrow l _, false :: tail => lookup l tail
  | .arrow _ r, true :: tail => lookup r tail
  | _, _ => none

theorem census_lookup (tree : Tree) (path : Address) (name : String) :
    (path, name) ∈ roles tree ↔ lookup tree path = some name := by
  induction tree generalizing path with
  | sig n =>
    cases path <;> simp [roles, lookup, eq_comm]
  | arrow l r ihl ihr =>
    cases path with
    | nil => simp [roles, descend, lookup, List.mem_map]
    | cons head tail =>
      cases head <;> simp [roles, descend, lookup, List.mem_map, ← ihl, ← ihr]

theorem lookup_ext (s t : Tree) (same : ∀ path, lookup s path = lookup t path) : s = t := by
  induction s generalizing t with
  | sig a =>
    cases t with
    | sig b => have h := same []; simp [lookup] at h; simp [h]
    | arrow l r => have h := same []; simp [lookup] at h
  | arrow l r ihl ihr =>
    cases t with
    | sig a => have h := same []; simp [lookup] at h
    | arrow l' r' =>
      rw [ihl l' (fun p => same (false :: p)), ihr r' (fun p => same (true :: p))]

theorem census_determines_source (s t : Tree) (h : roles s = roles t) : s = t := by
  apply lookup_ext
  intro p
  have eqs (n : String) : lookup s p = some n ↔ lookup t p = some n := by
    rw [← census_lookup, ← census_lookup, h]
  cases hs : lookup s p with
  | some n => exact ((eqs n).mp hs).symm
  | none =>
    cases ht : lookup t p with
    | none => rfl
    | some n => have := (eqs n).mpr ht; simp [hs] at this

/-- The source scope precedes any digest. A finite map is represented by its sorted
sequence of unique declarations and ordered direct-parent paths. -/
structure Origin where
  subject : String × String
  tree : Tree
  ancestry : List (String × List String)

def payload (o : Origin) := (o.subject, roles o.tree, o.ancestry)

inductive Outcome where | verified | rejected | uncheckable deriving DecidableEq

def replay (origin : Option Origin) (wire : Origin) (ordinaryChecks otherTrustRequired : Bool) : Outcome :=
  if !ordinaryChecks then .rejected
  else if otherTrustRequired then .uncheckable
  else match origin with
    | none => .uncheckable
    | some raw => if payload raw = payload wire then .verified else .rejected

theorem verified_preserves_origin (raw wire : Origin) (checks other : Bool)
    (ok : replay (some raw) wire checks other = .verified) :
    raw.subject = wire.subject ∧ raw.tree = wire.tree ∧ raw.ancestry = wire.ancestry := by
  cases checks <;> cases other <;> simp [replay] at ok
  have h : raw.subject = wire.subject ∧ roles raw.tree = roles wire.tree ∧ raw.ancestry = wire.ancestry := by
    simpa [payload] using ok
  exact ⟨h.1, census_determines_source _ _ h.2.1, h.2.2⟩

theorem missing_or_other_trust_blocks (wire : Origin) (raw : Option Origin) :
    replay none wire true false = .uncheckable ∧ replay raw wire true true = .uncheckable := by
  simp [replay]

#print axioms census_lookup
#print axioms lookup_ext
#print axioms census_determines_source
#print axioms verified_preserves_origin
#print axioms missing_or_other_trust_blocks

end Seventh.G08
