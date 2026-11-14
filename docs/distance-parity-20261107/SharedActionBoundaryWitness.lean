import SharedActionBoundary

/-!
Source-shaped instances for `SharedActionBoundary`, Part 2.

Each instance transcribes, for one retained focused direction, the selected
native declaration program and the supplemental declaration slice of both arms
in original coordinates: binder ordinal and repair tuple of every selected
source and target occurrence, and every operation's kind, charge and index
pair. The `SHARED_BOUNDARY_WITNESS` lines printed by this module are compared
with the receipts by the bound witness check; the theorems below are about the
transcribed data only.

* `event16`, direction 0 (`coursesNew/both/8esLa6SqLZYToDpBe_inv7.als`,
  `inv7` to `inv7c`). The two selected native programs are the same program.
  The Fast supplemental slice is a different replay of the same endpoints at
  the same charge. The supplemental comparison differs; the native declaration
  stages are equal. This is a statement about the declaration stage only.
* `event1653`, direction 0 (`trainStationNew/both/9aov7tBy2LfDmizfK_inv10.als`,
  `inv10` to `inv10c`). The selected native programs are the same program in the
  base order. The two supplemental slices use different connecting
  permutations, so the supplemental comparison differs at its first action.
* `event69`, direction 0 (`coursesOld/both/mQTiiJRnphSxEscmT_inv7.als`, `inv7`
  to `inv7c`). The supplemental slices are equal while the selected native
  programs differ: supplemental agreement was never agreement of the selected
  programs, in either direction.

Not claimed: anything about the matrix stage, the selected binder maps or the
verdict of these directions. Those are measured by the replay, not here.
-/
namespace ACGN.FifthFive.SharedActionBoundaryWitness

open ACGN.FifthFive.SharedActionBoundary

/-- The old Java reader called isNull/getString on both coordinates, before
testing the (empty in these instances) repeated-occurrence classes. -/
def legacyStringCoordinate : Wire → Except String (Option String)
  | .null => .ok none
  | .text s => .ok (some s)
  | _ => .error "COORDINATE_NOT_STRING"

def legacyCoordinates (r : RawAction) : Except String Unit :=
  both (legacyStringCoordinate r.source) (legacyStringCoordinate r.target)
    (fun _ _ => .ok ())

def e16FirstAction : RawAction :=
  ⟨"declaration", "insert", 1, .null, .nat 1, none, some ["ALL", "Course", "ONE", "0"]⟩

def e1653FirstAction : RawAction :=
  ⟨"declarationPermutation", "", 0, .nats [2, 1, 0], .nats [0, 1], none, none⟩

theorem e16_old_reader_rejects : legacyCoordinates e16FirstAction = .error "COORDINATE_NOT_STRING" := rfl
theorem e1653_old_reader_rejects : legacyCoordinates e1653FirstAction = .error "COORDINATE_NOT_STRING" := rfl

theorem e16_stage_reader_accepts (parse : String → Option RepeatedOccurrence.Path) :
    scanRaw parse [] [] [e16FirstAction] = .ok none := rfl
theorem e1653_stage_reader_accepts (parse : String → Option RepeatedOccurrence.Path) :
    scanRaw parse [] [] [e1653FirstAction] = .ok none := rfl

inductive Quantifier where
  | ALL
  | SOME
  deriving DecidableEq

inductive Cardinality where
  | ONE
  | LONE
  | SOME
  | SET
  deriving DecidableEq

inductive Sig where
  | Person
  | Project
  | Course
  | Track
  | Semaphore
  deriving DecidableEq

structure Tuple where
  quantifier : Quantifier
  type : Sig
  cardinality : Cardinality
  disjointness : Nat
  deriving DecidableEq

def allOne (s : Sig) : Tuple := ⟨Quantifier.ALL, s, Cardinality.ONE, 0⟩

/-- The declaration stage of one arm's compared stream: an optional zero-charge
permutation action, then the declaration actions. -/
def declarationStage (permutation : Option (List Nat × List Nat))
    (actions : List (NativeAction Tuple)) : List (Staged (NativeAction Tuple)) :=
  (match permutation with
    | none => []
    | some (s, t) => [Staged.permutation s t]) ++ actions.map Staged.declaration

def deleteAt (l : Nat) : Op := ⟨DKind.delete, 1, some l, none⟩
def insertAt (r : Nat) : Op := ⟨DKind.insert, 1, none, some r⟩
def keepAt (l r : Nat) : Op := ⟨DKind.keep, 0, some l, some r⟩
def updateAt (l r : Nat) : Op := ⟨DKind.update, 1, some l, some r⟩

/-! ### event16, direction 0 -/

