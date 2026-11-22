import GuardedDomainProjection
import DistanceDerivedTrace

/- The selected matrix edit may change a lowered domain guard. This is a paid
   repair of the body, not equivalence of the original predicates. Slots below
   are relative tree addresses, bound bijectively to the captured native slice. -/
namespace PaidGuardEdit
open GuardedDomainProjection PaidImportedBinding TemporalPhaseLocalBinding
open DistanceDerivedTrace

deriving instance DecidableEq for PaidDeclarationAlignment.Edit

inductive Slot where
  | root | body | guard | variable | signature | reference
  deriving DecidableEq, Repr

def slots : List Slot := [.root, .body, .guard, .variable, .signature, .reference]

inductive Head where
  | root | disj | notIn | variable | signature (name : String)
  | reference (path : List TemporalPhaseRole)
  deriving DecidableEq, Repr

structure Node where
  head : Head
  type : String
  owner : BinderOrigin
  phase : Nat
  children : List Slot
  occurrence : Nat
  deriving DecidableEq

structure Frame where
  binding : Binding
  ownerPath : List TemporalPhaseRole
  usePath : List TemporalPhaseRole
  guardName : String
  occurrences : List Nat
  deriving DecidableEq

def Frame.node (f : Frame) (head : Head) (children : List Slot) (index : Nat) : Node :=
  { head, type := match head with
      | .variable | .signature _ => f.binding.carrier
      | _ => "BOOL",
    owner := f.binding.origin, phase := f.binding.origin.ownerPhase,
    children, occurrence := f.occurrences[index]?.getD 0 }

def guarded (f : Frame) : Store Slot Node
  | .root => some (f.node .root [.body] 0)
  | .body => some (f.node .disj [.guard,.reference] 1)
  | .guard => some (f.node .notIn [.variable,.signature] 2)
  | .variable => some (f.node .variable [] 3)
  | .signature => some (f.node (.signature f.guardName) [] 4)
  | .reference => some (f.node (.reference f.usePath) [] 5)

def plain (f : Frame) : Store Slot Node
  | .root => some (f.node .root [.body] 0)
  | .body => some (f.node (.reference f.usePath) [] 1)
  | _ => none

def snapshot (s : Store Slot Node) : List (Option Node) := slots.map s

theorem snapshot_injective (a b : Store Slot Node) (h : snapshot a = snapshot b) : a = b := by
  have all : a .root = b .root ∧ a .body = b .body ∧ a .guard = b .guard ∧
      a .variable = b .variable ∧ a .signature = b .signature ∧ a .reference = b .reference := by
    simpa [snapshot, slots] using h
  funext s
  cases s
  · exact all.1
  · exact all.2.1
  · exact all.2.2.1
  · exact all.2.2.2.1
  · exact all.2.2.2.2.1
  · exact all.2.2.2.2.2

inductive Direction where | remove | insert
  deriving DecidableEq

def beforeStore : Direction → Frame → Store Slot Node
  | .remove => guarded | .insert => plain
def afterStore : Direction → Frame → Store Slot Node
  | .remove => plain | .insert => guarded

def program (d : Direction) (a b : Frame) : List (Operation Slot Node) :=
  slots.map fun slot => ⟨slot, beforeStore d a slot, afterStore d b slot,
    if slot = .root then 0 else 1⟩

def opKeys (ops : List (Operation Slot Node)) :=
  ops.map fun op => (op.address, op.before, op.after, op.charge)

theorem program_cost (d : Direction) (a b : Frame) : cost (program d a b) = 5 := by
  rfl

theorem program_replays (d : Direction) (a b : Frame) :
    run (beforeStore d a) (program d a b) = some (afterStore d b) := by
  cases d <;>
    simp only [program, slots, List.map_cons, List.map_nil, run, apply,
      beforeStore, afterStore, guarded, plain] <;>
    simp only [Option.bind_some, ite_true, ite_false, reduceCtorEq] <;>
    congr 1 <;> funext slot <;> cases slot <;> rfl

/- Recursive interpretation follows the replayed child pointers. The reference
   interpretation is supplied for its exact role/branch path and same value. -/
def eval {V : Type} (s : Store Slot Node) (w : World V) (deps : List V)
    (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) (value : V) :
    Nat → Slot → Prop
  | 0, _ => False
  | fuel+1, slot => match s slot with
    | none => False
    | some node => match node.head, node.children with
      | .root, [child] => eval s w deps reference time value fuel child
      | .disj, [left,right] => eval s w deps reference time value fuel left ∨
          eval s w deps reference time value fuel right
      | .notIn, [varSlot,sigSlot] => match s varSlot, s sigSlot with
        | some v, some g => match v.head, g.head with
          | .variable, .signature name => ¬ w name deps time value
          | _, _ => False
        | _, _ => False
      | .reference path, [] => reference path time value
      | _, _ => False

