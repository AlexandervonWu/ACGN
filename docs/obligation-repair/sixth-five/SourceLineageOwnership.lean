import Std

namespace ACGN.SixthFive.SourceLineage

/-- Allocation events in one positive signed-long epoch of the JVM atomic counter.
A gap is a constructor, reseed or concurrent allocation outside the observed roots.
An original is identified by the object visited, independently of its content. -/
structure Ticket where
  owner : Nat
  lineage : Nat
  deriving DecidableEq

def maxLineage : Nat := 2^63 - 1

def allocate (before : Nat) (events : List (Option Nat)) (slot : Nat) : Option Ticket := do
  let lineage := before + slot + 1
  if lineage > maxLineage then none else
    let owner ← (← events[slot]?)
    return ⟨owner, lineage⟩

theorem allocation_fields {before events slot ticket}
    (issued : allocate before events slot = some ticket) :
    ticket.lineage = before + slot + 1 ∧ ticket.lineage ≤ maxLineage ∧
    events[slot]? = some (some ticket.owner) := by
  simp only [allocate] at issued
  split at issued
  · contradiction
  · rename_i within
    cases e : events[slot]? with
    | none => simp [e] at issued
    | some val =>
      cases val with
      | none => simp [e] at issued
      | some owner =>
        simp [e] at issued
        subst ticket
        simp_all

theorem one_allocation_per_lineage {before events i j a b}
    (ai : allocate before events i = some a) (bj : allocate before events j = some b)
    (same : a.lineage = b.lineage) : i = j ∧ a = b := by
  have ha := (allocation_fields ai).1
  have hb := (allocation_fields bj).1
  have hij : i = j := by omega
  subst j
  exact ⟨rfl, Option.some.inj (ai.symm.trans bj)⟩

theorem exhausted_allocation_rejects {before events i}
    (exhausted : before + i + 1 > maxLineage) : allocate before events i = none := by
  simp [allocate, exhausted]

/-- Owner is a ghost field tracing a copy to its original. Neither Java replay
guard below reads it. Raw and transfer are structural content values. -/
structure Image where
  objectId : Nat
  owner : Nat
  lineage : Nat
  raw : String
  transfer : String
  deriving DecidableEq

/-- Birth and lineage-preserving transitions of the retained slice. A copy may
change its representation. Actual transferability is decided separately below. -/
inductive Built (before : Nat) (events : List (Option Nat)) : Image → Prop
  | birth (i : Nat) (t : Ticket) (raw transfer : String)
      (issued : allocate before events i = some t) :
      Built before events ⟨t.owner, t.owner, t.lineage, raw, transfer⟩
  | copy {source : Image} (prior : Built before events source) (id : Nat)
      (raw transfer : String) :
      Built before events ⟨id, source.owner, source.lineage, raw, transfer⟩

theorem built_has_allocation {before events n} (made : Built before events n) :
    ∃ i, allocate before events i = some ⟨n.owner, n.lineage⟩ := by
  induction made with
  | birth i t raw transfer issued => exact ⟨i, issued⟩
  | copy _ _ _ _ ih => exact ih

theorem descendants_same_lineage_same_original {before events a b}
    (madeA : Built before events a) (madeB : Built before events b)
    (same : a.lineage = b.lineage) : a.owner = b.owner := by
  obtain ⟨i, hi⟩ := built_has_allocation madeA
  obtain ⟨j, hj⟩ := built_has_allocation madeB
  exact congrArg Ticket.owner (one_allocation_per_lineage hi hj same).2

structure Path where
  phase : Nat
  children : List Nat
  deriving DecidableEq

inductive Tree where
  | node (image : Image) (children : List Tree)

def imageAt (tree : Tree) : List Nat → Option Image
  | [] => match tree with | .node n _ => some n
  | i :: rest => match tree with | .node _ children => do
    let child ← children[i]?
    imageAt child rest

def objectIds : Tree → List Nat
  | .node n children => n.objectId :: children.flatMap objectIds

abbrev Forest := List (Option Tree)

/-- The identity check has the same accepted inputs as the adapter's finite
tree index: one retained object may occupy only one phase/child position.
Cyclic heaps are outside this finite representation. -/
def frozenAt (forest : Forest) (path : Path) : Option Image := do
  if !(forest.flatMap (fun phase => phase.toList.flatMap objectIds)).Nodup then none else
    let tree ← (← forest[path.phase]?)
    imageAt tree path.children

structure Commitment where
  path : Path
  typedSource : String
  raw : String
  deriving DecidableEq

structure Certificate where
  typedSource : String
  commitment : Commitment
  deriving DecidableEq

structure Binding where
  certified : Certificate
  lineage : Nat
  repairRaw : String
  transfer : String
  deriving DecidableEq

