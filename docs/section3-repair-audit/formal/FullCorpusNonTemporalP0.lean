/-
  Bounded proof obligations for the non-temporal full-corpus P0 repair.
  The Java refinement and parser-provenance checks remain separate obligations.
-/

import Std

namespace ACGN.Section3.FullCorpusNonTemporalP0

inductive IntegerCallable where
  | max0 | max1 | min0 | min1
  deriving DecidableEq, Repr

def explicitArity : IntegerCallable -> Nat
  | .max0 | .min0 => 0
  | .max1 | .min1 => 1

theorem integer_overloads_retain_exact_arity :
    explicitArity .max0 = 0 /\ explicitArity .max1 = 1 /\
      explicitArity .min0 = 0 /\ explicitArity .min1 = 1 := by
  decide

inductive Carrier where
  | primitive (identity : String)
  | relation (arity : Nat)
  deriving DecidableEq, Repr

def relationArity : Carrier -> Option Nat
  | .primitive _ => some 1
  | .relation arity => if arity = 0 then none else some arity

def commonRelationArity (left right : Carrier) : Option Nat :=
  match relationArity left, relationArity right with
  | some leftArity, some rightArity =>
      if leftArity = rightArity then some leftArity else none
  | _, _ => none

theorem primitive_binding_is_a_unary_relation (identity : String) :
    relationArity (.primitive identity) = some 1 := by
  rfl

theorem primitive_and_exact_unary_have_a_common_arity (identity : String) :
    commonRelationArity (.primitive identity) (.relation 1) = some 1 := by
  simp [commonRelationArity, relationArity]

def Rel (α β : Type) := α -> β -> Prop

def converse {α β : Type} (relation : Rel α β) : Rel β α :=
  fun right left => relation left right

theorem converse_involution {α β : Type} (relation : Rel α β) :
    converse (converse relation) = relation := by
  rfl

def join {α β γ : Type} (left : Rel α β) (right : Rel β γ) : Rel α γ :=
  fun source target => Exists fun middle => left source middle /\ right middle target

def domainRestrict {α β : Type} (set : α -> Prop) (relation : Rel α β) : Rel α β :=
  fun left right => set left /\ relation left right

def rangeRestrict {α β : Type} (relation : Rel α β) (set : β -> Prop) : Rel α β :=
  fun left right => relation left right /\ set right

theorem converse_join {α β γ : Type} (left : Rel α β) (right : Rel β γ) :
    converse (join left right) = join (converse right) (converse left) := by
  funext target source
  apply propext
  constructor <;> intro witness
  · rcases witness with ⟨middle, leftEdge, rightEdge⟩
    exact ⟨middle, rightEdge, leftEdge⟩
  · rcases witness with ⟨middle, rightEdge, leftEdge⟩
    exact ⟨middle, leftEdge, rightEdge⟩

theorem converse_range_is_domain {α β : Type}
    (relation : Rel α β) (set : β -> Prop) :
    converse (rangeRestrict relation set) =
      domainRestrict set (converse relation) := by
  funext right left
  apply propext
  constructor <;> intro proof
  · exact ⟨proof.2, proof.1⟩
  · exact ⟨proof.2, proof.1⟩

theorem join_range_moves_to_domain {α β γ : Type}
    (left : Rel α β) (middleSet : β -> Prop) (right : Rel β γ) :
    join (rangeRestrict left middleSet) right =
      join left (domainRestrict middleSet right) := by
  funext source target
  apply propext
  constructor <;> intro witness
  · rcases witness with ⟨middle, ⟨leftEdge, member⟩, rightEdge⟩
    exact ⟨middle, leftEdge, member, rightEdge⟩
  · rcases witness with ⟨middle, leftEdge, member, rightEdge⟩
    exact ⟨middle, ⟨leftEdge, member⟩, rightEdge⟩

def disjoint {α : Type} (left right : α -> Prop) : Prop :=
  ∀ value, Not (left value /\ right value)

theorem disjoint_is_commutative {α : Type} (left right : α -> Prop) :
    disjoint left right <-> disjoint right left := by
  constructor <;> intro proof value overlap
  · exact proof value ⟨overlap.2, overlap.1⟩
  · exact proof value ⟨overlap.2, overlap.1⟩

def transferProof {Payload : Type} [DecidableEq Payload]
    (certified repaired : Payload) : Option Payload :=
  if certified = repaired then some certified else none

theorem identical_lineage_payload_reuses_one_proof
    {Payload : Type} [DecidableEq Payload] (payload : Payload) :
    transferProof payload payload = some payload := by
  simp [transferProof]

theorem divergent_lineage_payload_is_rejected
    {Payload : Type} [DecidableEq Payload] (certified repaired : Payload)
    (different : certified ≠ repaired) :
    transferProof certified repaired = none := by
  simp [transferProof, different]

end ACGN.Section3.FullCorpusNonTemporalP0
