import TemporalReferenceReconstruction
import SelectedTemporalPayment
import TypedTemporalSplice
import PaidTemporalRouting

/- The shared REF decision consumes authenticated endpoint coordinates and an
   already selected temporal execution. Local display aliases are not keys.
   The tree executor below checks concrete retained splice programs; it does
   not assert source-formula equivalence or Java/source-wire certification. -/
namespace TemporalReferenceCostCongruence

inductive Tree where
  | node (head : String) (origin role : Int) (children : List Tree)
  deriving Repr

def Tree.head : Tree → String | .node h _ _ _ => h
def Tree.origin : Tree → Int | .node _ o _ _ => o
def Tree.role : Tree → Int | .node _ _ r _ => r
def Tree.children : Tree → List Tree | .node _ _ _ cs => cs
def Tree.withRole (r : Int) : Tree → Tree | .node h o _ cs => .node h o r cs
def Tree.payload : Tree → String × Int × List Tree | .node h o _ cs => (h, o, cs)

mutual
  def treeEq (a b : Tree) : Decidable (a = b) :=
    match a, b with
    | .node h o r cs, .node h' o' r' cs' =>
      if hh : h = h' then
        if ho : o = o' then
          if hr : r = r' then
            match forestEq cs cs' with
            | isTrue hc => isTrue (by subst h'; subst o'; subst r'; subst cs'; rfl)
            | isFalse hc => isFalse (fun same => hc (congrArg Tree.children same))
          else isFalse (fun same => hr (congrArg Tree.role same))
        else isFalse (fun same => ho (congrArg Tree.origin same))
      else isFalse (fun same => hh (congrArg Tree.head same))
  termination_by sizeOf a
  decreasing_by all_goals simp_wf; omega

  def forestEq (a b : List Tree) : Decidable (a = b) :=
    match a, b with
    | [], [] => isTrue rfl
    | [], _ :: _ => isFalse (by intro same; cases same)
    | _ :: _, [] => isFalse (by intro same; cases same)
    | x :: xs, y :: ys =>
      match treeEq x y with
      | isFalse different => isFalse (fun same => different (List.cons.inj same).1)
      | isTrue sameHead =>
        match forestEq xs ys with
        | isFalse different => isFalse (fun same => different (List.cons.inj same).2)
        | isTrue sameTail => isTrue (by subst y; subst ys; rfl)
  termination_by sizeOf a
  decreasing_by all_goals simp_wf; omega
end

instance : DecidableEq Tree := treeEq

def branchCount (head : String) : Int :=
  if head = "UNTIL" ∨ head = "RELEASES" ∨ head = "SINCE" ∨ head = "TRIGGERED"
  then 2 else 1

def ordered (roles : List Int) : Bool :=
  (roles.zip (roles.drop 1)).all (fun (a, b) => a ≤ b)

def route (head : String) (children : List Tree) (roles : List Int) : Option (List Tree) :=
  if children.length = roles.length ∧
      roles.all (fun r => 0 ≤ r ∧ r < branchCount head) ∧ ordered roles then
    some ((children.zip roles).map (fun (child, role) => child.withRole role))
  else none

inductive Command where
  | delete (expected : String)
  | update (expected target : String) (roles : List Int)
  | insert (head : String) (origin incoming : Int) (index count : Nat) (roles : List Int)
  deriving DecidableEq, Repr

def applyLocal (command : Command) (node : Tree) : Option (List Tree) := do
  match node, command with
  | .node h _ r cs, .delete expected =>
    if h = expected then some (cs.map (Tree.withRole r)) else none
  | .node h o r cs, .update expected target roles =>
    if h ≠ expected ∨ h = target then none else do
      let routed ← route target cs roles
      pure [.node target o r routed]
  | .node h o r cs, .insert label origin incoming index count roles =>
    if index + count > cs.length ∨
        ¬ (if h = "" then incoming = -1 else 0 ≤ incoming ∧ incoming < branchCount h)
        then none else do
      let chosen := (cs.drop index).take count
      if ¬ chosen.all (fun c => c.role = incoming) then none else do
        if ¬ ((cs[index - 1]?).all (fun c => index = 0 ∨ c.role ≤ incoming)) ∨
            ¬ ((cs[index + count]?).all (fun c => incoming ≤ c.role)) then none else do
          let routed ← route label chosen roles
          pure [.node h o r (cs.take index ++ [.node label origin incoming routed] ++ cs.drop (index + count))]

def splice : List Nat → Command → List Tree → Option (List Tree)
  | [], _, _ => none
  | i :: rest, command, forest => do
    let node ← forest[i]?
    let replacement ← match rest with
      | [] => applyLocal command node
      | _ :: _ => do
        let children ← splice rest command node.children
        pure [.node node.head node.origin node.role children]
    pure (forest.take i ++ replacement ++ forest.drop (i + 1))

