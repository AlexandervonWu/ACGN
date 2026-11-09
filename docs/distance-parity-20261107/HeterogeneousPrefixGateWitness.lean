import HeterogeneousPrefixPresentation

namespace HeterogeneousPrefixGateWitness
open HeterogeneousPrefixPresentation

structure Slot where
  coordinate : Nat
  carrier : String
  deriving DecidableEq

def slots : List Slot := [⟨0,"AlloyCarrier(Class)"⟩,⟨1,"AlloyCarrier(Person)"⟩]

/- TypedEmbedding.isTypePreserving on a non-null, source-key-complete map.
   The source-key and totality checks are computed, not assumed. The Java
   guard itself remains unchanged; presentation is not a value-slot swap. -/
def oldTypeGate (source codomain : List Slot) (mapping : List (Slot × Option Slot)) : Bool :=
  (source.all fun s => (mapping.filter fun e => e.1 == s).length == 1) &&
  (mapping.all fun e => source.contains e.1) &&
  (mapping.all fun e => match e.2 with
    | none => false
    | some target => codomain.contains target && e.1.carrier == target.carrier)

def exchangeValues : List (Slot × Option Slot) :=
  [(⟨0,"AlloyCarrier(Class)"⟩,some ⟨1,"AlloyCarrier(Person)"⟩),
   (⟨1,"AlloyCarrier(Person)"⟩,some ⟨0,"AlloyCarrier(Class)"⟩)]

def retainValues : List (Slot × Option Slot) := slots.map fun s => (s,some s)

theorem old_java_type_gate_rejects : oldTypeGate slots slots exchangeValues = false := by decide
theorem presentation_value_map_remains_typed : oldTypeGate slots slots retainValues = true := by decide
theorem missing_target_rejected :
    oldTypeGate slots slots [(⟨0,"AlloyCarrier(Class)"⟩,none),(⟨1,"AlloyCarrier(Person)"⟩,some ⟨1,"AlloyCarrier(Person)"⟩)] = false := by decide
theorem wrong_codomain_rejected : oldTypeGate slots [] retainValues = false := by decide
theorem repeated_source_rejected : oldTypeGate slots slots (retainValues ++ retainValues) = false := by decide

-- A presentation carries original occurrences without changing their typed
-- values. Each adjacent independent exchange is sound in either direction.
theorem actual_typed_target_and_old_rejection {Class Person Group : Type}
    (Groups : Class → Person → Group → Prop)
    (Teaches : Person → Class → Prop) (Tutors : Person → Person → Prop) :
    oldTypeGate slots slots exchangeValues = false ∧
    oldTypeGate slots slots retainValues = true ∧
    ((∀ c p, (∃ g, Groups c p g) → ∀ t, Teaches t c → Tutors t p) ↔
     (∀ p c, (∃ g, Groups c p g) → ∀ t, Teaches t c → Tutors t p)) :=
  ⟨old_java_type_gate_rejects,presentation_value_map_remains_typed,z4_target_presentation Groups Teaches Tutors⟩

#print axioms old_java_type_gate_rejects
#print axioms presentation_value_map_remains_typed
#print axioms missing_target_rejected
#print axioms wrong_codomain_rejected
#print axioms repeated_source_rejected
#print axioms actual_typed_target_and_old_rejection
end HeterogeneousPrefixGateWitness