theorem guarded_meaning {V : Type} (f : Frame) (w : World V) (deps : List V)
    (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) (value : V) :
    eval (guarded f) w deps reference time value 3 .root ↔
      (w f.guardName deps time value → reference f.usePath time value) := by
  simpa [eval, guarded, Frame.node] using
    native_not_in_or_guard (w f.guardName deps time value) (reference f.usePath time value)

theorem plain_meaning {V : Type} (f : Frame) (w : World V) (deps : List V)
    (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) (value : V) :
    eval (plain f) w deps reference time value 3 .root ↔ reference f.usePath time value := by
  rfl

def sourceMeaning {V : Type} (d : Direction) (f : Frame) (w : World V) (deps : List V)
    (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) : Prop :=
  match d with
  | .remove => ∀ value, (w f.binding.domain deps time value ∧ w f.guardName deps time value) →
      reference f.usePath time value
  | .insert => ∃ value, w f.binding.domain deps time value ∧ reference f.usePath time value

def targetMeaning {V : Type} (d : Direction) (f : Frame) (w : World V) (deps : List V)
    (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) : Prop :=
  match d with | .remove => sourceMeaning .insert f w deps reference time
               | .insert => sourceMeaning .remove f w deps reference time

def nativeMeaning {V : Type} (q : Quantifier) (f : Frame) (s : Store Slot Node)
    (w : World V) (deps : List V)
    (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) : Prop :=
  quantify q (w f.binding.domain deps time)
    (fun value => eval s w deps reference time value 3 .root)

def sourceQuantifier : Direction → Quantifier | .remove => .all | .insert => .some
def targetQuantifier : Direction → Quantifier | .remove => .some | .insert => .all

theorem own_endpoint_lowering {V : Type} (d : Direction) (f : Frame) (w : World V)
    (deps : List V) (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) :
    sourceMeaning d f w deps reference time ↔
      nativeMeaning (sourceQuantifier d) f (beforeStore d f) w deps reference time := by
  cases d <;> simp [sourceMeaning, nativeMeaning, sourceQuantifier, beforeStore,
    quantify, guarded_meaning, plain_meaning, and_imp]

/- Dependency occurrences are not unique owners: repeats must survive. Each
   occurrence carries its selected owner index; order and multiplicity matter. -/
structure DependencyOccurrence where
  occurrence : Nat
  ownerIndex : Nat
  deriving DecidableEq

def occurrenceCheck (owners : List Dependency) (actual expected : List DependencyOccurrence) : Bool :=
  decide (actual = expected ∧ ∀ o ∈ actual, o.ownerIndex < owners.length)

theorem complete_occurrences (owners : List Dependency) (actual expected : List DependencyOccurrence)
    (h : occurrenceCheck owners actual expected = true) : actual = expected :=
  (of_decide_eq_true h).1

def readCheck (f : Frame) (read : PhaseImport) : Bool :=
  decide (read.origin = f.binding.origin ∧ read.targetPath = f.usePath ∧
    f.ownerPath.length = f.binding.origin.ownerPhase ∧
    f.usePath.take f.ownerPath.length = f.ownerPath ∧ f.ownerPath.length < f.usePath.length)

/- Actual/expected endpoint objects and selected payment are separate inputs.
   Java must obtain expected frames from authenticated source authority, not
   manufacture them from the submitted serialized projection. -/