/-- The constructor takes its typed key from the certificate. Authenticating the
type or source subject from parser bytes is outside this ownership result. -/
def bindOriginal (forest : Forest) (path : Path) (c : Certificate) : Option Binding := do
  let n ← frozenAt forest path
  if n.lineage > 0 ∧ c.commitment = ⟨path, c.typedSource, n.raw⟩ then
    return ⟨c, n.lineage, n.raw, n.transfer⟩
  else none

def transferTo (b : Binding) (n : Image) : Option Binding :=
  if n.lineage = b.lineage ∧ n.transfer = b.transfer then some { b with repairRaw := n.raw }
  else none

def checkMatches (b : Binding) (n : Image) : Prop :=
  n.lineage = b.lineage ∧ n.raw = b.repairRaw ∧ n.transfer = b.transfer

theorem transfer_fields {b n out} (ok : transferTo b n = some out) :
    out.certified = b.certified ∧ out.lineage = b.lineage ∧
    n.lineage = b.lineage ∧ checkMatches out n := by
  simp [transferTo] at ok
  obtain ⟨h, rfl⟩ := ok
  simp [checkMatches, h]

theorem authorized_copy_matches {b source}
    (ok : checkMatches b source) (otherId : Nat) (newRaw : String) :
    let copy := {source with objectId := otherId, raw := newRaw}
    transferTo b copy = some {b with repairRaw := newRaw} ∧
    checkMatches {b with repairRaw := newRaw} copy := by
  obtain ⟨lineage, _, content⟩ := ok
  simp [transferTo, checkMatches, lineage, content]

theorem transfer_change_rejected {b n} (change : n.transfer ≠ b.transfer) :
    transferTo b n = none := by simp [transferTo, change]

/-- The same issued binding can replay on multiple physical copies; every
accepted copy traces to one original. The premise on construction is inductive,
rather than assuming an injective certificate assignment or unique lineages. -/
theorem transferred_certificate_has_one_original {before events b a d ba bd}
    (madeA : Built before events a) (madeD : Built before events d)
    (atA : transferTo b a = some ba) (atD : transferTo b d = some bd) :
    a.owner = d.owner := by
  have ha := (transfer_fields atA).2.2.1
  have hd := (transfer_fields atD).2.2.1
  exact descendants_same_lineage_same_original madeA madeD (ha.trans hd.symm)

theorem rechecking_two_images_identifies_one_original {before events b a d}
    (madeA : Built before events a) (madeD : Built before events d)
    (ha : checkMatches b a) (hd : checkMatches b d) : a.owner = d.owner :=
  descendants_same_lineage_same_original madeA madeD (ha.1.trans hd.1.symm)

theorem indexed_certificate_keeps_owner {before events forest path cert source repair b out}
    (found : frozenAt forest path = some source)
    (madeS : Built before events source) (madeR : Built before events repair)
    (issued : bindOriginal forest path cert = some b) (accepted : transferTo b repair = some out) :
    source.owner = repair.owner ∧ out.certified = cert := by
  simp [bindOriginal, found] at issued
  obtain ⟨_, rfl⟩ := issued
  have h := transfer_fields accepted
  exact ⟨descendants_same_lineage_same_original madeS madeR h.2.2.1.symm, h.1⟩

theorem binding_seals_indexed_path {forest path cert b}
    (issued : bindOriginal forest path cert = some b) :
    cert.commitment.path = path ∧ b.certified = cert := by
  cases located : frozenAt forest path with
  | none => simp [bindOriginal, located] at issued
  | some n =>
    simp [bindOriginal, located] at issued
    obtain ⟨⟨_, commitEq⟩, rfl⟩ := issued
    exact ⟨congrArg Commitment.path commitEq, rfl⟩

/-- Path substitution, including sibling or phase permutations, cannot issue
the same structural certificate at a second position in the frozen forest. -/
theorem one_certificate_selects_one_path {forest p q cert bp bq}
    (first : bindOriginal forest p cert = some bp)
    (second : bindOriginal forest q cert = some bq) : p = q ∧ bp = bq := by
  have hp := (binding_seals_indexed_path first).1
  have hq := (binding_seals_indexed_path second).1
  have he : p = q := hp.symm.trans hq
  rw [← he] at second
  exact ⟨he, Option.some.inj (first.symm.trans second)⟩

#print axioms binding_seals_indexed_path
#print axioms one_certificate_selects_one_path
#print axioms allocation_fields
#print axioms one_allocation_per_lineage
#print axioms exhausted_allocation_rejects
#print axioms built_has_allocation
#print axioms descendants_same_lineage_same_original
#print axioms transfer_fields
#print axioms authorized_copy_matches
#print axioms transfer_change_rejected
#print axioms transferred_certificate_has_one_original
#print axioms rechecking_two_images_identifies_one_original
#print axioms indexed_certificate_keeps_owner

end ACGN.SixthFive.SourceLineage
