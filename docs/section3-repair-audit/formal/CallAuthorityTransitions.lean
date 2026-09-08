import Std

namespace ACGN.ThirdFive.CallAuthorityTransitions

/- Equality tokens denote independently recorded declaration identities, never
   source spelling. Heap/token issuance and Java refinement are explicit trust.
   Overloads are allowed; only a unique matching table entry is selected. -/
structure Signature where
  callee : Nat
  kind : Nat
  arity : Nat
  authority : Nat
  deriving DecidableEq, Repr

def declaredArity (parameterGroups : List Nat) : Nat := parameterGroups.sum

def candidates (table : List Signature) (callee kind observed : Nat) : List Signature :=
  table.filter fun s => decide (s.callee = callee ∧ s.kind = kind ∧ s.arity = observed)

def resolve (table : List Signature) (callee kind observed : Nat) : Option Signature :=
  match candidates table callee kind observed with
  | [s] => some s
  | _ => none

theorem resolve_iff (table : List Signature) (callee kind observed : Nat) (s : Signature) :
    resolve table callee kind observed = some s ↔ candidates table callee kind observed = [s] := by
  unfold resolve
  cases candidates table callee kind observed with
  | nil => simp
  | cons a rest => cases rest <;> simp

theorem selected_from_independent_authority (table : List Signature) (callee kind observed : Nat)
    (s : Signature) (accepted : resolve table callee kind observed = some s) :
    s ∈ table ∧ s.callee = callee ∧ s.kind = kind ∧ s.arity = observed := by
  have member : s ∈ candidates table callee kind observed := by
    rw [(resolve_iff ..).mp accepted]
    simp
  simpa [candidates] using member

theorem observed_arity_cannot_create_authority (table : List Signature) (callee kind observed : Nat)
    (missing : ∀ s ∈ table, ¬ (s.callee = callee ∧ s.kind = kind ∧ s.arity = observed)) :
    resolve table callee kind observed = none := by
  cases h : resolve table callee kind observed with
  | none => rfl
  | some s =>
      have hs := selected_from_independent_authority table callee kind observed s h
      exact False.elim (missing s hs.1 hs.2)

theorem selected_declaration_retains_parameter_arity (groups : List Nat) (s : Signature)
    (declared : s.arity = declaredArity groups) (table : List Signature) (callee kind observed : Nat)
    (accepted : resolve table callee kind observed = some s) : observed = groups.sum := by
  have h := (selected_from_independent_authority table callee kind observed s accepted).2.2.2
  simpa [declaredArity] using h.symm.trans declared

/- Natural arithmetic corresponds only inside the signed Java int envelope.
   arity+3 includes the producer array length; every executed counter increment
   must separately satisfy JavaStepSafe. No overflow or allocation claim. -/
def JavaAritySafe (n : Nat) : Prop := n + 3 ≤ 2147483647
def JavaStepSafe (before : Nat) : Prop := before + 1 ≤ 2147483647
instance (n : Nat) : Decidable (JavaAritySafe n) := inferInstanceAs (Decidable (_ ≤ _))
instance (n : Nat) : Decidable (JavaStepSafe n) := inferInstanceAs (Decidable (_ ≤ _))

theorem java_int_envelope (arity before : Nat) (ha : JavaAritySafe arity)
    (hb : JavaStepSafe before) : arity + 2 ≤ 2147483647 ∧ before + 1 ≤ 2147483647 := by
  unfold JavaAritySafe at ha
  exact ⟨by omega, hb⟩

abbrev Counters := Nat → Nat
def advance (s : Counters) (owner : Nat) : Counters :=
  fun other => if other = owner then s owner + 1 else s other

def allocations (s : Counters) : List Nat → List (Nat × Nat)
  | [] => []
  | owner :: rest => (owner, s owner + 1) :: allocations (advance s owner) rest

theorem advance_monotone (s : Counters) (owner other : Nat) : s other ≤ advance s owner other := by
  simp only [advance]
  split <;> simp_all

