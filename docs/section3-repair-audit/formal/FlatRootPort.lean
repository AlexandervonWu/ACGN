import Std

namespace ACGN.BoundedFive.FlatRootPort

/- P2-05: control prefix of OperatorDeclaration.validateFlatPort, called by
   its public constructor (also reached by monomorphic). None denotes the
   disabled FlatLicense; some index denotes atRootPort(index). Root depth zero
   comes from FlatLicense.atRootPort -> PortPath.at, not from an index theorem.
   Int retains the signed Java index; Nat denotes the nonnegative list size.
   There is no arithmetic here that could overflow Java int.

   Passing this prefix is NECESSARY, not sufficient, for constructor success.
   The following independent postconditions are checked by the remaining Java
   body and exercised separately by FlatRootPortRegressionTest:
   * elementSchema must return One(outputType), using actual GraphType.equals;
   * the selected container law must declare associativity;
   * its ArityPolicy must satisfy requireFlatSpliceClosure;
   * admitting zero requires the selected law's exact unit license.
   No Boolean stand-ins for these postconditions are asserted or proved here.
   Earlier name/type-variable/schema/law validation, helper implementations,
   substitution typing, flattening semantics, and certificate authority are
   outside this control theorem. Nonflat exemption applies only to this prefix.

   Compiler extraction is separate evidence: it must check the constructor's
   guard call, factory routing, license creation and the complete guard shape,
   including the disabled early return and signed range check. Only THEN may
   it emit SourceProgram using the actual two literals and generate equality
   proofs consumed by extracted_guard_iff. sourceProgram is the expected
   contract, NOT an extraction or a source-correspondence certificate. -/

structure SourceProgram where
  requiredPortCount : Nat
  rootPortIndex : Int
  deriving DecidableEq, Repr

def sourceProgram : SourceProgram := ⟨1, 0⟩

def runSourceProgram (program : SourceProgram) (portCount : Nat)
    (flatPort : Option Int) : Bool :=
  match flatPort with
  | none => true
  | some index =>
    if index < 0 || index >= (portCount : Int) then false
    else if portCount != program.requiredPortCount || index != program.rootPortIndex
      then false
    else true

def guard (portCount : Nat) (flatPort : Option Int) : Bool :=
  runSourceProgram sourceProgram portCount flatPort

theorem source_nonflat_exempt (program : SourceProgram) (portCount : Nat) :
    runSourceProgram program portCount none = true := rfl

theorem source_enabled_iff (program : SourceProgram) (portCount : Nat) (index : Int) :
    runSourceProgram program portCount (some index) = true <->
      0 <= index ∧ index < (portCount : Int) ∧
        portCount = program.requiredPortCount ∧ index = program.rootPortIndex := by
  simp only [runSourceProgram, Bool.or_eq_true, decide_eq_true_eq, bne_iff_ne]
  split
  · rename_i outOfRange
    simp only [Bool.false_eq_true, false_iff]
    omega
  · rename_i inRange
    split
    · rename_i mismatch
      simp only [Bool.false_eq_true, false_iff]
      omega
    · rename_i equalConstants
      constructor
      · intro _
        omega
      · intro _
        rfl

theorem source_out_of_range_rejected (program : SourceProgram) (portCount : Nat)
    (index : Int) (bad : index < 0 ∨ (portCount : Int) <= index) :
    runSourceProgram program portCount (some index) = false := by
  rcases bad with negative | tooLarge
  · simp [runSourceProgram, negative]
  · simp [runSourceProgram, tooLarge]

theorem flat_guard_iff (portCount : Nat) (index : Int) :
    guard portCount (some index) = true <-> portCount = 1 ∧ index = 0 := by
  rw [guard, source_enabled_iff]
  simp only [sourceProgram]
  omega

theorem guard_iff (portCount : Nat) (flatPort : Option Int) :
    guard portCount flatPort = true <->
      flatPort = none ∨ (portCount = 1 ∧ flatPort = some 0) := by
  cases flatPort with
  | none => simp [guard, runSourceProgram]
  | some index => simp [flat_guard_iff]

