import PaidBranchRoute
import GuardedDomainProjection
import DistanceDerivedTrace

/- Context composition for a selected paid repair. There is no admission gate
   or Java evaluator here. The actual selected route, object authority and
   typed operation premises must still be checked by their existing contracts.
   In particular a successful store replay alone cannot license a free read. -/
namespace PaidContextComposition
open TemporalPhaseLocalBinding GuardedDomainProjection DistanceDerivedTrace

inductive Context (Atom : Type) where
  | atom : Atom -> Context Atom
  | neg : Context Atom -> Context Atom
  | conj : Context Atom -> Context Atom -> Context Atom
  | disj : Context Atom -> Context Atom -> Context Atom
  | unary : UnaryTemporalKind -> Context Atom -> Context Atom
  | binary : BinaryTemporalKind -> Context Atom -> Context Atom -> Context Atom
  deriving DecidableEq

def Context.eval {Atom V : Type} (atom : Atom -> List V -> Nat -> V -> Prop)
    (dependencies : List V) (value : V) : Context Atom -> Nat -> Prop
  | .atom a, time => atom a dependencies time value
  | .neg a, time => Not (a.eval atom dependencies value time)
  | .conj a b, time => a.eval atom dependencies value time /\ b.eval atom dependencies value time
  | .disj a b, time => a.eval atom dependencies value time \/ b.eval atom dependencies value time
  | .unary kind a, time => PaidBranchRoute.unaryMeaning kind (a.eval atom dependencies value) time
  | .binary kind a b, time => PaidBranchRoute.binaryMeaning kind
      (a.eval atom dependencies value) (b.eval atom dependencies value) time

/- Both environments are constructed with the selected value. No agreement
   of unrelated source/target environments is assumed. This is independent
   of surrounding guards, branch count, temporal role and expression edits. -/
theorem selected_value_in_every_context {Atom V : Type}
    (atom : Atom -> List V -> Nat -> V -> Prop) (body : Context Atom)
    (dependencies : List V) (value : V) (source target : Nat -> V)
    (sourceSlot targetSlot time : Nat) :
    body.eval atom dependencies (shadowBinder source sourceSlot value sourceSlot) time =
      body.eval atom dependencies (shadowBinder target targetSlot value targetSlot) time := by
  simp [shadowBinder]

/- The guard is evaluated at the declaration's time. It can denote a source
   subset, relational join, difference or emptiness test; authentic extraction
   of that expression is not replaced by the carrier's printed name. -/
theorem owner_guard_lowering {V : Type} (q : Quantifier)
    (carrier guard body : V -> Prop) :
    quantify q (fun v => carrier v /\ guard v) body <->
      quantify q carrier (fun v => match q with
        | .all => guard v -> body v
        | .some => guard v /\ body v) := by
  cases q <;> simp [quantify, and_imp, and_assoc]

theorem ordered_dependencies_in_every_context {Atom V : Type}
    (env : Environment V) (owners : List Dependency)
    (length : owners.length = env.owners.length)
    (atom : Atom -> List V -> Nat -> V -> Prop) (body : Context Atom)
    (value : V) (time : Nat) :
    (env.relabel owners length).owners = owners /\
      (env.relabel owners length).values = env.values /\
      body.eval atom (env.relabel owners length).values value time =
        body.eval atom env.values value time := by
  exact ⟨rfl, rfl, rfl⟩

/- A paid body edit is not an equivalence between the old and new predicate.
   Contexts on either side may differ. The selected lexical read is the same
   value in each, while the actual ordered edit program determines the body. -/
theorem executed_local_context {A P Atom V : Type} [DecidableEq A] [DecidableEq P]
    (source target : Store A P) (pre edits post : List (Operation A P))
    (afterPrefix afterLocal : Store A P)
    (prefixRan : run source pre = some afterPrefix)
    (localRan : run afterPrefix edits = some afterLocal)
    (suffixRan : run afterLocal post = some target)
    (decode : Store A P -> Context Atom)
    (atom : Atom -> List V -> Nat -> V -> Prop) (deps : List V)
    (value : V) (environment : Nat -> V) (slot time : Nat) :
    (run source (pre ++ edits ++ post)).map (fun output =>
      (cost (pre ++ edits ++ post),
        (decode output).eval atom deps (shadowBinder environment slot value slot) time)) =
      some (cost pre + cost edits + cost post,
        (decode target).eval atom deps value time) := by
  have replay : run source (pre ++ edits ++ post) = some target := by
    rw [run_append, run_append, prefixRan]
    change (run afterPrefix edits).bind (fun next => run next post) = some target
    rw [localRan]
    exact suffixRan
  rw [replay]
  simp [cost_append, Nat.add_assoc, shadowBinder]

/- Addition of an unrelated paid context changes the total by that context's
   charge, not the locally checked declaration/read payment. -/
theorem contextual_cost {A P : Type} (pre edits post : List (Operation A P)) :
    cost (pre ++ edits ++ post) = cost pre + cost edits + cost post := by
  simp [cost_append, Nat.add_assoc]

/- An arbitrary ordered sibling prefix can be removed without substituting
   the retained occurrence. The erased prefix and its actual payments remain
   separate obligations; this list law is not itself an admission check. -/
theorem selected_sibling_after_prefix {A : Type} (pre post : List A) (kept : A) :
    (pre ++ kept :: post).drop pre.length = kept :: post := by simp

theorem selected_sibling_before_suffix {A : Type} (pre post : List A) (kept : A) :
    (pre ++ kept :: post)[pre.length]? = some kept := by simp

def primeMembership {V : Type} (relation : Nat -> V -> Prop) (time : Nat) (value : V) : Prop :=
  relation (time + 1) value

theorem prime_keeps_selected_value {V : Type} (relation : Nat -> V -> Prop)
    (environment : Nat -> V) (slot time : Nat) (value : V) :
    primeMembership relation time (shadowBinder environment slot value slot) =
      relation (time + 1) value := by simp [primeMembership, shadowBinder]

theorem prime_is_not_unpaid_identity :
    Not (primeMembership (fun t (_ : Unit) => t = 1) 0 () <-> (0 : Nat) = 1) := by
  simp [primeMembership]

end PaidContextComposition