theorem allocated_strictly_after_counter (s : Counters) (schedule : List Nat) (owner visit : Nat)
    (member : (owner, visit) ∈ allocations s schedule) : s owner < visit := by
  induction schedule generalizing s with
  | nil => simp [allocations] at member
  | cons current rest ih =>
      simp only [allocations, List.mem_cons] at member
      rcases member with equal | later
      · cases equal
        omega
      · exact Nat.lt_of_le_of_lt (advance_monotone s current owner) (ih _ later)

theorem executable_allocations_never_reuse (s : Counters) (schedule : List Nat) :
    (allocations s schedule).Nodup := by
  induction schedule generalizing s with
  | nil => simp [allocations]
  | cons owner rest ih =>
      simp only [allocations, List.nodup_cons]
      refine ⟨?_, ih _⟩
      intro member
      have h := allocated_strictly_after_counter (advance s owner) rest owner (s owner + 1) member
      simp [advance] at h

/- nextTov updates even if downlinksFor subsequently rejects. The valid-bucket
   predicate is independent of the counter. No uniqueness premise is supplied. -/
def consume (before maxVisit : Nat) (valid : Nat → Bool) : Nat × Option Nat :=
  let visit := before + 1
  (visit, if visit ≤ maxVisit ∧ valid visit = true then some visit else none)

theorem consume_updates_on_rejection (before maxVisit : Nat) (valid : Nat → Bool) :
    (consume before maxVisit valid).1 = before + 1 := rfl

theorem fresh_occurrence_first_visit (valid : Nat → Bool) (good : valid 1 = true) :
    consume 0 1 valid = (1, some 1) := by simp [consume, good]

theorem consumed_fresh_occurrence_rejects (before : Nat) (positive : 1 ≤ before)
    (valid : Nat → Bool) : (consume before 1 valid).2 = none := by
  have h : ¬ before + 1 ≤ 1 := by omega
  simp [consume, h]

/- Source syntax and observed target representation have different constructors.
   Targets retain an ordered list of ports, not a bag/set or flat child stream.
   Barrier tags are arbitrary; no commutativity/idempotence law is assigned. -/
mutual
  inductive Source where
    | atom (value : Nat)
    | call (key : Signature) (arguments : SourceArgs)
    | barrier (tag : Nat) (arguments : SourceArgs)
    deriving DecidableEq, Repr
  inductive SourceArgs where
    | nil
    | cons (first : Source) (rest : SourceArgs)
    deriving DecidableEq, Repr
end

mutual
  inductive Representation where
    | scalar (value : Nat)
    | application (key : Signature) (ports : Ports)
    | boundary (tag : Nat) (ports : Ports)
    deriving DecidableEq, Repr
  inductive Ports where
    | nil
    | cons (first : Representation) (rest : Ports)
    deriving DecidableEq, Repr
end

mutual
  def lower : Source → Representation
    | .atom value => .scalar value
    | .call key args => .application key (lowerArgs args)
    | .barrier tag args => .boundary tag (lowerArgs args)
  def lowerArgs : SourceArgs → Ports
    | .nil => .nil
    | .cons first rest => .cons (lower first) (lowerArgs rest)
end

mutual
  def restore : Representation → Source
    | .scalar value => .atom value
    | .application key args => .call key (restoreArgs args)
    | .boundary tag args => .barrier tag (restoreArgs args)
  def restoreArgs : Ports → SourceArgs
    | .nil => .nil
    | .cons first rest => .cons (restore first) (restoreArgs rest)
end

mutual
  theorem restore_lower (source : Source) : restore (lower source) = source := by
    cases source <;> simp [lower, restore, restore_lower_args]
  theorem restore_lower_args (args : SourceArgs) : restoreArgs (lowerArgs args) = args := by
    cases args <;> simp [lowerArgs, restoreArgs, restore_lower, restore_lower_args]
end

def sourceArgs (args : List Source) : SourceArgs := args.foldr .cons .nil
def ports (args : List Representation) : Ports := args.foldr .cons .nil

