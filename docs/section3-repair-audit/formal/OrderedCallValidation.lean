import Std

namespace ACGN.NextFive.OrderedCallValidation

/- The input is a role-ordered exact-visit bucket, not an arbitrary Java heap.
   Callee keys and payloads are opaque equality tokens. Sorting, key issuance,
   parser lineage, Java integers and object identity remain separate boundaries. -/
inductive Target where
  | callee (key : Nat)
  | argument (payload : Nat)
  | terminator
  deriving DecidableEq, Repr

structure Edge where
  owner : Nat
  visit : Nat
  position : Nat
  target : Target
  deriving DecidableEq, Repr

structure Capture where
  owner : Nat
  visit : Nat
  callee : Nat
  arity : Nat
  deriving DecidableEq, Repr

/- Java correspondence is restricted to this arithmetic envelope: arity+2
   edges and arity+3 producer array length fit signed int. This neither models
   overflow nor promises array allocation, available memory, or parser limits. -/
def JavaIndexSafe (arity : Nat) : Prop := arity + 3 ≤ 2147483647

instance (arity : Nat) : Decidable (JavaIndexSafe arity) := inferInstanceAs (Decidable (_ ≤ _))

theorem java_index_bounds (arity : Nat) (safe : JavaIndexSafe arity) :
    arity + 2 ≤ 2147483647 ∧ arity + 3 ≤ 2147483647 := by
  unfold JavaIndexSafe at safe
  omega

def encodeArgs (owner visit : Nat) : Nat -> List Nat -> List Edge
  | position, [] => [⟨owner, visit, position, .terminator⟩]
  | position, payload :: rest =>
      ⟨owner, visit, position, .argument payload⟩ :: encodeArgs owner visit (position + 1) rest

def encode (capture : Capture) (payloads : List Nat) : List Edge :=
  ⟨capture.owner, capture.visit, 1, .callee capture.callee⟩ ::
    encodeArgs capture.owner capture.visit 2 payloads

/- Recursion is on declared arity, with an explicit terminal case. Payloads
   are read from edges, never supplied as a validity assumption or deduplicated. -/
def validateArgs (owner visit position : Nat) : Nat -> List Edge -> Option (List Nat)
  | 0, edges =>
      if edges = [⟨owner, visit, position, .terminator⟩] then some [] else none
  | n + 1, edge :: rest =>
      match edge.target with
      | .argument payload =>
          if edge = ⟨owner, visit, position, .argument payload⟩ then
            (validateArgs owner visit (position + 1) n rest).map (payload :: ·)
          else none
      | _ => none
  | _ + 1, [] => none

def validate (capture : Capture) : List Edge -> Option (List Nat)
  | [] => none
  | first :: rest =>
      if first = ⟨capture.owner, capture.visit, 1, .callee capture.callee⟩ then
        validateArgs capture.owner capture.visit 2 capture.arity rest
      else none

theorem validateArgs_iff (owner visit position n : Nat) (edges : List Edge) (xs : List Nat) :
    validateArgs owner visit position n edges = some xs ↔
      xs.length = n ∧ edges = encodeArgs owner visit position xs := by
  induction n generalizing position edges xs with
  | zero =>
      cases xs <;> simp [validateArgs, encodeArgs]
  | succ n ih =>
      cases edges with
      | nil => cases xs <;> simp [validateArgs, encodeArgs]
      | cons edge rest =>
          cases edge with
          | mk eo ev ep target =>
              cases target with
              | callee key => cases xs <;> simp [validateArgs, encodeArgs]
              | terminator => cases xs <;> simp [validateArgs, encodeArgs]
              | argument payload =>
                  by_cases h : (Edge.mk eo ev ep (.argument payload)) =
                      ⟨owner, visit, position, .argument payload⟩
                  · cases xs with
                    | nil => simp [validateArgs, h]
                    | cons x xs =>
                        simp only [Edge.mk.injEq, and_true] at h
                        obtain ⟨rfl, rfl, rfl⟩ := h
                        simp [validateArgs, encodeArgs, ih, and_assoc, and_left_comm, and_comm]
                  · cases xs <;> simp_all [validateArgs, encodeArgs, Edge.mk.injEq] <;> grind

theorem validate_iff (capture : Capture) (edges : List Edge) (xs : List Nat) :
    validate capture edges = some xs ↔ xs.length = capture.arity ∧ edges = encode capture xs := by
  cases edges with
  | nil => simp [validate, encode]
  | cons first rest =>
      by_cases h : first = ⟨capture.owner, capture.visit, 1, .callee capture.callee⟩
      · subst first
        simp [validate, encode, validateArgs_iff]
      · simp [validate, encode, h]

theorem accepted_complete_and_ordered (capture : Capture) (edges : List Edge) (xs : List Nat)
    (accepted : validate capture edges = some xs) :
    xs.length = capture.arity ∧ edges = encode capture xs :=
  (validate_iff capture edges xs).mp accepted

theorem source_order_complete (capture : Capture) (source : List Nat)
    (arity : source.length = capture.arity) :
    validate capture (encode capture source) = some source :=
  (validate_iff capture (encode capture source) source).mpr ⟨arity, rfl⟩

theorem malformed_rejects (capture : Capture) (edges : List Edge)
    (malformed : ¬ ∃ xs, xs.length = capture.arity ∧ edges = encode capture xs) :
    validate capture edges = none := by
  cases h : validate capture edges with
  | none => rfl
  | some xs => exact False.elim (malformed ⟨xs, (validate_iff capture edges xs).mp h⟩)

theorem encodeArgs_length (owner visit position : Nat) (xs : List Nat) :
    (encodeArgs owner visit position xs).length = xs.length + 1 := by
  induction xs generalizing position with
  | nil => rfl
  | cons x xs ih => simp [encodeArgs, ih, Nat.add_assoc]

