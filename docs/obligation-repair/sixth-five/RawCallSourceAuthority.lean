import Std


namespace ACGN.Sixth.RawCallSourceAuthority

/- The input is the resolved syntax of the supported raw Alloy fragment: a
   uniquely selected, local, nullary predicate with body `some expr`. Expressions
   are primitive signature leaves or local expression calls. Exact module-byte
   hashing, Alloy parsing, name resolution, type attribution, and the Java-to-model
   observation link are outside this theorem. Strings for types denote complete
   resolved descriptors. Their interpretation and subtyping belong to Alloy. -/
structure Root where
  sourceDigest : String
  qualifiedPredicate : String
  deriving DecidableEq, Repr

structure Callee where
  spelling : String
  qualifiedName : String
  parameterTypes : List String
  resultType : String
  deriving DecidableEq, Repr

mutual
inductive Expr where
  | signature (qualifiedName type : String)
  | call (declaration : Callee) (arguments : Args)
inductive Args where
  | nil
  | cons (argument : Expr) (rest : Args)
end

/-- All paths are relative to the matrix of phase zero in this fragment. -/
abbrev Path := List Nat

/-- A nested call is owned at its argument's child path. -/
inductive Endpoint where
  | signature (qualifiedName type : String)
  | call (child : Path) (resultType : String)
  deriving DecidableEq, Repr

def endpointType : Endpoint → String
  | .signature _ ty => ty
  | .call _ ty => ty

def endpoint (child : Path) : Expr → Endpoint
  | .signature name ty => .signature name ty
  | .call decl _ => .call child decl.resultType

structure Port where
  role : Nat
  target : Endpoint
  deriving DecidableEq, Repr

def ports (parent : Path) (role : Nat) : Args → List Port
  | .nil => []
  | .cons arg rest =>
    ⟨role, endpoint (parent ++ [role]) arg⟩ :: ports parent (role + 1) rest

structure Site where
  path : Path
  callee : Callee
  arguments : List Port
  deriving DecidableEq, Repr

mutual
def walk (path : Path) : Expr → List Site
  | .signature _ _ => []
  | .call decl args => ⟨path, decl, ports path 0 args⟩ :: walkArgs path 0 args
def walkArgs (parent : Path) (role : Nat) : Args → List Site
  | .nil => []
  | .cons arg rest => walk (parent ++ [role]) arg ++ walkArgs parent (role + 1) rest
end

/- A source occurrence is reached by descending ordered arguments from the
    selected body, without using any submitted row, anchor, or wire ordinal. -/
mutual
inductive AtSite : Path → Expr → Site → Prop where
  | here (p : Path) (d : Callee) (as : Args) :
      AtSite p (.call d as) ⟨p, d, ports p 0 as⟩
  | argument {p : Path} {d : Callee} {as : Args} {s : Site} :
      AtArgs p 0 as s → AtSite p (.call d as) s
inductive AtArgs : Path → Nat → Args → Site → Prop where
  | first {p : Path} {i : Nat} {a : Expr} {rest : Args} {s : Site} :
      AtSite (p ++ [i]) a s → AtArgs p i (.cons a rest) s
  | later {p : Path} {i : Nat} {a : Expr} {rest : Args} {s : Site} :
      AtArgs p (i + 1) rest s → AtArgs p i (.cons a rest) s
end

mutual
theorem walk_exact (p : Path) (e : Expr) (s : Site) : s ∈ walk p e ↔ AtSite p e s := by
  cases e with
  | signature => exact ⟨fun h => by simp [walk] at h, fun h => by cases h⟩
  | call d args =>
    constructor
    · intro h
      rcases List.mem_cons.mp h with eq | below
      · rw [eq]; exact .here ..
      · exact .argument ((walkArgs_exact p 0 args s).mp below)
    · intro h
      cases h with
      | here => exact List.mem_cons_self
      | argument h => exact List.mem_cons_of_mem _ ((walkArgs_exact p 0 args s).mpr h)
