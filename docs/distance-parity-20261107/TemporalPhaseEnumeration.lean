import Std

/- Repair phases are typed source records. An ordinal locates a record; it is
   not its temporal role or binder owner. Reachability may remove a record but
   must not silently permute the retained source enumeration used by the metric.
   This contract does not prove the Java implementation or raw-source semantics. -/
namespace TemporalPhaseEnumeration

structure Phase (Owner Role Body Declaration : Type) where
  owner : Owner
  role : Role
  body : Body
  declarations : List Declaration

inductive Retained {P : Type} : List P → List P → Prop where
  | nil : Retained [] []
  | keep (p : P) : Retained source target → Retained (p :: source) (p :: target)
  | drop (p : P) : Retained source target → Retained (p :: source) target

def retain (keep : P → Bool) : List P → List P
  | [] => []
  | p :: ps => if keep p then p :: retain keep ps else retain keep ps

theorem reachability_preserves_enumeration (keep : P → Bool) (source : List P) :
    Retained source (retain keep source) := by
  induction source with
  | nil => exact Retained.nil
  | cons p ps ih =>
    simp only [retain]
    split
    · exact Retained.keep p ih
    · exact Retained.drop p ih

structure CoordinateMap (n k : Nat) where
  original : Fin k → Fin n
  injective : ∀ a b, original a = original b → a = b
  ordered : ∀ a b, a.val < b.val → (original a).val < (original b).val

def project (source : Fin n → P) (map : CoordinateMap n k) : Fin k → P :=
  fun i => source (map.original i)

theorem exact_typed_record (source : Fin n → Phase O R B D)
    (map : CoordinateMap n k) (i : Fin k) :
    project source map i = source (map.original i) := rfl

theorem imported_owner_preserved (source : Fin n → Phase O R B D)
    (map : CoordinateMap n k) (sourceOwner : Fin n) (destinationOwner : Fin k)
    (link : map.original destinationOwner = sourceOwner) :
    project source map destinationOwner = source sourceOwner := by
  simp [project, link]

theorem foreign_phase_rejected (map : CoordinateMap n k) (a b : Fin k)
    (different : a ≠ b) : map.original a ≠ map.original b := by
  intro equal
  exact different (map.injective a b equal)

/- The selected aligned rows and the cost function remain unchanged. This does
   NOT assert that independently permuting endpoints preserves a positional
   metric. It explicitly exposes which original typed rows each charge uses. -/
theorem selected_row_costs (left : Fin n → P) (right : Fin m → Q)
    (a : CoordinateMap n k) (b : CoordinateMap m j)
    (rows : List (Fin k × Fin j)) (cost : P → Q → Nat) :
    rows.map (fun r => cost (project left a r.1) (project right b r.2)) =
    rows.map (fun r => cost (left (a.original r.1)) (right (b.original r.2))) := rfl

#print axioms reachability_preserves_enumeration
#print axioms exact_typed_record
#print axioms imported_owner_preserved
#print axioms foreign_phase_rejected
#print axioms selected_row_costs
end TemporalPhaseEnumeration