abbrev Edit := List Nat × Command
def execute : List Edit → List Tree → Option (List Tree × Nat)
  | [], source => some (source, 0)
  | (path, command) :: rest, source => do
    let next ← splice path command source
    let (target, paid) ← execute rest next
    pure (target, paid + 1)

def lookup : List Nat → List Tree → Option Tree
  | [], _ => none
  | i :: rest, forest => do
    let node ← forest[i]?
    match rest with
    | [] => some node
    | _ :: _ => lookup rest node.children

structure Reference where
  path : List Nat
  ownerPath : List Nat
  childIndex : Nat
  ownerPhase : Nat
  originalSlot : Nat
  branches : List Nat
  operator : String
  role : Int
  origin : Int
  sourceOwner : String
  sourceBranches : List String
  rawAlias : String
  deriving DecidableEq, Repr

def validReference (forest : List Tree) (r : Reference) : Bool :=
  match lookup r.path forest, lookup r.ownerPath forest with
  | some node, some owner =>
    r.path == r.ownerPath ++ [r.childIndex] && node.head == r.operator &&
    node.role == r.role && node.origin == r.origin &&
    (0 ≤ r.role && r.role < branchCount owner.head) &&
    (r.branches.length : Int) == branchCount r.operator &&
    r.sourceBranches.length == r.branches.length
  | _, _ => false

def sameSlot (a b : Reference) : Bool :=
  a.ownerPhase == b.ownerPhase && a.originalSlot == b.originalSlot &&
  a.branches.length == b.branches.length

def exact (a b : Reference) : Bool := a.branches == b.branches && a.operator == b.operator
def oldCost (a b : Reference) : Nat := if a.rawAlias = b.rawAlias then 0 else 1

def reconstructed (program : List Edit) (source target : List Tree)
    (a b : Reference) : Bool :=
  validReference source a && validReference target b && sameSlot a b &&
  match execute program source with
  | some (actual, paid) => actual == target && 0 < paid
  | none => false

def cost (same paid : Bool) : Nat := if same || paid then 0 else 1

theorem zero_cost_retains_authority (same paid : Bool) (zero : cost same paid = 0) :
    same = true ∨ paid = true := by
  cases same <;> cases paid <;> simp_all [cost]

theorem no_unproved_discount : cost false false = 1 := rfl

theorem representation_congruence (fastExact fastPaid certifiedExact certifiedPaid : Bool)
    (same : fastExact = certifiedExact) (paid : fastPaid = certifiedPaid) :
    cost fastExact fastPaid = cost certifiedExact certifiedPaid := by
  rw [same, paid]

theorem reconstruction_executes_target (program : List Edit) (source target : List Tree)
    (a b : Reference) (accepted : reconstructed program source target a b = true) :
    ∃ paid, execute program source = some (target, paid) ∧ 0 < paid := by
  unfold reconstructed at accepted
  cases h : execute program source with
  | none => simp [h] at accepted
  | some value =>
    rcases value with ⟨actual, paid⟩
    simp only [h, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at accepted
    exact ⟨paid, by simp [accepted.2.1], accepted.2.2⟩

theorem execution_charge_is_selected_length (program : List Edit) (source target : List Tree)
    (paid : Nat) (done : execute program source = some (target, paid)) :
    paid = program.length := by
  induction program generalizing source paid with
  | nil => simp [execute] at done; exact done.2.symm
  | cons edit rest ih =>
    rcases edit with ⟨path, command⟩
    cases step : splice path command source with
    | none => simp [execute, step] at done
    | some next =>
      cases tail : execute rest next with
      | none => simp [execute, step, tail] at done
      | some value =>
        rcases value with ⟨actual, charge⟩
        simp [execute, step, tail] at done
        rcases done with ⟨rfl, rfl⟩
        simp [ih next charge tail]

theorem delete_preserves_payloads (role : Int) (children : List Tree) :
    ((children.map (Tree.withRole role)).map Tree.payload) = children.map Tree.payload := by
  simp only [List.map_map]
  congr 1
  funext child
  cases child
  rfl

theorem unchanged_head_cannot_reroute (head : String) (origin role : Int)
    (children : List Tree) (roles : List Int) :
    applyLocal (.update head head roles) (.node head origin role children) = none := by
  simp [applyLocal]

#print axioms zero_cost_retains_authority
#print axioms representation_congruence
#print axioms reconstruction_executes_target
#print axioms execution_charge_is_selected_length
#print axioms delete_preserves_payloads
#print axioms unchanged_head_cannot_reroute
end TemporalReferenceCostCongruence
