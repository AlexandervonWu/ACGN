import Std

namespace ACGN.Seventh.RawArrowOccurrenceCensus

/- The input models resolved, static local Alloy declarations. The byte digest,
   parser attribution, producer's source-to-matrix wrapper correspondence and
   endpoint-to-certificate link are checked outside Lean. A ledger below is a
   list of decoded occurrence identities; its order is immaterial. -/
inductive Side where
  | left | right
  deriving DecidableEq, Repr

abbrev Path := List Side

structure Leaf where
  kind : String
  owner : String
  name : String
  columns : List String
  deriving DecidableEq, Repr

inductive Term where
  | leaf (value : Leaf)
  | arrow (left right : Term)

abbrev Port := Path × Leaf

/-- A syntax-directed partial lookup. A path extending past a leaf is invalid. -/
def resolve : Term → Path → Option Leaf
  | .leaf v, [] => some v
  | .arrow a _, .left :: path => resolve a path
  | .arrow _ b, .right :: path => resolve b path
  | _, _ => none

def under (side : Side) (row : Port) : Port := (side :: row.1, row.2)

/-- Binary source association determines the ordered frontier. -/
def frontier : Term → List Port
  | .leaf v => [([], v)]
  | .arrow a b => (frontier a).map (under .left) ++ (frontier b).map (under .right)

theorem frontier_resolves (t : Term) (path : Path) (v : Leaf) :
    (path, v) ∈ frontier t ↔ resolve t path = some v := by
  induction t generalizing path with
  | leaf x =>
    cases path <;> simp [frontier, resolve, eq_comm]
  | arrow a b ha hb =>
    cases path with
    | nil => simp [frontier, under, resolve, List.mem_map]
    | cons s path =>
      cases s <;> simp [frontier, under, resolve, List.mem_map, ha, hb]

/-- Typed owners at a given route are unique, including in trees with repeated leaves. -/
theorem owner_at_path_unique (t : Term) (p : Path) (u v : Leaf)
    (hu : (p, u) ∈ frontier t) (hv : (p, v) ∈ frontier t) : u = v := by
  have a := (frontier_resolves t p u).mp hu
  have b := (frontier_resolves t p v).mp hv
  exact Option.some.inj (a.symm.trans b)

def leafCount : Term → Nat
  | .leaf _ => 1
  | .arrow a b => leafCount a + leafCount b

theorem frontier_cardinality (t : Term) : (frontier t).length = leafCount t := by
  induction t <;> simp_all [frontier, leafCount]

/-- Independent, ordered expression-tree fold computing the result column word. -/
def resultColumns : Term → List String
  | .leaf v => v.columns
  | .arrow a b => resultColumns a ++ resultColumns b

theorem frontier_typed_order (t : Term) :
    (frontier t).flatMap (fun row => row.2.columns) = resultColumns t := by
  induction t with
  | leaf v => simp [frontier, resultColumns]
  | arrow a b ha hb =>
    simpa [frontier, resultColumns, List.flatMap_map, under] using
      congr (congrArg List.append ha) hb

structure Product where
  left : Term
  right : Term

def Product.term (product : Product) : Term := .arrow product.left product.right

inductive Body where
  | someProduct (p : Product)
  | included (left right : Product)

structure Subject where
  sourceDigest : String
  qualifiedPredicate : String
  deriving DecidableEq, Repr

structure Entry where
  subject : Subject
  operand : Nat
  ports : List Port
  deriving DecidableEq, Repr

def entry (s : Subject) (role : Nat) (p : Product) : Entry :=
  ⟨s, role, frontier p.term⟩

def census (s : Subject) : Body → List Entry
  | .someProduct p => [entry s 0 p]
  | .included l r => [entry s 0 l, entry s 1 r]

/-- Independent predicate-operand lookup describes which maximal tree a role owns. -/
def productAt : Body → Nat → Option Product
  | .someProduct p, 0 => some p
  | .included l _, 0 => some l
  | .included _ r, 1 => some r
  | _, _ => none

