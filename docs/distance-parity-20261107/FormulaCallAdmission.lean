import BoundCallAdmission
import MatrixReplay

/- Formula calls use the same ordered source-argument correspondence as
   expression calls. Bool is a result type, not a missing relation ancestry.
   This does not unfold a call or equate paid repair endpoints. -/
namespace FormulaCallAdmission
open BoundCallAdmission

structure CallShape where
  kind : String
  result : String
  authority : Authority
  arity : Nat
  ordered : Bool
  relationAuthority : Bool
  argumentsChecked : Bool
  deriving DecidableEq

def common (c : CallShape) : Bool :=
  (c.authority == .declaration || c.authority == .typecheckedImport) &&
  decide (0 < c.arity) && decide (c.arity <= 64) && c.ordered && c.argumentsChecked

def oldGate (c : CallShape) : Bool :=
  common c && c.kind == "call/expression" && c.result == "RELATION" && c.relationAuthority

def newGate (c : CallShape) : Bool := common c &&
  ((c.kind == "call/expression" && c.result == "RELATION" && c.relationAuthority) ||
    (c.kind == "call/formula" && c.result == "BOOL"))

def naturalCall : CallShape :=
  ⟨"call/formula", "BOOL", .declaration, 2, true, false, true⟩

theorem exact_old_rejection : oldGate naturalCall = false := by decide
theorem new_typed_acceptance : newGate naturalCall = true := by decide
theorem wrong_result_rejected : newGate { naturalCall with result := "RELATION" } = false := by decide
theorem unordered_rejected : newGate { naturalCall with ordered := false } = false := by decide
theorem unchecked_arguments_rejected :
    newGate { naturalCall with argumentsChecked := false } = false := by decide

theorem formula_transport {V : Type} (invoke : Head → List V → Prop)
    (head : Head) (old new : Slot → V) (r : Slot → Slot)
    (literal : Nat → V) (join difference : V → V → V)
    (links : ∀ s, new (r s) = old s) (args : List Arg) :
    invoke head ((args.map (rename r)).map (eval new literal join difference)) ↔
      invoke head (args.map (eval old literal join difference)) := by
  have ordered : (args.map (rename r)).map (eval new literal join difference) =
      args.map (eval old literal join difference) := by
    induction args with
    | nil => rfl
    | cons a rest ih =>
      simp only [List.map_cons, argument_transport old new r literal join difference links, ih]
  rw [ordered]

structure SourceArgument where
  lineage : Nat
  sourceName : String
  owner : String
  phase : Nat
  role : String
  coordinate : Nat
  dependency : List Nat
  type : String
  deriving DecidableEq

def studentArg : SourceArgument :=
  ⟨271,"s","root/predicate[0]/decl[0]@pos",0,"MATRIX",1,[],"RELATION[6:Person]"⟩
def classArg : SourceArgument :=
  ⟨272,"c","root/predicate[0]/decl[1]@pos",0,"MATRIX",0,[],"RELATION[5:Class]"⟩
def sourceArguments := [studentArg,classArg]

theorem wrong_owner_rejected :
    [{ studentArg with owner := "foreign" },classArg] ≠ sourceArguments := by decide
theorem wrong_occurrence_rejected :
    [{ studentArg with lineage := 272 },classArg] ≠ sourceArguments := by decide
theorem reversed_arguments_rejected : [classArg,studentArg] ≠ sourceArguments := by decide
theorem wrong_phase_rejected :
    [{ studentArg with phase := 1 },classArg] ≠ sourceArguments := by decide

/- Concrete natural source body at the actual call. Its two arguments retain
   their own carriers, including Student's Person carrier and subset guard.
   Both construction paths keep the same occurrence and ordered arguments;
   no link premise between the different repair predicates is assumed. -/
def studentInClass {Person Class Group : Type}
    (groups : Class → Person → Group → Prop) (s : Person) (c : Class) : Prop :=
  ∃ g, groups c s g

theorem natural_source_correspondence {Person Class Group : Type}
    (groups : Class → Person → Group → Prop) (s : Person) (c : Class) :
    studentInClass groups s c ↔ (∃ g, groups c s g) := Iff.rfl

def toCanonical (slot : Slot) : Slot :=
  ⟨slot.owner, match slot.index with | 0 => 1 | 1 => 0 | n+2 => n+2⟩