theorem enabled_requires_single_root (portCount : Nat) (flatPort : Option Int)
    (enabled : flatPort.isSome = true) (passed : guard portCount flatPort = true) :
    portCount = 1 ∧ flatPort = some 0 := by
  rcases (guard_iff portCount flatPort).mp passed with disabled | root
  · simp [disabled] at enabled
  · exact root

theorem bad_index_rejected (portCount : Nat) (index : Int) (bad : index ≠ 0) :
    guard portCount (some index) = false := by
  cases h : guard portCount (some index)
  · rfl
  · exact False.elim (bad ((flat_guard_iff portCount index).mp h).2)

theorem wrong_port_count_rejected (portCount : Nat) (index : Int) (bad : portCount ≠ 1) :
    guard portCount (some index) = false := by
  cases h : guard portCount (some index)
  · rfl
  · exact False.elim (bad ((flat_guard_iff portCount index).mp h).1)

theorem multiport_rejected (portCount : Nat) (index : Int) (multiple : 1 < portCount) :
    guard portCount (some index) = false :=
  wrong_port_count_rejected portCount index (by omega)

theorem no_ports_rejected (index : Int) : guard 0 (some index) = false :=
  wrong_port_count_rejected 0 index (by decide)

theorem nonflat_exempt (portCount : Nat) : guard portCount none = true := rfl

/- This witness is a root schema, not a proof that the schema is a container
   of the correct element type. That is the independent Java postcondition. -/
theorem sole_root_schema {Schema : Type _} (ports : List Schema) (index : Int)
    (passed : guard ports.length (some index) = true) :
    (∃ schema, ports = [schema]) ∧ index = 0 := by
  obtain ⟨count, root⟩ := (flat_guard_iff ports.length index).mp passed
  exact ⟨List.length_eq_one_iff.mp count, root⟩

/- List.map is the model of one-output-per-input substitution. This theorem
   does not establish that the Java substitution loop implements List.map. -/
theorem map_preserves_control {Schema Result : Type _} (substitute : Schema -> Result)
    (ports : List Schema) (flatPort : Option Int) (program : SourceProgram) :
    runSourceProgram program (ports.map substitute).length flatPort =
      runSourceProgram program ports.length flatPort := by
  simp

/- Generated proofs must discharge both equalities from extracted literals,
   not pass sourceProgram back as though it came from javac. Altered constants
   still have source_enabled_iff but cannot discharge this expected contract. -/
theorem extracted_guard_iff (program : SourceProgram)
    (requiredCount : program.requiredPortCount = 1)
    (rootIndex : program.rootPortIndex = 0)
    (portCount : Nat) (flatPort : Option Int) :
    runSourceProgram program portCount flatPort = true <->
      flatPort = none ∨ (portCount = 1 ∧ flatPort = some 0) := by
  cases program with
  | mk required permitted =>
    cases requiredCount
    cases rootIndex
    exact guard_iff portCount flatPort

end ACGN.BoundedFive.FlatRootPort

#print axioms ACGN.BoundedFive.FlatRootPort.source_nonflat_exempt
#print axioms ACGN.BoundedFive.FlatRootPort.source_enabled_iff
#print axioms ACGN.BoundedFive.FlatRootPort.source_out_of_range_rejected
#print axioms ACGN.BoundedFive.FlatRootPort.flat_guard_iff
#print axioms ACGN.BoundedFive.FlatRootPort.guard_iff
#print axioms ACGN.BoundedFive.FlatRootPort.enabled_requires_single_root
#print axioms ACGN.BoundedFive.FlatRootPort.bad_index_rejected
#print axioms ACGN.BoundedFive.FlatRootPort.wrong_port_count_rejected
#print axioms ACGN.BoundedFive.FlatRootPort.multiport_rejected
#print axioms ACGN.BoundedFive.FlatRootPort.no_ports_rejected
#print axioms ACGN.BoundedFive.FlatRootPort.nonflat_exempt
#print axioms ACGN.BoundedFive.FlatRootPort.sole_root_schema
#print axioms ACGN.BoundedFive.FlatRootPort.map_preserves_control
#print axioms ACGN.BoundedFive.FlatRootPort.extracted_guard_iff
