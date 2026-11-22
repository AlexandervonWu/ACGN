import AuthenticatedPhaseTransport
import Focus40Congruence

/- Port metadata may differ after source normalization. This contract changes
   only the encoding of one ordered operand, not the operand, its type, scope,
   source identity, or selected repair. Java must authenticate the source record
   before using the law. It is not a proof of parser or Java correspondence. -/
namespace UnaryRelationPort

inductive Port where
  | one | sequence | bag | set
  deriving DecidableEq, Repr

inductive OperandType where
  | missing | boolean | other (exact : String)
  deriving DecidableEq, Repr

structure Child where
  occurrence : Nat
  operator : String
  type : OperandType
  declaration : Bool
  deriving DecidableEq, Repr

structure Payload where
  occurrence : Nat
  ownerPhase : Nat
  sourcePath : String
  typedContext : String
  operator : String
  booleanMetatype : Bool
  booleanExactType : Bool
  formulaSourceType : Bool
  children : List Child
  deriving DecidableEq, Repr

structure View where
  payload : Payload
  port : Port
  deriving DecidableEq, Repr

def cardinality (operator : String) : Bool :=
  ["NO", "SOME", "ONE", "LONE"].contains operator

def eligible (p : Payload) : Bool :=
  cardinality p.operator && p.booleanMetatype && p.booleanExactType && p.formulaSourceType &&
  match p.children with
  | [child] => !child.declaration && match child.type with
    | .other _ => true
    | _ => false
  | _ => false

def ordered : Port → Bool
  | .one | .sequence => true
  | _ => false

def normalize (v : View) : View :=
  if eligible v.payload && ordered v.port then { v with port := .one } else v

def decode (port : Port) (children : List A) : Option (List A) :=
  match port with
  | .one => match children with | [child] => some [child] | _ => none
  | .sequence => some children
  | _ => none

theorem eligible_singleton (p : Payload) (h : eligible p = true) :
    ∃ child, p.children = [child] := by
  cases hs : p.children with
  | nil => simp [eligible, hs] at h
  | cons child rest =>
    cases rest with
    | nil => exact ⟨child, rfl⟩
    | cons next tail => simp [eligible, hs] at h

theorem typed_payload_preserved (v : View) : (normalize v).payload = v.payload := by
  unfold normalize; split <;> rfl

theorem operand_order_and_identity (v : View) :
    decode (normalize v).port (normalize v).payload.children =
      decode v.port v.payload.children := by
  unfold normalize
  split
  · rename_i h
    simp only [Bool.and_eq_true] at h
    obtain ⟨he, ho⟩ := h
    obtain ⟨child, hc⟩ := eligible_singleton v.payload he
    cases hp : v.port <;> simp_all [ordered, decode]
  · rfl

/- Cardinality semantics consume the same interpreted relation cardinality.
   The interpreter receives the complete typed child record, including its
   original occurrence. No assumption equating before/after results is used. -/
def predicate (operator : String) (size : Nat) : Bool :=
  if operator = "NO" then size == 0
  else if operator = "SOME" then size != 0
  else if operator = "ONE" then size == 1
  else if operator = "LONE" then size <= 1
  else false

def evaluate (relationCardinality : Child → Nat) (v : View) : Option Bool :=
  (decode v.port v.payload.children).bind fun xs =>
    match xs with
    | [child] => some (predicate v.payload.operator (relationCardinality child))
    | _ => none

theorem semantics_preserved (relationCardinality : Child → Nat) (v : View) :
    evaluate relationCardinality (normalize v) = evaluate relationCardinality v := by
  unfold evaluate
  rw [operand_order_and_identity, typed_payload_preserved]

theorem contextual_congruence (relationCardinality : Child → Nat)
    (context : Option Bool → Result) (v : View) :
    context (evaluate relationCardinality (normalize v)) =
      context (evaluate relationCardinality v) := by rw [semantics_preserved]

theorem ordered_encodings_agree (payload : Payload) (a b : Port)
    (he : eligible payload = true) (ha : ordered a = true) (hb : ordered b = true) :
    normalize ⟨payload, a⟩ = normalize ⟨payload, b⟩ := by simp [normalize, he, ha, hb]

theorem ineligible_unchanged (v : View) (h : eligible v.payload = false) :
    normalize v = v := by simp [normalize, h]

theorem unordered_unchanged (v : View) (h : ordered v.port = false) :
    normalize v = v := by simp [normalize, h]

/- Admission binds the original issued occurrence and every typed payload field.
   Matching opcode, value or local alias alone is never source authentication. -/
def authenticate (issued observed : Payload) : Bool := decide (issued = observed)

theorem authentic_record (issued observed : Payload)
    (h : authenticate issued observed = true) : issued = observed := of_decide_eq_true h

theorem foreign_record_rejected (issued observed : Payload) (h : issued ≠ observed) :
    authenticate issued observed = false := by simp [authenticate, h]

theorem stale_replay_stays_invalid [DecidableEq A] [DecidableEq P]
    (e : AuthenticatedPhaseTransport.Reindex A B) [DecidableEq B]
    (s : DistanceDerivedTrace.Store A P) (ops : List (DistanceDerivedTrace.Operation A P))
    (h : DistanceDerivedTrace.run s ops = none) :
    DistanceDerivedTrace.run (AuthenticatedPhaseTransport.moveStore e s)
      (ops.map (AuthenticatedPhaseTransport.moveOperation e)) = none :=
  AuthenticatedPhaseTransport.invalid_selected_path_stays_invalid e s ops h

#print axioms semantics_preserved
#print axioms contextual_congruence
#print axioms ordered_encodings_agree
#print axioms foreign_record_rejected
#print axioms stale_replay_stays_invalid
end UnaryRelationPort