theorem accepted_edge_count (capture : Capture) (edges : List Edge) (xs : List Nat)
    (accepted : validate capture edges = some xs) : edges.length = capture.arity + 2 := by
  obtain ⟨arity, rfl⟩ := accepted_complete_and_ordered capture edges xs accepted
  simp [encode, encodeArgs_length, arity, Nat.add_assoc]

theorem encodeArgs_index (owner visit position : Nat) (xs : List Nat) (i payload : Nat)
    (atIndex : xs[i]? = some payload) :
    (encodeArgs owner visit position xs)[i]? =
      some ⟨owner, visit, position + i, .argument payload⟩ := by
  induction xs generalizing position i with
  | nil => simp at atIndex
  | cons x xs ih =>
      cases i with
      | zero => simpa [encodeArgs] using atIndex
      | succ i =>
          simpa [encodeArgs, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using
            ih (position + 1) i (by simpa using atIndex)

theorem accepted_payload_at_source_index (capture : Capture) (edges : List Edge)
    (xs : List Nat) (i payload : Nat) (accepted : validate capture edges = some xs)
    (atIndex : xs[i]? = some payload) :
    edges[i + 1]? = some ⟨capture.owner, capture.visit, i + 2, .argument payload⟩ := by
  rw [(accepted_complete_and_ordered capture edges xs accepted).2]
  simpa [encode, Nat.add_comm] using encodeArgs_index capture.owner capture.visit 2 xs i payload atIndex

theorem duplicates_preserved (owner visit callee payload n : Nat) :
    validate ⟨owner, visit, callee, n⟩
      (encode ⟨owner, visit, callee, n⟩ (List.replicate n payload)) =
        some (List.replicate n payload) :=
  source_order_complete _ _ (List.length_replicate ..)

theorem reordered_payloads_not_accepted (capture : Capture) (source other : List Nat)
    (arity : source.length = capture.arity) (different : source ≠ other) :
    validate capture (encode capture source) ≠ some other := by
  rw [source_order_complete capture source arity]
  simpa using different

/- Executable CALL dispatch. Other buckets exist but are never enumerated.
   This models only CALL, not the non-CALL quantifier/nearest-visit search. -/
def selectCall (capture : Capture) (maxVisit : Nat) (buckets : Nat -> Option (List Edge)) :
    Option (List Nat) :=
  if capture.visit > maxVisit then none
  else (buckets capture.visit).bind (validate capture)

theorem no_unrelated_visit_fallback (capture : Capture) (maxVisit : Nat)
    (left right : Nat -> Option (List Edge)) (same : left capture.visit = right capture.visit) :
    selectCall capture maxVisit left = selectCall capture maxVisit right := by
  simp [selectCall, same]

theorem missing_exact_visit_rejects (capture : Capture) (maxVisit : Nat)
    (buckets : Nat -> Option (List Edge)) (missing : buckets capture.visit = none) :
    selectCall capture maxVisit buckets = none := by
  simp [selectCall, missing]

theorem malformed_exact_visit_rejects (capture : Capture) (maxVisit : Nat)
    (buckets : Nat -> Option (List Edge)) (edges : List Edge)
    (exactVisit : buckets capture.visit = some edges) (bad : validate capture edges = none) :
    selectCall capture maxVisit buckets = none := by
  simp [selectCall, exactVisit, bad]

theorem past_max_visit_rejects (capture : Capture) (maxVisit : Nat)
    (buckets : Nat -> Option (List Edge)) (past : capture.visit > maxVisit) :
    selectCall capture maxVisit buckets = none := by
  simp [selectCall, past]

/- Replay consumes independent parser, MASG edge, IR, and certified payload
   observations. The external encoder and equality-token mapping are trusted. -/
structure Observation where
  capture : Capture
  edges : List Edge
  parserPayloads : List Nat
  irPayloads : List Nat
  certifiedPayloads : List Nat
  deriving DecidableEq, Repr

def checkObservation (o : Observation) : Bool :=
  decide (JavaIndexSafe o.capture.arity ∧ validate o.capture o.edges = some o.parserPayloads ∧
    o.irPayloads = o.parserPayloads ∧ o.certifiedPayloads = o.parserPayloads)

theorem checked_observation_contract (o : Observation) (checked : checkObservation o = true) :
    JavaIndexSafe o.capture.arity ∧ o.parserPayloads.length = o.capture.arity ∧
      o.edges = encode o.capture o.parserPayloads ∧
      o.irPayloads = o.parserPayloads ∧ o.certifiedPayloads = o.parserPayloads := by
  have h : JavaIndexSafe o.capture.arity ∧ validate o.capture o.edges = some o.parserPayloads ∧
      o.irPayloads = o.parserPayloads ∧ o.certifiedPayloads = o.parserPayloads := by
    simpa [checkObservation] using checked
  exact ⟨h.1, ((validate_iff ..).mp h.2.1).1, ((validate_iff ..).mp h.2.1).2, h.2.2⟩

#print axioms validateArgs_iff
#print axioms validate_iff
#print axioms accepted_complete_and_ordered
#print axioms source_order_complete
#print axioms malformed_rejects
#print axioms encodeArgs_length
#print axioms accepted_edge_count
#print axioms encodeArgs_index
#print axioms accepted_payload_at_source_index
#print axioms duplicates_preserved
#print axioms reordered_payloads_not_accepted
#print axioms no_unrelated_visit_fallback
#print axioms missing_exact_visit_rejects
#print axioms malformed_exact_visit_rejects
#print axioms past_max_visit_rejects
#print axioms checked_observation_contract
#print axioms java_index_bounds

end ACGN.NextFive.OrderedCallValidation