def execute (d : Direction) (a expectedA b expectedB : Frame)
    (actualSource actualTarget : List (Option Node)) (ops : List (Operation Slot Node))
    (ownersA ownersB : List Dependency) (links : List (Dependency × Dependency))
    (occurrences expectedOccurrences : List DependencyOccurrence)
    (payment : List PaidDeclarationAlignment.Edit) (read : PhaseImport) :
    Option (Store Slot Node × PhaseImport × Nat) := do
  if a != expectedA || b != expectedB ||
      actualSource != snapshot (beforeStore d a) || actualTarget != snapshot (afterStore d b) ||
      opKeys ops != opKeys (program d a b) ||
      !dependenciesCheck ownersA ownersB links || !occurrenceCheck ownersA occurrences expectedOccurrences ||
      a.binding.dependencies != ownersA.map (fun x => x.origin.coordinate) ||
      b.binding.dependencies != ownersB.map (fun x => x.origin.coordinate) ||
      !sameFrame a.binding b.binding || a.ownerPath != b.ownerPath || a.usePath != b.usePath ||
      a.binding.quantifier != (sourceQuantifier d).code ||
      b.binding.quantifier != (targetQuantifier d).code || !readCheck a read ||
      payment != [.pair (atom a.binding) (atom b.binding)] then none
  else
    let (output, charged, pairs) ← PaidDeclarationAlignment.replay [atom a.binding] payment
    if output != [atom b.binding] || charged != 1 ||
        pairs != [(a.binding.origin.coordinate,b.binding.origin.coordinate)] then none
    else
      let next ← run (beforeStore d a) ops
      if snapshot next != actualTarget then none
      else some (next, ⟨b.binding.origin,b.usePath⟩, charged + cost ops)

theorem accepted_result_is_replayed_target (d : Direction) (a ea b eb : Frame)
    (s t : List (Option Node)) (ops : List (Operation Slot Node))
    (oa ob : List Dependency) (links : List (Dependency × Dependency))
    (os es : List DependencyOccurrence) (payment : List PaidDeclarationAlignment.Edit)
    (read resultRead : PhaseImport) (next : Store Slot Node) (charge : Nat)
    (h : execute d a ea b eb s t ops oa ob links os es payment read = some (next,resultRead,charge)) :
    next = afterStore d b ∧ resultRead = ⟨b.binding.origin,b.usePath⟩ ∧ charge = 1 + cost ops := by
  unfold execute at h
  split at h
  · contradiction
  · next valid =>
      have target : t = snapshot (afterStore d b) := by
        by_cases equal : t = snapshot (afterStore d b)
        · exact equal
        · exact False.elim (valid (by simp [equal]))
      cases p : PaidDeclarationAlignment.replay [atom a.binding] payment with
      | none => simp [p] at h
      | some output =>
        rcases output with ⟨out,paid,pairs⟩
        simp only [p] at h
        dsimp only [Bind.bind, Option.bind] at h
        split at h
        · contradiction
        · next paidChecks =>
            have paidOne : paid = 1 := by
              by_cases equal : paid = 1
              · exact equal
              · exact False.elim (paidChecks (by simp [equal]))
            cases r : run (beforeStore d a) ops with
            | none => simp [r] at h
            | some store =>
              simp only [r] at h
              split at h
              · contradiction
              · next matched =>
                  have eq : snapshot store = t := by simpa using matched
                  simp only [Option.some.injEq, Prod.mk.injEq] at h
                  rcases h with ⟨hn,hr,hc⟩
                  subst next
                  exact ⟨snapshot_injective _ _ (eq.trans target),hr.symm,by simpa [paidOne] using hc.symm⟩

theorem executed_body_is_target_source {V : Type} (d : Direction) (a ea b eb : Frame)
    (s t : List (Option Node)) (ops : List (Operation Slot Node))
    (oa ob : List Dependency) (links : List (Dependency × Dependency))
    (os es : List DependencyOccurrence) (payment : List PaidDeclarationAlignment.Edit)
    (read resultRead : PhaseImport) (next : Store Slot Node) (charge : Nat)
    (h : execute d a ea b eb s t ops oa ob links os es payment read = some (next,resultRead,charge))
    (w : World V) (deps : List V) (reference : List TemporalPhaseRole → Nat → V → Prop) (time : Nat) :
    nativeMeaning (targetQuantifier d) b next w deps reference time ↔
      targetMeaning d b w deps reference time := by
  rw [(accepted_result_is_replayed_target d a ea b eb s t ops oa ob links os es payment read
    resultRead next charge h).1]
  cases d <;> simp [nativeMeaning, targetMeaning, sourceMeaning, targetQuantifier,
    afterStore, quantify, plain_meaning, guarded_meaning, and_imp]

theorem future_read_keeps_selected_value {V : Type} (w : World V) (deps : List V)
    (name : String) (sourceEnv targetEnv : Nat → V) (sourceSlot targetSlot : Nat)
    (value : V) (ownerTime : Nat) :
    futureAlways (fun t => w name deps t
      (shadowBinder sourceEnv sourceSlot value sourceSlot)) ownerTime =
    futureAlways (fun t => w name deps t
      (shadowBinder targetEnv targetSlot value targetSlot)) ownerTime := by
  simp [shadowBinder]