def e16Source : List (Origin Tuple) :=
  [⟨0, allOne Sig.Person⟩, ⟨1, allOne Sig.Project⟩, ⟨2, allOne Sig.Project⟩]

def e16Target : List (Origin Tuple) := [⟨1, allOne Sig.Course⟩, ⟨0, allOne Sig.Person⟩]

def e16Native : List Op := [deleteAt 0, updateAt 1 0, updateAt 2 1]

def e16FastSupplemental : List Op := [insertAt 0, keepAt 0 1, deleteAt 1, deleteAt 2]

def e16Fast : ArmEvidence Tuple :=
  ⟨e16Source, e16Target, e16Native, e16Source, e16Target, e16FastSupplemental⟩

def e16Certified : ArmEvidence Tuple :=
  ⟨e16Source, e16Target, e16Native, e16Source, e16Target, e16Native⟩

theorem e16_native_replays : check e16Source e16Target 0 0 e16Native = true := by decide

theorem e16_supplemental_replays :
    check e16Source e16Target 0 0 e16FastSupplemental = true := by decide

theorem e16_equal_charge :
    programCost e16Native = 3 ∧ programCost e16FastSupplemental = 3 := by decide

/-- The supplemental comparison (the old authority) reports a difference. -/
theorem e16_supplemental_stage_differs :
    declarationStage none (supplementalDiagnostic e16Fast) ≠
      declarationStage none (supplementalDiagnostic e16Certified) := by decide

/-- The selected native declaration stages are equal. -/
theorem e16_native_stage_equal :
    declarationStage none (compared e16Fast) = declarationStage none (compared e16Certified) := rfl

/-- The supplemental slice is a replay of equal charge, and it is not accepted
in place of the selected program. -/
theorem e16_substituted_selection_rejected :
    selectionBound e16Fast.nativeOps e16Fast.supplementalOps = false := by decide

/-! ### event1653, direction 0 -/

def e1653Source : List (Origin Tuple) :=
  [⟨2, allOne Sig.Semaphore⟩, ⟨0, allOne Sig.Track⟩, ⟨1, allOne Sig.Track⟩]

def e1653Target : List (Origin Tuple) := [⟨0, allOne Sig.Track⟩, ⟨1, allOne Sig.Track⟩]

def e1653Native : List Op := [deleteAt 0, keepAt 1 0, keepAt 2 1]

def e1653FastSupplementalSource : List (Origin Tuple) :=
  [⟨1, allOne Sig.Track⟩, ⟨0, allOne Sig.Track⟩, ⟨2, allOne Sig.Semaphore⟩]

def e1653FastSupplemental : List Op := [keepAt 0 0, keepAt 1 1, deleteAt 2]

def e1653CertifiedSupplementalSource : List (Origin Tuple) :=
  [⟨2, allOne Sig.Semaphore⟩, ⟨1, allOne Sig.Track⟩, ⟨0, allOne Sig.Track⟩]

def e1653CertifiedSupplemental : List Op := [deleteAt 0, keepAt 1 0, keepAt 2 1]

def e1653Fast : ArmEvidence Tuple :=
  ⟨e1653Source, e1653Target, e1653Native,
    e1653FastSupplementalSource, e1653Target, e1653FastSupplemental⟩

def e1653Certified : ArmEvidence Tuple :=
  ⟨e1653Source, e1653Target, e1653Native,
    e1653CertifiedSupplementalSource, e1653Target, e1653CertifiedSupplemental⟩

theorem e1653_native_replays : check e1653Source e1653Target 0 0 e1653Native = true := by decide

theorem e1653_supplementals_replay :
    check e1653FastSupplementalSource e1653Target 0 0 e1653FastSupplemental = true ∧
      check e1653CertifiedSupplementalSource e1653Target 0 0 e1653CertifiedSupplemental = true := by
  decide

/-- The supplemental comparison differs, with the recorded connecting
permutations `[2,1,0]` and `[0,2,1]` of the two arms. -/
theorem e1653_supplemental_stage_differs :
    declarationStage (some ([2, 1, 0], [0, 1])) (supplementalDiagnostic e1653Fast) ≠
      declarationStage (some ([0, 2, 1], [0, 1])) (supplementalDiagnostic e1653Certified) := by
  decide

/-- The selected native declaration stages are equal and use the base order. -/
theorem e1653_native_stage_equal :
    declarationStage none (compared e1653Fast) =
      declarationStage none (compared e1653Certified) := rfl

/-! ### event69, direction 0 -/

def e69FastNative : List Op := [deleteAt 0, updateAt 1 0, updateAt 2 1]