theorem walkArgs_exact (p : Path) (i : Nat) (as : Args) (s : Site) :
    s ∈ walkArgs p i as ↔ AtArgs p i as s := by
  cases as with
  | nil => exact ⟨fun h => by simp [walkArgs] at h, fun h => by cases h⟩
  | cons a rest =>
    constructor
    · intro h
      rcases List.mem_append.mp h with first | later
      · exact .first ((walk_exact (p ++ [i]) a s).mp first)
      · exact .later ((walkArgs_exact p (i + 1) rest s).mp later)
    · intro h
      cases h with
      | first h => exact List.mem_append_left _ ((walk_exact (p ++ [i]) a s).mpr h)
      | later h => exact List.mem_append_right _ ((walkArgs_exact p (i + 1) rest s).mpr h)
end

mutual
def callCount : Expr → Nat
  | .signature _ _ => 0
  | .call _ args => callCountArgs args + 1
def callCountArgs : Args → Nat
  | .nil => 0
  | .cons arg rest => callCount arg + callCountArgs rest
end

mutual
theorem walk_count (path : Path) (e : Expr) : (walk path e).length = callCount e := by
  cases e with
  | signature => rfl
  | call d args => simp [walk, callCount, walkArgs_count path 0 args]
theorem walkArgs_count (parent : Path) (role : Nat) (args : Args) :
    (walkArgs parent role args).length = callCountArgs args := by
  cases args with
  | nil => rfl
  | cons arg rest =>
    simp [walkArgs, callCountArgs, walk_count (parent ++ [role]) arg,
      walkArgs_count parent (role + 1) rest]
end

/-- The parent row precedes its nested calls. Distinct operand positions give
    distinct child paths even when the same declaration and type recur. -/
theorem nested_argument_owner (path : Path) (d c : Callee) (children rest : Args) :
    (walk path (.call d (.cons (.call c children) rest))).take 2 =
      [⟨path, d, ⟨0, .call (path ++ [0]) c.resultType⟩ :: ports path 1 rest⟩,
       ⟨path ++ [0], c, ports (path ++ [0]) 0 children⟩] := by
  simp [walk, walkArgs, ports, endpoint, List.take]

theorem ordered_binary_ports (path : Path) (a b : Expr) :
    ports path 0 (.cons a (.cons b .nil)) =
      [⟨0, endpoint (path ++ [0]) a⟩, ⟨1, endpoint (path ++ [1]) b⟩] := rfl

structure Predicate where
  qualifiedName : String
  body : Expr

structure ParsedModule where
  sourceDigest : String
  predicates : List Predicate

def candidates (m : ParsedModule) (name : String) : List Predicate :=
  m.predicates.filter (fun p => p.qualifiedName == name)

def selectRoot (m : ParsedModule) (name : String) : Option Predicate :=
  match candidates m name with
  | [p] => some p
  | _ => none

theorem selected_unique (m : ParsedModule) (name : String) (p : Predicate) :
    selectRoot m name = some p ↔ candidates m name = [p] := by
  unfold selectRoot
  cases candidates m name with
  | nil => simp
  | cons x xs => cases xs <;> simp

theorem selected_name (m : ParsedModule) (name : String) (p : Predicate)
    (selected : selectRoot m name = some p) : p ∈ m.predicates ∧ p.qualifiedName = name := by
  have h : p ∈ candidates m name := by rw [(selected_unique ..).mp selected]; simp
  simpa [candidates] using h

abbrev Row := Site × Nat
abbrev Anchor := Path × Nat

structure Evidence where
  root : Root
  rows : List Row
  anchors : List Anchor
  deriving DecidableEq, Repr

/-- Independent of every submitted row and anchor. The two child edges are
    the fixed predicate/multiplicity wrappers of the Java fixture. -/
def derive (m : ParsedModule) (p : Predicate) : Evidence :=
  let rows := (walk [0, 0] p.body).zipIdx
  ⟨⟨m.sourceDigest, p.qualifiedName⟩, rows, rows.map (fun (site, i) => (site.path, i))⟩

/-- The admitted fixture uses exact resolved types for unary signature
    arguments. List equality checks both arity and position. -/
def typed (s : Site) : Bool :=
  decide (s.arguments.map (fun port => endpointType port.target) = s.callee.parameterTypes)

def typedBody (p : Predicate) : Bool := (walk [0, 0] p.body).all typed

def verify (m : ParsedModule) (wanted : String) (submitted : Evidence) : Bool :=
  match selectRoot m wanted with
  | none => false
  | some p => typedBody p && decide (submitted = derive m p)