structure RetainedRead where
  beforeOwner : BinderOrigin
  afterOwner : BinderOrigin
  beforeOccurrence : Nat
  afterOccurrence : Nat
  beforeType : String
  afterType : String
  path : List TemporalPhaseRole
  deriving DecidableEq

def retainedReadCheck (a b : Frame) (actual selected : RetainedRead) : Bool :=
  decide (actual = selected ∧ actual.beforeOwner = a.binding.origin ∧
    actual.afterOwner = b.binding.origin ∧ actual.beforeType = a.binding.carrier ∧
    actual.afterType = b.binding.carrier ∧ actual.path = a.usePath ∧ actual.path = b.usePath)

theorem foreign_same_metadata_read_rejected (a b : Frame) (actual selected : RetainedRead)
    (wrong : actual.beforeOccurrence ≠ selected.beforeOccurrence) :
    retainedReadCheck a b actual selected = false := by
  have different : actual ≠ selected := by intro h; exact wrong (congrArg (·.beforeOccurrence) h)
  simp [retainedReadCheck, different]

def executeLinked (d : Direction) (a ea b eb : Frame)
    (s t : List (Option Node)) (ops : List (Operation Slot Node))
    (oa ob : List Dependency) (links : List (Dependency × Dependency))
    (os es : List DependencyOccurrence) (payment : List PaidDeclarationAlignment.Edit)
    (actual selected : RetainedRead) : Option (Store Slot Node × Nat × Nat) := do
  if !retainedReadCheck a b actual selected then none
  else
    let (next, _, charged) ← execute d a ea b eb s t ops oa ob links os es payment
      ⟨actual.beforeOwner,actual.path⟩
    some (next, charged, 0)

theorem linked_execution_sound {V : Type} (d : Direction) (a ea b eb : Frame)
    (s t : List (Option Node)) (ops : List (Operation Slot Node))
    (oa ob : List Dependency) (links : List (Dependency × Dependency))
    (os es : List DependencyOccurrence) (payment : List PaidDeclarationAlignment.Edit)
    (actual selected : RetainedRead) (next : Store Slot Node) (charge extra : Nat)
    (h : executeLinked d a ea b eb s t ops oa ob links os es payment actual selected =
      some (next,charge,extra))
    (w : World V) (deps : List V) (reference : List TemporalPhaseRole → Nat → V → Prop)
    (time : Nat) (value : V) (envA envB : Nat → V) :
    extra = 0 ∧ charge = 1 + cost ops ∧ actual = selected ∧
    shadowBinder envA a.binding.origin.coordinate value actual.beforeOwner.coordinate =
      shadowBinder envB b.binding.origin.coordinate value actual.afterOwner.coordinate ∧
    (nativeMeaning (targetQuantifier d) b next w deps reference time ↔
      targetMeaning d b w deps reference time) := by
  unfold executeLinked at h
  split at h
  · contradiction
  · next good =>
      have check : retainedReadCheck a b actual selected = true := by simpa using good
      have details := of_decide_eq_true check
      cases e : execute d a ea b eb s t ops oa ob links os es payment ⟨actual.beforeOwner,actual.path⟩ with
      | none => simp [e] at h
      | some result =>
        rcases result with ⟨store,read,paid⟩
        simp only [e] at h
        dsimp only [Bind.bind, Option.bind] at h
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        rcases h with ⟨hs,hc,he⟩
        subst next
        subst charge
        refine ⟨he.symm, (accepted_result_is_replayed_target d a ea b eb s t ops oa ob links os es
          payment ⟨actual.beforeOwner,actual.path⟩ read store paid e).2.2, details.1, ?_, ?_⟩
        · simp [details.2.1,details.2.2.1,shadowBinder]
        · exact executed_body_is_target_source d a ea b eb s t ops oa ob links os es payment
            ⟨actual.beforeOwner,actual.path⟩ read store paid e w deps reference time

def dependencyValues {V : Type} (env : Environment V) (occurrences : List DependencyOccurrence) :=
  occurrences.map fun o => env.values[o.ownerIndex]?

theorem repeated_dependency_values_preserved {V : Type} (env : Environment V)
    (targetOwners : List Dependency) (length : targetOwners.length = env.owners.length)
    (actual expected : List DependencyOccurrence)
    (checked : occurrenceCheck env.owners actual expected = true) :
    dependencyValues env actual = dependencyValues (env.relabel targetOwners length) expected := by
  rw [complete_occurrences _ _ _ checked]
  rfl

end PaidGuardEdit
