import Std

namespace ACGN.BoundedFive.ZeroArgumentCall

/- P1-10 only. This is the zero-arity specialization of visitCall and the
   acceptance algorithm in validateCompletedCallVisit, not a JVM refinement.
   At expected = 2, filling two distinct in-range byPosition slots has exactly
   the two storage orders below. Positions are signed, as in MASGEdge. Owner
   (node identity coordinate), parser occurrence, and time of visit are distinct.
   Java checks identity before exporting its stable owner coordinate; the Lean
   model does not prove that coordinate assignment or the parser implementation.
   Targets are declaration-key projections, not heap nodes. END is an explicit
   MASG target, not an argument, and is deliberately absent from lowered CALLs.
   Only Std/kernel proofs are used. No semantic rewrite family is introduced. -/

inductive Kind where
  | formula | expression
  deriving DecidableEq, Repr

inductive Authority where
  | declaration | typecheckedImport
  deriving DecidableEq, Repr

structure Key where
  source : String
  callee : String
  kind : Kind
  arity : Nat
  authority : Authority
  deriving DecidableEq, Repr

structure Capture where
  occurrence : Nat
  owner : Nat
  visit : Nat
  key : Key
  deriving DecidableEq, Repr

inductive Target where
  | callee (key : Key)
  | endMarker
  | other
  deriving DecidableEq, Repr

structure Edge where
  owner : Nat
  visit : Nat
  position : Int
  target : Target
  deriving DecidableEq, Repr

def zeroCall (occurrence owner visit : Nat) (source callee : String)
    (kind : Kind) (authority : Authority) : Capture :=
  ⟨occurrence, owner, visit, ⟨source, callee, kind, 0, authority⟩⟩

def calleeEdge (c : Capture) : Edge := ⟨c.owner, c.visit, 1, .callee c.key⟩
def endEdge (c : Capture) : Edge := ⟨c.owner, c.visit, 2, .endMarker⟩

def construct (c : Capture) : List Edge := [calleeEdge c, endEdge c]

def edgeAt (c : Capture) (position : Int) (target : Target) (e : Edge) : Bool :=
  e.owner == c.owner && e.visit == c.visit &&
    e.position == position && e.target == target

/- Null/missing and arbitrary malformed lists are inputs, not excluded by a
   ValidVisit premise. The two-slot unrolling accepts reversed storage order,
   as Java does; visitCall itself emits callee then END. Target equality compares
   spelling, qualified callee, kind, declared arity, and authority independently. -/
def validate (c : Capture) (edges : Option (List Edge)) : Bool :=
  c.key.arity == 0 && match edges with
    | some [a, b] =>
      (edgeAt c 1 (.callee c.key) a && edgeAt c 2 .endMarker b) ||
      (edgeAt c 2 .endMarker a && edgeAt c 1 (.callee c.key) b)
    | _ => false

theorem edgeAt_iff (c : Capture) (position : Int) (target : Target) (e : Edge) :
    edgeAt c position target e = true <->
      e = ⟨c.owner, c.visit, position, target⟩ := by
  cases e
  simp [edgeAt, Bool.and_eq_true, beq_iff_eq, Edge.mk.injEq, and_assoc]

theorem validate_iff (c : Capture) (edges : Option (List Edge)) :
    validate c edges = true <-> c.key.arity = 0 ∧
      (edges = some (construct c) ∨ edges = some [endEdge c, calleeEdge c]) := by
  cases edges with
  | none => simp [validate]
  | some edges =>
    cases edges with
    | nil => simp [validate, construct]
    | cons a rest =>
      cases rest with
      | nil => simp [validate, construct]
      | cons b rest =>
        cases rest with
        | nil =>
          simp [validate, Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq,
            edgeAt_iff, construct, calleeEdge, endEdge]
        | cons d rest => simp [validate, construct]

theorem construction_accepts (occurrence owner visit : Nat) (source callee : String)
    (kind : Kind) (authority : Authority) :
    let c := zeroCall occurrence owner visit source callee kind authority
    validate c (some (construct c)) = true := by
  dsimp
  rw [validate_iff]
  exact ⟨rfl, Or.inl rfl⟩

theorem construction_fields (occurrence owner visit : Nat) (source callee : String)
    (kind : Kind) (authority : Authority) :
    let c := zeroCall occurrence owner visit source callee kind authority
    c.occurrence = occurrence ∧ c.owner = owner ∧ c.visit = visit ∧
      c.key = ⟨source, callee, kind, 0, authority⟩ ∧
      construct c = [⟨owner, visit, 1, .callee c.key⟩,
                     ⟨owner, visit, 2, .endMarker⟩] := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem malformed_rejects (c : Capture) (edges : Option (List Edge))
    (bad : ¬ (c.key.arity = 0 ∧
      (edges = some (construct c) ∨ edges = some [endEdge c, calleeEdge c]))) :
    validate c edges = false := by
  cases h : validate c edges
  · rfl
  · exact False.elim (bad ((validate_iff c edges).mp h))

theorem missing_rejects (c : Capture) : validate c none = false := by
  simp [validate]

theorem wrong_count_rejects (c : Capture) (edges : List Edge) (bad : edges.length ≠ 2) :
    validate c (some edges) = false := by
  apply malformed_rejects
  rintro ⟨_, h | h⟩ <;> cases h <;> exact bad rfl

