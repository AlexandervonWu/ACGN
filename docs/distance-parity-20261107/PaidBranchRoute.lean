import PaidImportedBinding

/- A paid arity change retains a selected branch, not every branch having a
   similar label. Object-to-record authority is a separate Java obligation. -/
namespace PaidBranchRoute
open PaidImportedBinding TemporalPhaseLocalBinding

inductive Head where
  | unary : UnaryTemporalKind → Head
  | binary : BinaryTemporalKind → Head
  deriving DecidableEq

abbrev Body := List (String × String × List Nat)

structure Branch where
  occurrence : Nat
  owner : BinderOrigin
  type : String
  phase : Nat
  dependencies : List Nat
  body : Body
  nodes : List Nat
  readOccurrence : Nat
  deriving DecidableEq

structure State where
  binding : Binding
  outer : UnaryTemporalKind
  inner : Head
  referenceOccurrence : Nat
  referenceArity : Nat
  branches : List Branch
  deriving DecidableEq

inductive Action where
  | inner : Head → Head → Action
  | outer : UnaryTemporalKind → UnaryTemporalKind → Action
  | declaration : Binding → Binding → Action
  | reference : Nat → Nat → Nat → Nat → Action
  | retain : Nat → Branch → Branch → Action
  | erase : Nat → Branch → Action
  | insert : Nat → Branch → Action
  deriving DecidableEq

def apply (s : State) : Action → Option State
  | .inner a b => if s.inner = a then some { s with inner := b } else none
  | .outer a b => if s.outer = a then some { s with outer := b } else none
  | .declaration a b => if s.binding = a then some { s with binding := b } else none
  | .reference a b ar br =>
      if s.referenceOccurrence = a ∧ s.referenceArity = ar then
        some { s with referenceOccurrence := b, referenceArity := br } else none
  | .retain i a b => if s.branches[i]? = some a then
      some { s with branches := s.branches.set i b } else none
  | .erase i a => if s.branches[i]? = some a then
      some { s with branches := s.branches.eraseIdx i } else none
  | .insert i a => if i ≤ s.branches.length then
      some { s with branches := s.branches.take i ++ [a] ++ s.branches.drop i } else none

def run (s : State) : List Action → Option State
  | [] => some s
  | a :: rest => (apply s a).bind (fun t => run t rest)

def charge : Action → Nat
  | .inner a b => if a = b then 0 else 1
  | .outer a b => if a = b then 0 else 1
  | .declaration a b => if a.quantifier = b.quantifier then 0 else 1
  | .reference _ _ a b => if a = b then 0 else 1
  | .retain _ _ _ => 0
  | .erase _ b | .insert _ b => b.nodes.length

def cost (p : List Action) : Nat := (p.map charge).sum

structure Plan where
  source : State
  target : State
  keptSource : Branch
  keptTarget : Branch
  discarded : Branch
  right : Bool
  expanding : Bool
  deriving DecidableEq

def binaryBranches (right : Bool) (kept discarded : Branch) : List Branch :=
  if right then [discarded, kept] else [kept, discarded]

def program (p : Plan) : List Action :=
  [.inner p.source.inner p.target.inner,
   .outer p.source.outer p.target.outer,
   .declaration p.source.binding p.target.binding,
   .reference p.source.referenceOccurrence p.target.referenceOccurrence
     p.source.referenceArity p.target.referenceArity,
   .retain (if p.expanding then 0 else if p.right then 1 else 0) p.keptSource p.keptTarget,
   if p.expanding then .insert (if p.right then 0 else 1) p.discarded
   else .erase (if p.right then 0 else 1) p.discarded]

def branchTyped (b : Binding) (x : Branch) : Bool := decide
  (x.owner = b.origin ∧ x.type = b.carrier ∧ x.dependencies = b.dependencies ∧
   x.phase > b.origin.ownerPhase ∧ x.nodes.Nodup ∧ x.occurrence ∈ x.nodes ∧
   x.readOccurrence ∈ x.nodes ∧ x.body.length = x.nodes.length)

def shapeCheck (p : Plan) : Bool :=
  let binary := if p.expanding then p.target else p.source
  let unary := if p.expanding then p.source else p.target
  let kept := if p.expanding then p.keptTarget else p.keptSource
  let single := if p.expanding then p.keptSource else p.keptTarget
  (match binary.inner, unary.inner with | .binary _, .unary _ => true | _, _ => false) &&
  decide (binary.referenceArity = 2 ∧ unary.referenceArity = 1 ∧
    binary.branches = binaryBranches p.right kept p.discarded ∧ unary.branches = [single] ∧
    p.keptSource.body = p.keptTarget.body ∧
    (kept.nodes ++ p.discarded.nodes).Nodup) &&
  sameFrame p.source.binding p.target.binding &&
  decide (p.source.binding.quantifier ≠ p.target.binding.quantifier) &&
  branchTyped p.source.binding p.keptSource && branchTyped p.target.binding p.keptTarget &&
  branchTyped binary.binding p.discarded

/- Supplied source/target/plan are compared with the selected object-issued
   authority. The executable replay, not a scalar cost, licenses the read. -/
def execute (authority supplied : Plan) (actions : List Action) : Option (State × Nat) := do
  if supplied != authority || !shapeCheck authority || actions != program authority then none
  else
    let output ← run authority.source actions
    if output = authority.target then some (output, cost actions) else none