def e69CertifiedNative : List Op := [insertAt 0, keepAt 0 1, deleteAt 1, deleteAt 2]

def e69Fast : ArmEvidence Tuple :=
  ⟨e16Source, e16Target, e69FastNative, e16Source, e16Target, e69CertifiedNative⟩

def e69Certified : ArmEvidence Tuple :=
  ⟨e16Source, e16Target, e69CertifiedNative, e16Source, e16Target, e69CertifiedNative⟩

theorem e69_natives_replay :
    check e16Source e16Target 0 0 e69FastNative = true ∧
      check e16Source e16Target 0 0 e69CertifiedNative = true := by decide

/-- The supplemental comparison accepts this declaration stage. -/
theorem e69_supplemental_stage_equal :
    declarationStage none (supplementalDiagnostic e69Fast) =
      declarationStage none (supplementalDiagnostic e69Certified) := rfl

/-- The selected native declaration programs differ. -/
theorem e69_native_stage_differs :
    declarationStage none (compared e69Fast) ≠ declarationStage none (compared e69Certified) := by
  decide

/-! ### Consequences -/

/-- Equal endpoints, a valid replay and an equal total do not determine the
action list. A verdict cannot be inferred from them. -/
theorem equal_charge_replays_can_differ :
    ∃ (src tgt : List (Origin Tuple)) (p q : List Op),
      check src tgt 0 0 p = true ∧ check src tgt 0 0 q = true ∧
      programCost p = programCost q ∧ nativeActions src tgt p ≠ nativeActions src tgt q :=
  ⟨e16Source, e16Target, e16Native, e16FastSupplemental, by decide, by decide, by decide,
    by decide⟩

/-- Supplemental agreement and selected-program agreement are independent:
each occurs without the other on a retained source shape. -/
theorem supplemental_agreement_independent_of_native :
    (supplementalDiagnostic e16Fast ≠ supplementalDiagnostic e16Certified ∧
        compared e16Fast = compared e16Certified) ∧
      (supplementalDiagnostic e69Fast = supplementalDiagnostic e69Certified ∧
        compared e69Fast ≠ compared e69Certified) :=
  ⟨⟨by decide, rfl⟩, ⟨rfl, by decide⟩⟩

/-! ### Printed transcription, compared with the receipts by the witness check -/

def sigName : Sig → String
  | Sig.Person => "Person"
  | Sig.Project => "Project"
  | Sig.Course => "Course"
  | Sig.Track => "Track"
  | Sig.Semaphore => "Semaphore"

def quantifierName : Quantifier → String
  | Quantifier.ALL => "ALL"
  | Quantifier.SOME => "SOME"

def cardinalityName : Cardinality → String
  | Cardinality.ONE => "ONE"
  | Cardinality.LONE => "LONE"
  | Cardinality.SOME => "SOME"
  | Cardinality.SET => "SET"

def kindName : DKind → String
  | DKind.insert => "insert"
  | DKind.delete => "delete"
  | DKind.keep => "keep"
  | DKind.update => "update"

def renderOrigin (o : Origin Tuple) : String :=
  s!"{o.ordinal}:{quantifierName o.tuple.quantifier}/{sigName o.tuple.type}/{cardinalityName o.tuple.cardinality}/{o.tuple.disjointness}"

def renderIndex : Option Nat → String
  | none => "-"
  | some n => toString n

def renderOp (op : Op) : String :=
  s!"{kindName op.kind}({renderIndex op.left},{renderIndex op.right})${op.cost}"

def renderProgram (src tgt : List (Origin Tuple)) (ops : List Op) : String :=
  s!"src=[{" ".intercalate (src.map renderOrigin)}] tgt=[{" ".intercalate (tgt.map renderOrigin)}] ops=[{" ".intercalate (ops.map renderOp)}]"

def renderArm (event arm : String) (e : ArmEvidence Tuple) : List String :=
  [s!"SHARED_BOUNDARY_WITNESS|{event}|{arm}|native|{renderProgram e.nativeSource e.nativeTarget e.nativeOps}",
   s!"SHARED_BOUNDARY_WITNESS|{event}|{arm}|supplemental|{renderProgram e.supplementalSource e.supplementalTarget e.supplementalOps}"]

#eval (renderArm "event16-0" "fast" e16Fast ++ renderArm "event16-0" "certified" e16Certified ++
  renderArm "event1653-0" "fast" e1653Fast ++ renderArm "event1653-0" "certified" e1653Certified ++
  renderArm "event69-0" "fast" e69Fast ++ renderArm "event69-0" "certified" e69Certified).forM
    IO.println

end ACGN.FifthFive.SharedActionBoundaryWitness