theorem verify_exact (m : ParsedModule) (wanted : String) (submitted : Evidence) :
    verify m wanted submitted = true ↔
      ∃ p, selectRoot m wanted = some p ∧ typedBody p = true ∧ submitted = derive m p := by
  cases h : selectRoot m wanted <;> simp [verify, h]

theorem verified_occurrence_count (m : ParsedModule) (wanted : String) (submitted : Evidence)
    (p : Predicate) (s : selectRoot m wanted = some p) (h : verify m wanted submitted = true) :
    submitted.rows.length = callCount p.body := by
  have checked : typedBody p = true ∧ submitted = derive m p := by simpa [verify, s] using h
  simp [checked.2, derive, walk_count]

theorem verified_sites_exact (m : ParsedModule) (wanted : String) (submitted : Evidence)
    (p : Predicate) (s : selectRoot m wanted = some p) (h : verify m wanted submitted = true)
    (site : Site) : site ∈ submitted.rows.map Prod.fst ↔ AtSite [0, 0] p.body site := by
  have checked : typedBody p = true ∧ submitted = derive m p := by simpa [verify, s] using h
  simpa [checked.2, derive, List.zipIdx_map_fst] using walk_exact [0, 0] p.body site

theorem verified_argument_types (m : ParsedModule) (wanted : String) (submitted : Evidence)
    (p : Predicate) (s : selectRoot m wanted = some p) (h : verify m wanted submitted = true)
    (site : Site) (occurs : AtSite [0, 0] p.body site) :
    site.arguments.map (fun port => endpointType port.target) = site.callee.parameterTypes := by
  have checked : typedBody p = true ∧ submitted = derive m p := by simpa [verify, s] using h
  have matchTypes := List.all_eq_true.mp checked.1 site ((walk_exact ..).mpr occurs)
  simpa [typed] using matchTypes

/-- Deleting any actual row rejects even when an attacker changes every anchor
    to agree with the shortened row list. -/
theorem coordinated_omission_rejected (m : ParsedModule) (wanted : String) (p : Predicate)
    (s : selectRoot m wanted = some p) (before after : List Row) (removed : Row)
    (whole : (derive m p).rows = before ++ removed :: after)
    (root : Root) (changedAnchors : List Anchor) :
    verify m wanted ⟨root, before ++ after, changedAnchors⟩ = false := by
  have different : (Evidence.mk root (before ++ after) changedAnchors) ≠ derive m p := by
    intro eq
    have lengths := congrArg (fun (x : Evidence) => x.rows.length) eq
    change (before ++ after).length = (derive m p).rows.length at lengths
    rw [whole, List.length_append, List.length_append, List.length_cons] at lengths
    exact Nat.ne_of_lt (Nat.lt_succ_self _) (Nat.add_left_cancel lengths)
  simp [verify, s, different]

theorem foreign_root_rejected (m : ParsedModule) (wanted : String) (p : Predicate)
    (s : selectRoot m wanted = some p) (submitted : Evidence)
    (foreignRoot : submitted.root ≠ ⟨m.sourceDigest, wanted⟩) :
    verify m wanted submitted = false := by
  have different : submitted ≠ derive m p := by
    intro eq
    apply foreignRoot
    simp [eq, derive, (selected_name m wanted p s).2]
  simp [verify, s, different]

theorem changed_order_or_types_rejected (m : ParsedModule) (wanted : String) (p : Predicate)
    (s : selectRoot m wanted = some p) (submitted : Evidence)
    (different : submitted.rows ≠ (derive m p).rows) : verify m wanted submitted = false := by
  have ne : submitted ≠ derive m p := fun eq => different (congrArg Evidence.rows eq)
  simp [verify, s, ne]

#print axioms walk_exact
#print axioms walkArgs_exact
#print axioms walk_count
#print axioms walkArgs_count
#print axioms nested_argument_owner
#print axioms ordered_binary_ports
#print axioms selected_unique
#print axioms selected_name
#print axioms verify_exact
#print axioms verified_occurrence_count
#print axioms verified_sites_exact
#print axioms verified_argument_types
#print axioms coordinated_omission_rejected
#print axioms foreign_root_rejected
#print axioms changed_order_or_types_rejected

end ACGN.Sixth.RawCallSourceAuthority