theorem accepted_has_two_positions (c : Capture) (edges : List Edge)
    (accepted : validate c (some edges) = true) :
    edges.length = 2 ∧
      (edges.map Edge.position = [1, 2] ∨ edges.map Edge.position = [2, 1]) ∧
      edges.map Edge.owner = [c.owner, c.owner] ∧
      edges.map Edge.visit = [c.visit, c.visit] := by
  obtain ⟨_, h | h⟩ := (validate_iff c (some edges)).mp accepted
  · cases h
    exact ⟨rfl, Or.inl rfl, rfl, rfl⟩
  · cases h
    exact ⟨rfl, Or.inr rfl, rfl, rfl⟩

theorem accepted_exact_targets (c : Capture) (edges : List Edge)
    (accepted : validate c (some edges) = true) :
    c.key.arity = 0 ∧
      (edges.filter (fun e => e.position == 1)).map Edge.target = [.callee c.key] ∧
      (edges.filter (fun e => e.position == 2)).map Edge.target = [.endMarker] ∧
      (edges.filter (fun e => 1 < e.position && e.position < 2)) = [] := by
  obtain ⟨zero, h | h⟩ := (validate_iff c (some edges)).mp accepted
  all_goals cases h; simp [construct, calleeEdge, endEdge, zero]

structure BoundaryCall where
  occurrence : Nat
  key : Key
  arguments : Nat
  endChildren : Nat
  deriving DecidableEq, Repr

def lower (c : Capture) (edges : Option (List Edge)) : Option BoundaryCall :=
  if validate c edges then some ⟨c.occurrence, c.key, 0, 0⟩ else none

theorem construction_lowers_without_END (occurrence owner visit : Nat) (source callee : String)
    (kind : Kind) (authority : Authority) :
    let c := zeroCall occurrence owner visit source callee kind authority
    lower c (some (construct c)) = some ⟨occurrence, c.key, 0, 0⟩ := by
  dsimp only
  unfold lower
  rw [construction_accepts]
  rfl

/- Integration API: generate an Observation from each Java TSV row and prove
   `replay row = true` by decide. Do not substitute expected fixture values.
   Encode e1 from its independently read target key and e1_is_end; e2_is_end
   selects endMarker/other. Check edge_count before constructing the edge list.
   Key enum encodings: call/formula -> formula, call/expression -> expression;
   DECLARATION -> declaration, TYPECHECKED_IMPORT -> typecheckedImport.
   parser_path, graph, cert_path, cert_operator identify/provide Java evidence;
   their string interpretation, reflection, parsing, and serialization are
   trusted, not semantic theorems here. No path is invented to join stages. -/
structure Observation where
  capture : Capture
  edges : List Edge
  edgeCount : Nat
  parserSource : String
  parserKind : Kind
  parserArguments : Nat
  calleeMatch : Bool
  ir : BoundaryCall
  irMaxArity : Nat
  certified : BoundaryCall
  certifiedPorts : Nat
  deriving DecidableEq, Repr

def replay (o : Observation) : Bool :=
  validate o.capture (some o.edges) && o.edgeCount == o.edges.length &&
    o.parserSource == o.capture.key.source && o.parserKind == o.capture.key.kind &&
    o.parserArguments == 0 && o.calleeMatch &&
    lower o.capture (some o.edges) == some o.ir && o.irMaxArity == 0 &&
    o.certified == o.ir && o.certifiedPorts == 0

theorem replay_validates_visit (o : Observation) (passed : replay o = true) :
    validate o.capture (some o.edges) = true := by
  simp only [replay, Bool.and_eq_true] at passed
  exact passed.1.1.1.1.1.1.1.1.1

theorem replay_retains_occurrence_key_and_zero_arguments (o : Observation)
    (passed : replay o = true) :
    o.ir = ⟨o.capture.occurrence, o.capture.key, 0, 0⟩ ∧
      o.certified = o.ir ∧ o.certifiedPorts = 0 := by
  have valid := replay_validates_visit o passed
  simp only [replay, Bool.and_eq_true, beq_iff_eq] at passed
  have lowered : lower o.capture (some o.edges) = some o.ir := passed.1.1.1.2
  simp [lower, valid] at lowered
  exact ⟨lowered.symm, passed.1.2, passed.2⟩

end ACGN.BoundedFive.ZeroArgumentCall

#print axioms ACGN.BoundedFive.ZeroArgumentCall.edgeAt_iff
#print axioms ACGN.BoundedFive.ZeroArgumentCall.validate_iff
#print axioms ACGN.BoundedFive.ZeroArgumentCall.construction_accepts
#print axioms ACGN.BoundedFive.ZeroArgumentCall.construction_fields
#print axioms ACGN.BoundedFive.ZeroArgumentCall.malformed_rejects
#print axioms ACGN.BoundedFive.ZeroArgumentCall.missing_rejects
#print axioms ACGN.BoundedFive.ZeroArgumentCall.wrong_count_rejects
#print axioms ACGN.BoundedFive.ZeroArgumentCall.accepted_has_two_positions
#print axioms ACGN.BoundedFive.ZeroArgumentCall.accepted_exact_targets
#print axioms ACGN.BoundedFive.ZeroArgumentCall.construction_lowers_without_END
#print axioms ACGN.BoundedFive.ZeroArgumentCall.replay_validates_visit
#print axioms ACGN.BoundedFive.ZeroArgumentCall.replay_retains_occurrence_key_and_zero_arguments