theorem census_addresses (s : Subject) (body : Body) (e : Entry) :
    e ∈ census s body ↔ ∃ p, productAt body e.operand = some p ∧ e = entry s e.operand p := by
  constructor
  · intro h
    cases body with
    | someProduct p =>
      simp only [census, List.mem_singleton] at h
      subst e
      exact ⟨p, rfl, rfl⟩
    | included l r =>
      simp [census] at h
      rcases h with rfl | rfl
      · exact ⟨l, rfl, rfl⟩
      · exact ⟨r, rfl, rfl⟩
  · rintro ⟨p, hp, he⟩
    cases e with
    | mk subject role ports =>
      cases body <;> cases role with
      | zero => simp_all [productAt, census, entry]
      | succ role => cases role <;> simp_all [productAt, census, entry]

structure Candidate where
  subject : Subject
  retained : List Entry
  ledger : List Entry

/-- Both submitted projections are compared with the independently walked source. -/
def Accepted (s : Subject) (b : Body) (c : Candidate) : Prop :=
  c.subject = s ∧ c.retained.Perm (census s b) ∧ c.ledger.Perm (census s b)

theorem accepted_ledger_resolves (s : Subject) (b : Body) (c : Candidate)
    (h : Accepted s b c) (e : Entry) (he : e ∈ c.ledger) (path : Path) (v : Leaf) :
    ∃ p, productAt b e.operand = some p ∧
          ((path, v) ∈ e.ports ↔ resolve p.term path = some v) := by
  have source := h.2.2.mem_iff.mp he
  obtain ⟨p, hp, heq⟩ := (census_addresses s b e).mp source
  refine ⟨p, hp, ?_⟩
  have ports := congrArg Entry.ports heq
  rw [ports]
  exact frontier_resolves p.term path v

theorem accepted_counts (s : Subject) (b : Body) (c : Candidate) (h : Accepted s b c)
    (e : Entry) : c.retained.count e = (census s b).count e ∧
      c.ledger.count e = (census s b).count e := ⟨h.2.1.count_eq e, h.2.2.count_eq e⟩

/-- Both independent operands survive multiset comparison when their types and
    complete frontiers coincide. The source declaration's role still differs. -/
theorem included_roles_distinct (s : Subject) (p q : Product) :
    entry s 0 p ≠ entry s 1 q := by
  intro h
  have roles := congrArg Entry.operand h
  simp [entry] at roles

theorem coordinated_omission_rejected (s : Subject) (b : Body) (c : Candidate)
    (pre post : List Entry) (e : Entry) (source : census s b = pre ++ e :: post)
    (omitted : c.ledger = pre ++ post) : ¬ Accepted s b c := by
  intro ok
  have lengths := ok.2.2.length_eq
  rw [omitted, source] at lengths
  simp only [List.length_append, List.length_cons] at lengths
  omega

theorem extra_occurrence_rejected (s : Subject) (b : Body) (c : Candidate) (e : Entry)
    (extra : c.ledger.Perm (e :: census s b)) : ¬ Accepted s b c := by
  intro ok
  have h₁ := extra.length_eq
  have h₂ := ok.2.2.length_eq
  simp only [List.length_cons] at h₁
  omega

theorem equal_size_substitution_rejected (s : Subject) (p q : Product)
    (c : Candidate) (twoLeft : c.ledger = [entry s 0 p, entry s 0 p]) :
    ¬ Accepted s (.included p q) c := by
  intro ok
  have right : entry s 1 q ∈ c.ledger := ok.2.2.mem_iff.mpr (by simp [census])
  rw [twoLeft] at right
  simp [Ne.symm (included_roles_distinct s p q)] at right

theorem foreign_subject_rejected (s : Subject) (b : Body) (c : Candidate)
    (foreign : c.subject ≠ s) : ¬ Accepted s b c := fun ok => foreign ok.1

#print axioms frontier_resolves
#print axioms owner_at_path_unique
#print axioms frontier_cardinality
#print axioms frontier_typed_order
#print axioms census_addresses
#print axioms accepted_ledger_resolves
#print axioms accepted_counts
#print axioms included_roles_distinct
#print axioms coordinated_omission_rejected
#print axioms extra_occurrence_rejected
#print axioms equal_size_substitution_rejected
#print axioms foreign_subject_rejected

end ACGN.Seventh.RawArrowOccurrenceCensus
