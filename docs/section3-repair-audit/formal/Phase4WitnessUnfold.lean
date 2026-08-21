import Std

/-
  Bounded semantic model for the schema-v8 WITNESS_UNFOLD rule.

  A witness invocation is defined to denote its retained definition acted on by
  the invocation embedding. Consequently unfolding introduces no equation and
  consumes no admitted theory premise. The final theorem is the exact direct-parent
  composition used by the bounded producer bridge. This file is not a Java
  refinement proof.
-/

namespace Section3.Phase4WitnessUnfold

abbrev Atom := Nat
abbrev Term := List Atom

structure Embedding where
  image : Atom -> Atom

structure Witness where
  definition : Term

def act (term : Term) (embedding : Embedding) : Term :=
  term.map embedding.image

def invoke (witness : Witness) (embedding : Embedding) : Term :=
  act witness.definition embedding

theorem witness_unfold_is_definitional
    (witness : Witness) (embedding : Embedding) :
    invoke witness embedding = act witness.definition embedding := by
  rfl

theorem direct_parent_rehome_owner_equation
    (child parent : Witness)
    (childEmbedding parentEmbedding : Embedding)
    (parentEdge :
      invoke child childEmbedding = invoke parent parentEmbedding) :
    act child.definition childEmbedding =
      act parent.definition parentEmbedding := by
  simpa only [witness_unfold_is_definitional] using parentEdge

def identity : Embedding := ⟨fun atom => atom⟩
def child : Witness := ⟨[0, 1]⟩
def parent : Witness := ⟨[0, 1]⟩
def unequalParent : Witness := ⟨[1, 0]⟩

example : invoke child identity = act child.definition identity := by
  native_decide

example : invoke child identity = invoke parent identity := by
  native_decide

example : invoke child identity != invoke unequalParent identity := by
  native_decide

end Section3.Phase4WitnessUnfold