theorem lower_ordered_list (args : List Source) :
    lowerArgs (sourceArgs args) = ports (args.map lower) := by
  induction args with
  | nil => rfl
  | cons first rest ih => simpa [sourceArgs, ports, lowerArgs] using congrArg (Ports.cons (lower first)) ih

theorem representation_injective (left right : Source) : lower left = lower right ↔ left = right := by
  constructor
  · intro h
    have := congrArg restore h
    simpa [restore_lower] using this
  · intro h
    cases h
    rfl

theorem ordered_ports_preserved (args : List Source) (index : Nat) :
    (args.map lower)[index]? = args[index]?.map lower := by simp

theorem repeated_ports_preserved (key : Signature) (value : Source) (count : Nat) :
    lower (.call key (sourceArgs (List.replicate count value))) =
      .application key (ports (List.replicate count (lower value))) := by
  simp [lower, lower_ordered_list]

theorem distinct_swaps_remain_distinct (key : Signature) (a b : Source) (different : a ≠ b) :
    lower (.call key (sourceArgs [a, b])) ≠ lower (.call key (sourceArgs [b, a])) := by
  intro h
  have := (representation_injective _ _).mp h
  simp_all [sourceArgs]

theorem repeated_argument_not_deduplicated (key : Signature) (a : Source) :
    lower (.call key (sourceArgs [a, a])) ≠ lower (.call key (sourceArgs [a])) := by
  intro h
  have := (representation_injective _ _).mp h
  simp_all [sourceArgs]

theorem nested_call_not_flattened (outer inner : Signature) (args : List Source) :
    lower (.call outer (sourceArgs [.call inner (sourceArgs args)])) =
      .application outer (ports [.application inner (ports (args.map lower))]) := by
  simp only [lower, lower_ordered_list, List.map_cons, List.map_nil]

theorem nested_same_call_cannot_collapse (key : Signature) (args : SourceArgs) :
    lower (.call key (.cons (.call key args) .nil)) ≠ lower (.call key args) := by
  intro h
  have equal := (representation_injective _ _).mp h
  have argsEqual : SourceArgs.cons (.call key args) .nil = args := by simpa using equal
  have sizes := congrArg sizeOf argsEqual
  simp at sizes
  omega

theorem barrier_not_erased (key : Signature) (tag : Nat) (args : List Source) :
    lower (.call key (sourceArgs [.barrier tag (sourceArgs args)])) ≠
      lower (.call key (sourceArgs [.call key (sourceArgs args)])) := by
  intro h
  have := (representation_injective _ _).mp h
  simp_all [sourceArgs]

def checkRepresentation (source : Source) (observed : Representation) : Bool :=
  decide (lower source = observed)

theorem checked_representation_retains_full_tree (source : Source) (observed : Representation)
    (checked : checkRepresentation source observed = true) : restore observed = source := by
  have h : lower source = observed := by simpa [checkRepresentation] using checked
  rw [← h, restore_lower]

#print axioms resolve_iff
#print axioms selected_from_independent_authority
#print axioms observed_arity_cannot_create_authority
#print axioms selected_declaration_retains_parameter_arity
#print axioms java_int_envelope
#print axioms advance_monotone
#print axioms allocated_strictly_after_counter
#print axioms executable_allocations_never_reuse
#print axioms consume_updates_on_rejection
#print axioms fresh_occurrence_first_visit
#print axioms consumed_fresh_occurrence_rejects
#print axioms restore_lower
#print axioms restore_lower_args
#print axioms lower_ordered_list
#print axioms representation_injective
#print axioms ordered_ports_preserved
#print axioms repeated_ports_preserved
#print axioms distinct_swaps_remain_distinct
#print axioms repeated_argument_not_deduplicated
#print axioms nested_call_not_flattened
#print axioms nested_same_call_cannot_collapse
#print axioms barrier_not_erased
#print axioms checked_representation_retains_full_tree

end ACGN.ThirdFive.CallAuthorityTransitions