theorem accepted_selected_program (a p : Plan) (ops : List Action) (out : State) (n : Nat)
    (h : execute a p ops = some (out, n)) :
    p = a ∧ shapeCheck a = true ∧ ops = program a ∧
      run a.source ops = some out ∧ out = a.target ∧ n = cost ops := by
  unfold execute at h
  split at h
  · simp at h
  · rename_i good
    have checks : p = a ∧ shapeCheck a = true ∧ ops = program a := by simpa [and_assoc] using good
    cases hr : run a.source ops with
    | none => simp [hr] at h
    | some result =>
      simp only [hr] at h
      dsimp only [Bind.bind, Option.bind] at h
      split at h
      · rename_i equal
        cases h
        exact ⟨checks.1, checks.2.1, checks.2.2, rfl, equal, rfl⟩
      · simp at h

theorem foreign_plan_rejected (a p : Plan) (ops : List Action) (bad : p ≠ a) :
    execute a p ops = none := by simp [execute, bad]

theorem substituted_payment_rejected (a : Plan) (ops : List Action)
    (bad : ops ≠ program a) : execute a a ops = none := by simp [execute, bad]

theorem accepted_typed_read (a p : Plan) (ops : List Action) (out : State) (n : Nat)
    (h : execute a p ops = some (out, n))
    (Value : String → Type) (value : Value a.source.binding.carrier)
    (before : Nat → Value a.source.binding.carrier)
    (after : Nat → Value a.target.binding.carrier) :
    ∃ typed : a.source.binding.carrier = a.target.binding.carrier,
      out = a.target ∧ n = cost ops ∧
      a.keptSource.body = a.keptTarget.body ∧
      a.keptSource.owner = a.source.binding.origin ∧
      a.keptTarget.owner = a.target.binding.origin ∧
      shadowBinder after a.target.binding.origin.coordinate (typed ▸ value)
          a.keptTarget.owner.coordinate =
        typed ▸ shadowBinder before a.source.binding.origin.coordinate value
          a.keptSource.owner.coordinate := by
  have checked := accepted_selected_program a p ops out n h
  have fields := checked.2.1
  simp only [shapeCheck, Bool.and_eq_true_iff, decide_eq_true_eq] at fields
  have frame := fields.1.1.1.1.2
  have typeEq := (of_decide_eq_true frame).1
  have src := of_decide_eq_true fields.1.1.2
  have dst := of_decide_eq_true fields.1.2
  refine ⟨typeEq, checked.2.2.2.2.1, checked.2.2.2.2.2,
    fields.1.1.1.1.1.2.2.2.2.2.1, src.1, dst.1, ?_⟩
  simp [src.1, dst.1, shadowBinder]

structure RouteStep where
  tree : Nat
  role : Int
  branch : Int
  owners : Nat
  deriving DecidableEq

/- Exact old Java loop after temporalOwnerRoute succeeds and lengths match. -/
def oldRouteGate (selected : List (Nat × Nat)) (a b : List RouteStep) : Bool :=
  decide (a.length = b.length) && (a.zip b).all (fun (x,y) =>
    decide ((x.tree,y.tree) ∈ selected ∧ x.role = y.role ∧
      x.branch = y.branch ∧ x.owners = y.owners))

def unaryMeaning (k : UnaryTemporalKind) (p : Nat → Prop) (t : Nat) : Prop :=
  match k with
  | .always => futureAlways p t
  | .eventually => futureEventually p t
  | .historically => pastHistorically p t
  | .once => pastOnce p t
  | .after => p (t+1)
  | .before => ∃ previous, t = previous+1 ∧ p previous

def binaryMeaning (k : BinaryTemporalKind) (p q : Nat → Prop) (t : Nat) : Prop :=
  match k with
  | .until => futureUntil p q t
  | .releases => futureRelease p q t
  | .since => pastSince p q t
  | .triggered => pastTriggered p q t

def bodyMeaning {V : Type} (meaning : Body → V → Nat → Prop)
    (s : State) (v : V) (t : Nat) : Prop :=
  match s.inner, s.branches with
  | .unary k, [x] => unaryMeaning k (meaning x.body v) t
  | .binary k, [x,y] => binaryMeaning k (meaning x.body v) (meaning y.body v) t
  | _, _ => False

def meaning {V : Type} (carrier : Nat → V → Prop)
    (body : Body → V → Nat → Prop) (s : State) (t : Nat) : Prop :=
  unaryMeaning s.outer (fun now =>
    if s.binding.quantifier = 0 then ∀ v, carrier now v → bodyMeaning body s v now
    else ∃ v, carrier now v ∧ bodyMeaning body s v now) t

theorem executed_path_has_target_meaning {V : Type} (carrier : Nat → V → Prop)
    (body : Body → V → Nat → Prop) (a p : Plan) (ops : List Action)
    (out : State) (n t : Nat) (h : execute a p ops = some (out,n)) :
    meaning carrier body out t = meaning carrier body a.target t ∧
      run a.source ops = some out ∧ n = cost ops := by
  have good := accepted_selected_program a p ops out n h
  exact ⟨congrArg (fun s => meaning carrier body s t) good.2.2.2.2.1,
    good.2.2.2.1, good.2.2.2.2.2⟩

end PaidBranchRoute
