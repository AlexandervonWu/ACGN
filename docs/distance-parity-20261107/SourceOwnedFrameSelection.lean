import StructuralDeclarationTyping

/- A normalization pass can retain several issued bindings with one parser
   lineage. Select by the actual current binding object before requiring a
   unique frame. Identity is reference identity in Java, never an alpha string.
   This is evidence selection, not a quantifier rewrite or payment rule. -/
namespace SourceOwnedFrameSelection

structure Key (Identity : Type) where
  owner : Identity
  binding : Identity
  declaration : Nat
  variableOccurrence : Nat
  tuple : Nat
  deriving DecidableEq

structure Frame (Identity Payload : Type) where
  key : Key Identity
  payload : Payload
  deriving DecidableEq

def lineageMatches [DecidableEq I] (query : Key I) (frame : Frame I P) : Bool :=
  decide (frame.key.owner = query.owner ∧ frame.key.declaration = query.declaration ∧
    frame.key.variableOccurrence = query.variableOccurrence ∧ frame.key.tuple = query.tuple)

def objectMatches [DecidableEq I] (query : Key I) (frame : Frame I P) : Bool :=
  decide (frame.key = query)

def only : List A → Option A
  | [a] => some a
  | _ => none

def oldSelect [DecidableEq I] (issued : List (Frame I P)) (query : Key I) :=
  only (issued.filter (lineageMatches query))

def select [DecidableEq I] (issued : List (Frame I P)) (query : Key I) :=
  only (issued.filter (objectMatches query))

theorem only_exact (xs : List A) (a : A) : only xs = some a ↔ xs = [a] := by
  cases xs with
  | nil => simp [only]
  | cons b xs =>
    cases xs with
    | nil => simp [only]
    | cons c xs => simp [only]

theorem selected_issued_exact [DecidableEq I] (issued : List (Frame I P))
    (query : Key I) (selected : Frame I P) (h : select issued query = some selected) :
    selected ∈ issued ∧ selected.key = query ∧
      issued.filter (objectMatches query) = [selected] := by
  have exactList := (only_exact _ _).mp h
  have member : selected ∈ issued.filter (objectMatches query) := by rw [exactList]; simp
  have facts := List.mem_filter.mp member
  exact ⟨facts.1, of_decide_eq_true facts.2, exactList⟩

theorem foreign_binding_rejected [DecidableEq I] (issued : List (Frame I P))
    (query : Key I) (selected : Frame I P)
    (foreign : selected.key.binding ≠ query.binding) :
    select issued query ≠ some selected := by
  intro h
  exact foreign (congrArg Key.binding (selected_issued_exact issued query selected h).2.1)

theorem unique_original_payload [DecidableEq I] (issued : List (Frame I P))
    (query : Key I) (selected : Frame I P) (h : select issued query = some selected) :
    ∃ original ∈ issued, original = selected ∧
      ∀ interpretation : Frame I P → V, interpretation original = interpretation selected := by
  exact ⟨selected, (selected_issued_exact issued query selected h).1, rfl, fun _ => rfl⟩

/- Later admission still checks the complete structural group and domain.
   Selecting a frame does not authorize altered payloads, stale owners or an
   unverified slot-to-binding lookup. -/
theorem selected_group_sound [DecidableEq I]
    (issued : List (Frame I StructuralDeclarationTyping.Group))
    (query : Key I) (selected : Frame I StructuralDeclarationTyping.Group)
    (head : StructuralDeclarationTyping.Head) (compared : StructuralDeclarationTyping.Group)
    (selection : select issued query = some selected)
    (checks : StructuralDeclarationTyping.structuralAdmission head selected.payload compared = true)
    (domain : StructuralDeclarationTyping.Group → (StructuralDeclarationTyping.Slot → A) → A → Prop)
    (env : StructuralDeclarationTyping.Slot → A) :
    selected ∈ issued ∧ selected.key = query ∧
      (StructuralDeclarationTyping.permits domain env compared ↔
        StructuralDeclarationTyping.permits domain env selected.payload) :=
  ⟨(selected_issued_exact issued query selected selection).1,
    (selected_issued_exact issued query selected selection).2.1,
    StructuralDeclarationTyping.admitted_group_sound head selected.payload compared checks domain env⟩

/- Natural pre-reseed observation: owner is one phase object, bindings _l3/_l5
   have distinct object identities but declaration32/variable35/tuple0. Tokens
   3/5 name those observed objects, not a runtime test based on their names. -/
structure Context where
  phasePath : String
  ownerRole : String
  bindingPath : String
  exactType : String
  domain : String
  dependencies : List Nat
  disjointness : Nat
  deriving DecidableEq

def sourceDomain : String :=
  "13:GLOBALBINDING[3:22:alloy/signature/Course18:RELATION[6:Course]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}"
def prior : Frame Nat Context := ⟨⟨0,3,32,35,0⟩,
  ⟨"phase[0]","ONE","root/predicate[0]/body[1]/body[1]/or[2]/local-decl[0]",
    "RELATION[6:Course]",sourceDomain,[],1⟩⟩
def current : Frame Nat Context := ⟨⟨0,5,32,35,0⟩,
  ⟨"phase[0]","ONE","root/predicate[0]/or[3]/local-decl[0]",
    "RELATION[6:Course]",sourceDomain,[],2⟩⟩

theorem natural_old_rejection : oldSelect [prior,current] current.key = none := by decide
theorem natural_current_object_selection : select [prior,current] current.key = some current := by rfl
theorem natural_pool_reverse_preserves_selection : select [current,prior] current.key = some current := by rfl
theorem stale_binding_not_selected : select [prior,current] current.key ≠ some prior := by decide
theorem duplicate_current_rejected : select [prior,current,current] current.key = none := by decide
theorem missing_current_rejected : select [prior] current.key = none := by decide
theorem wrong_owner_rejected : select [prior,current] { current.key with owner := 9 } = none := by decide
theorem wrong_tuple_rejected : select [prior,current] { current.key with tuple := 1 } = none := by decide
theorem foreign_same_lineage_rejected :
    select [prior,current] { current.key with binding := 9 } = none := by decide

/- Held-out shape: nonzero phase owner, three ordered dependent binders.
   Context data are preserved unchanged; authentic-domain checking still follows. -/
def heldout : Frame Nat Context := ⟨⟨7,9,101,103,2⟩,
  { current.payload with phasePath := "phase[7]", dependencies := [4,6,4] }⟩
theorem heldout_unique_selected :
    select [current,heldout,prior] heldout.key = some heldout := by rfl
theorem heldout_dependency_order_retained :
    (select [current,heldout,prior] heldout.key).map (fun f => f.payload.dependencies) =
      some [4,6,4] := by decide

#print axioms selected_issued_exact
#print axioms selected_group_sound
#print axioms natural_old_rejection
end SourceOwnedFrameSelection