def sourceEnv {Person Class : Type} (s : Person) (c : Class) (slot : Slot) : Sum Person Class :=
  match slot.index with | 1 => .inr c | _ => .inl s
def canonicalEnv {Person Class : Type} (s : Person) (c : Class) (slot : Slot) : Sum Person Class :=
  match slot.index with | 0 => .inr c | _ => .inl s

theorem actual_links {Person Class : Type} (s : Person) (c : Class) (slot : Slot) :
    canonicalEnv s c (toCanonical slot) = sourceEnv s c slot := by
  rcases slot with ⟨owner, index⟩
  cases index with
  | zero => rfl
  | succ n => cases n <;> rfl

def actualArgs : List Arg := [.bound ⟨0,0⟩, .bound ⟨0,1⟩]
def actualHead : Head := ⟨0,0,.declaration,0,[1,2]⟩
def invokeNatural {Person Class Group : Type} (groups : Class → Person → Group → Prop)
    (_ : Head) : List (Sum Person Class) → Prop
  | [.inl s,.inr c] => studentInClass groups s c
  | _ => False

theorem natural_actual_argument_transport {Person Class Group : Type}
    (groups : Class → Person → Group → Prop) (s : Person) (c : Class) :
    invokeNatural groups actualHead
      ((actualArgs.map (rename toCanonical)).map
        (eval (canonicalEnv s c) (fun _ => .inl s) (fun x _ => x) (fun x _ => x))) ↔
    studentInClass groups s c := by
  exact formula_transport (invokeNatural groups) actualHead (sourceEnv s c)
    (canonicalEnv s c) toCanonical (fun _ => .inl s) (fun x _ => x) (fun x _ => x)
    (actual_links s c) actualArgs

theorem natural_actual_argument_transport_reverse {Person Class Group : Type}
    (groups : Class → Person → Group → Prop) (s : Person) (c : Class) :
    studentInClass groups s c ↔ invokeNatural groups actualHead
      ((actualArgs.map (rename toCanonical)).map
        (eval (canonicalEnv s c) (fun _ => .inl s) (fun x _ => x) (fun x _ => x))) :=
  (natural_actual_argument_transport groups s c).symm

/- The actual selected call subtree occupies operation23, followed by its
   distinct argument occurrences24/25. A charged deletion/insertion is a
   syntactic repair, not a logical equivalence or a free call rewrite. -/
structure SelectedNode where
  occurrence : Nat
  address : String
  type : String
  deriving DecidableEq
def callNode : SelectedNode := ⟨268,"root/child/0/child/2/child/0","BOOL"⟩
def sNode : SelectedNode := ⟨271,"root/child/0/child/2/child/0/child/0","RELATION[6:Person]"⟩
def cNode : SelectedNode := ⟨272,"root/child/0/child/2/child/0/child/1","RELATION[5:Class]"⟩
def selectedSubtree := [callNode,sNode,cNode]
inductive ChargedEdit : List SelectedNode → List SelectedNode → Nat → Prop where
  | delete (n : SelectedNode) (rest : List SelectedNode) : ChargedEdit (n::rest) rest 1
  | insert (n : SelectedNode) (rest : List SelectedNode) : ChargedEdit rest (rest ++ [n]) 1

theorem selected_delete_path : MatrixReplay.Replay ChargedEdit selectedSubtree [] 3 :=
  .next (ChargedEdit.delete _ _) (.next (ChargedEdit.delete _ _)
    (.next (ChargedEdit.delete _ _) (.done _)))
theorem selected_insert_path : MatrixReplay.Replay ChargedEdit [] selectedSubtree 3 :=
  .next (ChargedEdit.insert callNode []) (.next (ChargedEdit.insert sNode [callNode])
    (.next (ChargedEdit.insert cNode [callNode,sNode]) (.done _)))
theorem no_free_call_delete : ¬ ChargedEdit selectedSubtree [sNode,cNode] 0 := by
  intro h; cases h
theorem wrong_call_occurrence_rejected :
    {callNode with occurrence := 269} ≠ callNode := by decide

#print axioms formula_transport
#print axioms exact_old_rejection
#print axioms new_typed_acceptance
#print axioms natural_source_correspondence
#print axioms actual_links
#print axioms natural_actual_argument_transport
#print axioms natural_actual_argument_transport_reverse
#print axioms selected_delete_path
#print axioms selected_insert_path
#print axioms no_free_call_delete
end FormulaCallAdmission
