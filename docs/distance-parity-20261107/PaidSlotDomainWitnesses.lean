import PaidSlotDomainTransport

/- Retained route/tuple witnesses, not whole-program certification. The
   generator joins the diagnostic owner inventory to actual selected native
   declaration orders and matrix occurrence paths. Domain strings are from
   that diagnostic inventory; domain-guard Java refinement remains open. -/
namespace PaidSlotDomainWitnesses
open PaidSlotDomainTransport SelectedSlotTransport PhaseOwnedJointRoutes
open Focused225SharedContracts Focused225Concrete
open ACGN.FifthFive.SharedActionBoundary (DKind)
set_option maxRecDepth 16384
set_option maxHeartbeats 2000000

def event1799_0_left_p1_b0 : Binding := {
  origin := ⟨"2fdc8d77a108dd87eb61656f5bb5cfa245d67abf8d225ea65d198bf4c55aaea8", "inv12", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1799_0_left : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [4, 0], owned := [], imports := [] }, { phase := 1, path := [4, 0, 3, 0], owned := [event1799_0_left_p1_b0], imports := [] }, { phase := 2, path := [4, 0, 3, 0, 1, 0], owned := [], imports := [event1799_0_left_p1_b0] }, { phase := 3, path := [4, 0, 3, 0, 2, 0], owned := [], imports := [event1799_0_left_p1_b0] }], [[⟨4, 0, -1⟩], [⟨4, 0, 0⟩, ⟨3, 0, -1⟩], [⟨4, 0, 0⟩, ⟨3, 0, 0⟩, ⟨1, 0, -1⟩], [⟨4, 0, 0⟩, ⟨3, 0, 1⟩, ⟨2, 0, -1⟩]]⟩

def event1799_0_right_p1_b0 : Binding := {
  origin := ⟨"2fdc8d77a108dd87eb61656f5bb5cfa245d67abf8d225ea65d198bf4c55aaea8", "inv12c", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "SOME", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1799_0_right : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [3, 0], owned := [], imports := [] }, { phase := 1, path := [3, 0, 2, 0], owned := [event1799_0_right_p1_b0], imports := [] }, { phase := 2, path := [3, 0, 2, 0, 1, 0], owned := [], imports := [event1799_0_right_p1_b0] }], [[⟨3, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 0, -1⟩]]⟩

def event1799_0_refs : DependencyInventory := ⟨[(event1799_0_left_p1_b0, [])], [(event1799_0_right_p1_b0, [])]⟩
def event1799_0_tuple (b : Binding) : List String := (([(event1799_0_left_p1_b0, ["ALL", "File", "ONE", "0"]), (event1799_0_right_p1_b0, ["SOME", "File", "ONE", "0"])].find? (fun p => p.1 == b)).map Prod.snd).getD []
def event1799_0_env : Environment := ⟨[event1799_0_left_p1_b0], [event1799_0_right_p1_b0]⟩
def event1799_0_candidate : JointCandidate (List String) := ⟨[⟨0, ["ALL", "File", "ONE", "0"]⟩], [⟨0, ["SOME", "File", "ONE", "0"]⟩], [⟨.update, 1, some 0, some 0⟩], [], [], []⟩
def event1799_0_program : OwnerProgram := ⟨1, 1, event1799_0_env, event1799_0_candidate⟩
def event1799_0_route : TypedRoute := ⟨⟨.update, 1, some 0, some 0, some ["ALL", "File", "ONE", "0"], some ["SOME", "File", "ONE", "0"]⟩, some event1799_0_left_p1_b0, some event1799_0_right_p1_b0⟩

theorem event1799_0_owner_program : ownerProgramCheck event1799_0_tuple event1799_0_left.scopes event1799_0_right.scopes event1799_0_program = true := by decide +kernel

def event1799_0_read0_before : MatrixUse := ⟨event1799_0_left_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[1]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1799_0_read0_after : MatrixUse := ⟨event1799_0_right_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[0]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1799_0_sourceUses := [event1799_0_read0_before]
def event1799_0_targetUses := [event1799_0_read0_after]

theorem event1799_0_read0_accepted : dependentSlotTransport event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program event1799_0_refs 0 event1799_0_sourceUses event1799_0_targetUses event1799_0_read0_before event1799_0_read0_after = some event1799_0_route := by decide +kernel

def event1799_0_read0_pair : Focused225SelectedConsumers.MatrixPair := ⟨⟨"495d0fc767e572d118d51781e9412bf76543cd7afb4f1a67d325b7c68e11779a", "/fast/phases/2/program/operations/2"⟩, 0, "metric-align", 0, event1799_0_read0_before, event1799_0_read0_after⟩
theorem event1799_0_read0_selected_pair : selectedSlotPair event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program event1799_0_refs [event1799_0_read0_pair] event1799_0_read0_pair.key event1799_0_sourceUses event1799_0_targetUses event1799_0_read0_before event1799_0_read0_after = some event1799_0_route := by decide +kernel

theorem event1799_0_read0_cross_pair_rejected : selectedSlotPair event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program event1799_0_refs [event1799_0_read0_pair] event1799_0_read0_pair.key event1799_0_sourceUses event1799_0_targetUses event1799_0_read0_before {event1799_0_read0_after with nodePath := "root/forged-sibling"} = none := by decide +kernel

theorem event1799_0_read0_typed_target (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead event1799_0_route event1799_0_left_p1_b0).map (typedRead Value valuation) = some ⟨event1799_0_right_p1_b0.origin.exactType, valuation event1799_0_right_p1_b0⟩ :=
  (typed_transport_sound event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program 0 event1799_0_sourceUses event1799_0_targetUses event1799_0_read0_before event1799_0_read0_after event1799_0_route (dependent_transport_exact event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program event1799_0_refs 0 event1799_0_sourceUses event1799_0_targetUses event1799_0_read0_before event1799_0_read0_after event1799_0_route event1799_0_read0_accepted).1 Value valuation).1

theorem event1799_0_read0_bad_type : typedSlotTransport event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program 0 event1799_0_sourceUses event1799_0_targetUses {event1799_0_read0_before with observedType := "FORGED"} event1799_0_read0_after = none := by decide +kernel

theorem event1799_0_read0_unpaid : typedSlotTransport event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program 1 event1799_0_sourceUses event1799_0_targetUses event1799_0_read0_before event1799_0_read0_after = none := by decide +kernel

theorem event1799_0_read0_dropped : typedSlotTransport event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program 0 event1799_0_sourceUses [] event1799_0_read0_before event1799_0_read0_after = none := by decide +kernel

theorem event1799_0_read0_forged_domain : typedSlotTransport event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program 0 event1799_0_sourceUses event1799_0_targetUses {event1799_0_read0_before with binding := {event1799_0_left_p1_b0 with origin := {event1799_0_left_p1_b0.origin with domain := "FORGED"}}} event1799_0_read0_after = none := by decide +kernel

theorem event1799_0_old_route_rejected : oldRoute (selectedBy [(2, 1), (3, 2), (4, 3)]) (countOf [(1, 1), (2, 1), (3, 1), (4, 1)]) (countOf [(1, 1), (2, 1), (3, 1)]) ((event1799_0_left.routes[2]?).getD []) ((event1799_0_right.routes[2]?).getD []) = false := by decide +kernel

/- Derived complete-store control over retained typed endpoints, not a claim
   that this two-operation program is the complete natural Java trace. -/
def sourceGuard : GuardToken := ⟨event1799_0_left_p1_b0, 1, "derived/guard"⟩
def targetGuard : GuardToken := ⟨event1799_0_right_p1_b0, 1, "derived/guard"⟩
def originalStore : Trace.Store (Fin 2) Payload := fun i => if i = 0 then some (.guard sourceGuard) else some (.read event1799_0_read0_before)
def finalStore : Trace.Store (Fin 2) Payload := fun i => if i = 0 then some (.guard targetGuard) else some (.read event1799_0_read0_after)
def selectedMatrix : List (Trace.Operation (Fin 2) Payload) := [⟨0, some (.guard sourceGuard), some (.guard targetGuard), 1⟩, readOperation 1 event1799_0_read0_before event1799_0_read0_after]
def selectedPrograms : SelectedPrograms 2 Payload := ⟨event1799_0_candidate.declarations, selectedMatrix, []⟩
def joint : ExecutableJoint 2 (List String) Payload := ⟨event1799_0_candidate, originalStore, finalStore, finalStore, selectedMatrix, [], 1, 0⟩
def selectedKeys : List Focused225SelectedConsumers.OperationKey := [⟨"495d0fc767e572d118d51781e9412bf76543cd7afb4f1a67d325b7c68e11779a", "/derived/guard"⟩, event1799_0_read0_pair.key]
def otherAuthenticUse : MatrixUse := {event1799_0_read0_after with nodePath := "root/other-issued-read"}
def crossedPair : Focused225SelectedConsumers.MatrixPair := {event1799_0_read0_pair with after := otherAuthenticUse}
def allTargetUses : List MatrixUse := [event1799_0_read0_after, otherAuthenticUse]
theorem derived_guard_replay_valid : guardedJointCheck event1799_0_tuple event1799_0_env selectedPrograms (fun _ _ => true) (fun _ => true) joint event1799_0_left.scopes event1799_0_right.scopes [sourceGuard] [targetGuard] 0 0 sourceGuard targetGuard = true := by decide +kernel

theorem derived_selected_read_and_guard_accept : selectedRepairCheck event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program event1799_0_refs [event1799_0_read0_pair] event1799_0_read0_pair event1799_0_sourceUses allTargetUses event1799_0_route selectedPrograms selectedKeys 1 1 (fun _ _ => true) (fun _ => true) joint [sourceGuard] [targetGuard] 0 0 sourceGuard targetGuard = true := by decide +kernel

theorem derived_authentic_cross_pair_in_isolation : selectedSlotPair event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program event1799_0_refs [crossedPair] crossedPair.key event1799_0_sourceUses allTargetUses crossedPair.before crossedPair.after = some event1799_0_route := by decide +kernel

theorem derived_unselected_read_with_valid_guard_rejected : guardedJointCheck event1799_0_tuple event1799_0_env selectedPrograms (fun _ _ => true) (fun _ => true) joint event1799_0_left.scopes event1799_0_right.scopes [sourceGuard] [targetGuard] 0 0 sourceGuard targetGuard = true ∧ selectedRepairCheck event1799_0_tuple event1799_0_left event1799_0_right event1799_0_program event1799_0_refs [crossedPair] crossedPair event1799_0_sourceUses allTargetUses event1799_0_route selectedPrograms selectedKeys 1 1 (fun _ _ => true) (fun _ => true) joint [sourceGuard] [targetGuard] 0 0 sourceGuard targetGuard = false := by decide +kernel

def event1799_1_left_p1_b0 : Binding := {
  origin := ⟨"2fdc8d77a108dd87eb61656f5bb5cfa245d67abf8d225ea65d198bf4c55aaea8", "inv12c", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "SOME", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1799_1_left : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [3, 0], owned := [], imports := [] }, { phase := 1, path := [3, 0, 2, 0], owned := [event1799_1_left_p1_b0], imports := [] }, { phase := 2, path := [3, 0, 2, 0, 1, 0], owned := [], imports := [event1799_1_left_p1_b0] }], [[⟨3, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 0, -1⟩]]⟩

def event1799_1_right_p1_b0 : Binding := {
  origin := ⟨"2fdc8d77a108dd87eb61656f5bb5cfa245d67abf8d225ea65d198bf4c55aaea8", "inv12", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1799_1_right : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [4, 0], owned := [], imports := [] }, { phase := 1, path := [4, 0, 3, 0], owned := [event1799_1_right_p1_b0], imports := [] }, { phase := 2, path := [4, 0, 3, 0, 1, 0], owned := [], imports := [event1799_1_right_p1_b0] }, { phase := 3, path := [4, 0, 3, 0, 2, 0], owned := [], imports := [event1799_1_right_p1_b0] }], [[⟨4, 0, -1⟩], [⟨4, 0, 0⟩, ⟨3, 0, -1⟩], [⟨4, 0, 0⟩, ⟨3, 0, 0⟩, ⟨1, 0, -1⟩], [⟨4, 0, 0⟩, ⟨3, 0, 1⟩, ⟨2, 0, -1⟩]]⟩

def event1799_1_refs : DependencyInventory := ⟨[(event1799_1_left_p1_b0, [])], [(event1799_1_right_p1_b0, [])]⟩
def event1799_1_tuple (b : Binding) : List String := (([(event1799_1_left_p1_b0, ["SOME", "File", "ONE", "0"]), (event1799_1_right_p1_b0, ["ALL", "File", "ONE", "0"])].find? (fun p => p.1 == b)).map Prod.snd).getD []
def event1799_1_env : Environment := ⟨[event1799_1_left_p1_b0], [event1799_1_right_p1_b0]⟩
def event1799_1_candidate : JointCandidate (List String) := ⟨[⟨0, ["SOME", "File", "ONE", "0"]⟩], [⟨0, ["ALL", "File", "ONE", "0"]⟩], [⟨.update, 1, some 0, some 0⟩], [], [], []⟩
def event1799_1_program : OwnerProgram := ⟨1, 1, event1799_1_env, event1799_1_candidate⟩
def event1799_1_route : TypedRoute := ⟨⟨.update, 1, some 0, some 0, some ["SOME", "File", "ONE", "0"], some ["ALL", "File", "ONE", "0"]⟩, some event1799_1_left_p1_b0, some event1799_1_right_p1_b0⟩

theorem event1799_1_owner_program : ownerProgramCheck event1799_1_tuple event1799_1_left.scopes event1799_1_right.scopes event1799_1_program = true := by decide +kernel

def event1799_1_read0_before : MatrixUse := ⟨event1799_1_left_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[0]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1799_1_read0_after : MatrixUse := ⟨event1799_1_right_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[1]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1799_1_sourceUses := [event1799_1_read0_before]
def event1799_1_targetUses := [event1799_1_read0_after]

theorem event1799_1_read0_accepted : dependentSlotTransport event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program event1799_1_refs 0 event1799_1_sourceUses event1799_1_targetUses event1799_1_read0_before event1799_1_read0_after = some event1799_1_route := by decide +kernel

def event1799_1_read0_pair : Focused225SelectedConsumers.MatrixPair := ⟨⟨"198a875d7bf1bef751b8b85a3a9bdc5ccd3d32f215e0ea6e552052da07c023c6", "/fast/phases/2/program/operations/2"⟩, 0, "metric-align", 0, event1799_1_read0_before, event1799_1_read0_after⟩
theorem event1799_1_read0_selected_pair : selectedSlotPair event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program event1799_1_refs [event1799_1_read0_pair] event1799_1_read0_pair.key event1799_1_sourceUses event1799_1_targetUses event1799_1_read0_before event1799_1_read0_after = some event1799_1_route := by decide +kernel

theorem event1799_1_read0_cross_pair_rejected : selectedSlotPair event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program event1799_1_refs [event1799_1_read0_pair] event1799_1_read0_pair.key event1799_1_sourceUses event1799_1_targetUses event1799_1_read0_before {event1799_1_read0_after with nodePath := "root/forged-sibling"} = none := by decide +kernel

theorem event1799_1_read0_typed_target (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead event1799_1_route event1799_1_left_p1_b0).map (typedRead Value valuation) = some ⟨event1799_1_right_p1_b0.origin.exactType, valuation event1799_1_right_p1_b0⟩ :=
  (typed_transport_sound event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program 0 event1799_1_sourceUses event1799_1_targetUses event1799_1_read0_before event1799_1_read0_after event1799_1_route (dependent_transport_exact event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program event1799_1_refs 0 event1799_1_sourceUses event1799_1_targetUses event1799_1_read0_before event1799_1_read0_after event1799_1_route event1799_1_read0_accepted).1 Value valuation).1

theorem event1799_1_read0_bad_type : typedSlotTransport event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program 0 event1799_1_sourceUses event1799_1_targetUses {event1799_1_read0_before with observedType := "FORGED"} event1799_1_read0_after = none := by decide +kernel

theorem event1799_1_read0_unpaid : typedSlotTransport event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program 1 event1799_1_sourceUses event1799_1_targetUses event1799_1_read0_before event1799_1_read0_after = none := by decide +kernel

theorem event1799_1_read0_dropped : typedSlotTransport event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program 0 event1799_1_sourceUses [] event1799_1_read0_before event1799_1_read0_after = none := by decide +kernel

theorem event1799_1_read0_forged_domain : typedSlotTransport event1799_1_tuple event1799_1_left event1799_1_right event1799_1_program 0 event1799_1_sourceUses event1799_1_targetUses {event1799_1_read0_before with binding := {event1799_1_left_p1_b0 with origin := {event1799_1_left_p1_b0.origin with domain := "FORGED"}}} event1799_1_read0_after = none := by decide +kernel

theorem event1799_1_old_route_rejected : oldRoute (selectedBy [(1, 2), (2, 3), (3, 4)]) (countOf [(1, 1), (2, 1), (3, 1)]) (countOf [(1, 1), (2, 1), (3, 1), (4, 1)]) ((event1799_1_left.routes[2]?).getD []) ((event1799_1_right.routes[2]?).getD []) = false := by decide +kernel

def event1811_0_left_p1_b0 : Binding := {
  origin := ⟨"0895a15625043516e91dad21992ddc86cba920608ca8503803cb6c29ff10227f", "inv12", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1811_0_left : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [3, 0], owned := [], imports := [] }, { phase := 1, path := [3, 0, 2, 0], owned := [event1811_0_left_p1_b0], imports := [] }, { phase := 2, path := [3, 0, 2, 0, 1, 0], owned := [], imports := [event1811_0_left_p1_b0] }, { phase := 3, path := [3, 0, 2, 0, 1, 1], owned := [], imports := [event1811_0_left_p1_b0] }], [[⟨3, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 1, -1⟩]]⟩

def event1811_0_right_p1_b0 : Binding := {
  origin := ⟨"0895a15625043516e91dad21992ddc86cba920608ca8503803cb6c29ff10227f", "inv12c", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "SOME", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1811_0_right : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [3, 0], owned := [], imports := [] }, { phase := 1, path := [3, 0, 2, 0], owned := [event1811_0_right_p1_b0], imports := [] }, { phase := 2, path := [3, 0, 2, 0, 1, 0], owned := [], imports := [event1811_0_right_p1_b0] }], [[⟨3, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 0, -1⟩]]⟩

def event1811_0_refs : DependencyInventory := ⟨[(event1811_0_left_p1_b0, [])], [(event1811_0_right_p1_b0, [])]⟩
def event1811_0_tuple (b : Binding) : List String := (([(event1811_0_left_p1_b0, ["ALL", "File", "ONE", "0"]), (event1811_0_right_p1_b0, ["SOME", "File", "ONE", "0"])].find? (fun p => p.1 == b)).map Prod.snd).getD []
def event1811_0_env : Environment := ⟨[event1811_0_left_p1_b0], [event1811_0_right_p1_b0]⟩
def event1811_0_candidate : JointCandidate (List String) := ⟨[⟨0, ["ALL", "File", "ONE", "0"]⟩], [⟨0, ["SOME", "File", "ONE", "0"]⟩], [⟨.update, 1, some 0, some 0⟩], [], [], []⟩
def event1811_0_program : OwnerProgram := ⟨1, 1, event1811_0_env, event1811_0_candidate⟩
def event1811_0_route : TypedRoute := ⟨⟨.update, 1, some 0, some 0, some ["ALL", "File", "ONE", "0"], some ["SOME", "File", "ONE", "0"]⟩, some event1811_0_left_p1_b0, some event1811_0_right_p1_b0⟩

theorem event1811_0_owner_program : ownerProgramCheck event1811_0_tuple event1811_0_left.scopes event1811_0_right.scopes event1811_0_program = true := by decide +kernel

def event1811_0_read0_before : MatrixUse := ⟨event1811_0_left_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[0]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1811_0_read0_after : MatrixUse := ⟨event1811_0_right_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[0]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1811_0_sourceUses := [event1811_0_read0_before]
def event1811_0_targetUses := [event1811_0_read0_after]

theorem event1811_0_read0_accepted : dependentSlotTransport event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program event1811_0_refs 0 event1811_0_sourceUses event1811_0_targetUses event1811_0_read0_before event1811_0_read0_after = some event1811_0_route := by decide +kernel

def event1811_0_read0_pair : Focused225SelectedConsumers.MatrixPair := ⟨⟨"d67d76db26c681e0a542a2edb5f64fab1805ffc4ec343519e3bf525425d53441", "/fast/phases/2/program/operations/2"⟩, 0, "metric-align", 0, event1811_0_read0_before, event1811_0_read0_after⟩
theorem event1811_0_read0_selected_pair : selectedSlotPair event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program event1811_0_refs [event1811_0_read0_pair] event1811_0_read0_pair.key event1811_0_sourceUses event1811_0_targetUses event1811_0_read0_before event1811_0_read0_after = some event1811_0_route := by decide +kernel

theorem event1811_0_read0_cross_pair_rejected : selectedSlotPair event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program event1811_0_refs [event1811_0_read0_pair] event1811_0_read0_pair.key event1811_0_sourceUses event1811_0_targetUses event1811_0_read0_before {event1811_0_read0_after with nodePath := "root/forged-sibling"} = none := by decide +kernel

theorem event1811_0_read0_typed_target (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead event1811_0_route event1811_0_left_p1_b0).map (typedRead Value valuation) = some ⟨event1811_0_right_p1_b0.origin.exactType, valuation event1811_0_right_p1_b0⟩ :=
  (typed_transport_sound event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program 0 event1811_0_sourceUses event1811_0_targetUses event1811_0_read0_before event1811_0_read0_after event1811_0_route (dependent_transport_exact event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program event1811_0_refs 0 event1811_0_sourceUses event1811_0_targetUses event1811_0_read0_before event1811_0_read0_after event1811_0_route event1811_0_read0_accepted).1 Value valuation).1

theorem event1811_0_read0_bad_type : typedSlotTransport event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program 0 event1811_0_sourceUses event1811_0_targetUses {event1811_0_read0_before with observedType := "FORGED"} event1811_0_read0_after = none := by decide +kernel

theorem event1811_0_read0_unpaid : typedSlotTransport event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program 1 event1811_0_sourceUses event1811_0_targetUses event1811_0_read0_before event1811_0_read0_after = none := by decide +kernel

theorem event1811_0_read0_dropped : typedSlotTransport event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program 0 event1811_0_sourceUses [] event1811_0_read0_before event1811_0_read0_after = none := by decide +kernel

theorem event1811_0_read0_forged_domain : typedSlotTransport event1811_0_tuple event1811_0_left event1811_0_right event1811_0_program 0 event1811_0_sourceUses event1811_0_targetUses {event1811_0_read0_before with binding := {event1811_0_left_p1_b0 with origin := {event1811_0_left_p1_b0.origin with domain := "FORGED"}}} event1811_0_read0_after = none := by decide +kernel

theorem event1811_0_old_route_rejected : oldRoute (selectedBy [(1, 1), (2, 2), (3, 3)]) (countOf [(1, 2), (2, 1), (3, 1)]) (countOf [(1, 1), (2, 1), (3, 1)]) ((event1811_0_left.routes[2]?).getD []) ((event1811_0_right.routes[2]?).getD []) = false := by decide +kernel

def event1811_1_left_p1_b0 : Binding := {
  origin := ⟨"0895a15625043516e91dad21992ddc86cba920608ca8503803cb6c29ff10227f", "inv12c", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "SOME", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1811_1_left : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [3, 0], owned := [], imports := [] }, { phase := 1, path := [3, 0, 2, 0], owned := [event1811_1_left_p1_b0], imports := [] }, { phase := 2, path := [3, 0, 2, 0, 1, 0], owned := [], imports := [event1811_1_left_p1_b0] }], [[⟨3, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 0, -1⟩]]⟩

def event1811_1_right_p1_b0 : Binding := {
  origin := ⟨"0895a15625043516e91dad21992ddc86cba920608ca8503803cb6c29ff10227f", "inv12", "var/scope:2/slot:0", "root/temporalroot[0]/decl[0]@pos", 1, "matrix", [], [], "RELATION[4:File]", "13:GLOBALBINDING[3:20:alloy/signature/File16:RELATION[4:File]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1811_1_right : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [3, 0], owned := [], imports := [] }, { phase := 1, path := [3, 0, 2, 0], owned := [event1811_1_right_p1_b0], imports := [] }, { phase := 2, path := [3, 0, 2, 0, 1, 0], owned := [], imports := [event1811_1_right_p1_b0] }, { phase := 3, path := [3, 0, 2, 0, 1, 1], owned := [], imports := [event1811_1_right_p1_b0] }], [[⟨3, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 0, -1⟩], [⟨3, 0, 0⟩, ⟨2, 0, 0⟩, ⟨1, 1, -1⟩]]⟩

def event1811_1_refs : DependencyInventory := ⟨[(event1811_1_left_p1_b0, [])], [(event1811_1_right_p1_b0, [])]⟩
def event1811_1_tuple (b : Binding) : List String := (([(event1811_1_left_p1_b0, ["SOME", "File", "ONE", "0"]), (event1811_1_right_p1_b0, ["ALL", "File", "ONE", "0"])].find? (fun p => p.1 == b)).map Prod.snd).getD []
def event1811_1_env : Environment := ⟨[event1811_1_left_p1_b0], [event1811_1_right_p1_b0]⟩
def event1811_1_candidate : JointCandidate (List String) := ⟨[⟨0, ["SOME", "File", "ONE", "0"]⟩], [⟨0, ["ALL", "File", "ONE", "0"]⟩], [⟨.update, 1, some 0, some 0⟩], [], [], []⟩
def event1811_1_program : OwnerProgram := ⟨1, 1, event1811_1_env, event1811_1_candidate⟩
def event1811_1_route : TypedRoute := ⟨⟨.update, 1, some 0, some 0, some ["SOME", "File", "ONE", "0"], some ["ALL", "File", "ONE", "0"]⟩, some event1811_1_left_p1_b0, some event1811_1_right_p1_b0⟩

theorem event1811_1_owner_program : ownerProgramCheck event1811_1_tuple event1811_1_left.scopes event1811_1_right.scopes event1811_1_program = true := by decide +kernel

def event1811_1_read0_before : MatrixUse := ⟨event1811_1_left_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[0]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1811_1_read0_after : MatrixUse := ⟨event1811_1_right_p1_b0, 2, "VARIABLE", "phase[0]/temporal[0]/temporal[0]", "root/child/0/child/0", "RELATION[4:File]", "var/scope:2/slot:0"⟩
def event1811_1_sourceUses := [event1811_1_read0_before]
def event1811_1_targetUses := [event1811_1_read0_after]

theorem event1811_1_read0_accepted : dependentSlotTransport event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program event1811_1_refs 0 event1811_1_sourceUses event1811_1_targetUses event1811_1_read0_before event1811_1_read0_after = some event1811_1_route := by decide +kernel

def event1811_1_read0_pair : Focused225SelectedConsumers.MatrixPair := ⟨⟨"87e1e5ed967364d7e0687410961ab6cec5f9931229766280c5fd7505ead297bf", "/fast/phases/2/program/operations/2"⟩, 0, "metric-align", 0, event1811_1_read0_before, event1811_1_read0_after⟩
theorem event1811_1_read0_selected_pair : selectedSlotPair event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program event1811_1_refs [event1811_1_read0_pair] event1811_1_read0_pair.key event1811_1_sourceUses event1811_1_targetUses event1811_1_read0_before event1811_1_read0_after = some event1811_1_route := by decide +kernel

theorem event1811_1_read0_cross_pair_rejected : selectedSlotPair event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program event1811_1_refs [event1811_1_read0_pair] event1811_1_read0_pair.key event1811_1_sourceUses event1811_1_targetUses event1811_1_read0_before {event1811_1_read0_after with nodePath := "root/forged-sibling"} = none := by decide +kernel

theorem event1811_1_read0_typed_target (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead event1811_1_route event1811_1_left_p1_b0).map (typedRead Value valuation) = some ⟨event1811_1_right_p1_b0.origin.exactType, valuation event1811_1_right_p1_b0⟩ :=
  (typed_transport_sound event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program 0 event1811_1_sourceUses event1811_1_targetUses event1811_1_read0_before event1811_1_read0_after event1811_1_route (dependent_transport_exact event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program event1811_1_refs 0 event1811_1_sourceUses event1811_1_targetUses event1811_1_read0_before event1811_1_read0_after event1811_1_route event1811_1_read0_accepted).1 Value valuation).1

theorem event1811_1_read0_bad_type : typedSlotTransport event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program 0 event1811_1_sourceUses event1811_1_targetUses {event1811_1_read0_before with observedType := "FORGED"} event1811_1_read0_after = none := by decide +kernel

theorem event1811_1_read0_unpaid : typedSlotTransport event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program 1 event1811_1_sourceUses event1811_1_targetUses event1811_1_read0_before event1811_1_read0_after = none := by decide +kernel

theorem event1811_1_read0_dropped : typedSlotTransport event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program 0 event1811_1_sourceUses [] event1811_1_read0_before event1811_1_read0_after = none := by decide +kernel

theorem event1811_1_read0_forged_domain : typedSlotTransport event1811_1_tuple event1811_1_left event1811_1_right event1811_1_program 0 event1811_1_sourceUses event1811_1_targetUses {event1811_1_read0_before with binding := {event1811_1_left_p1_b0 with origin := {event1811_1_left_p1_b0.origin with domain := "FORGED"}}} event1811_1_read0_after = none := by decide +kernel

theorem event1811_1_old_route_rejected : oldRoute (selectedBy [(1, 1), (2, 2), (3, 3)]) (countOf [(1, 1), (2, 1), (3, 1)]) (countOf [(1, 2), (2, 1), (3, 1)]) ((event1811_1_left.routes[2]?).getD []) ((event1811_1_right.routes[2]?).getD []) = false := by decide +kernel

def event1508_0_left_p0_b0 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4", "var/scope:2/slot:0", "root/predicate[0]/decl[0]@pos", 0, "matrix", [], [], "RELATION[9:Component]", "13:GLOBALBINDING[3:25:alloy/signature/Component21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1508_0_left_p0_b1 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4", "var/scope:3/slot:0", "root/predicate[0]/body[1]/decl[0]@pos", 0, "matrix", [], [0], "RELATION[7:Product]", "4:JOIN[3:12:BOPEXPR_JOIN19:RELATION[7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:124:8:VARIABLE[3:12:dependency/021:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}131:13:GLOBALBINDING[3:5:parts30:RELATION[9:Component7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}", "ALL", "ONE", 0⟩
  vectorIndex := 1, coordinate := 1, ordinal := 1 }

def event1508_0_left : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [1, 0], owned := [event1508_0_left_p0_b0, event1508_0_left_p0_b1], imports := [] }], [[⟨1, 0, -1⟩]]⟩

def event1508_0_right_p0_b0 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4c", "var/scope:2/slot:0", "root/predicate[0]/decl[0]@pos", 0, "matrix", [], [], "RELATION[9:Component]", "13:GLOBALBINDING[3:25:alloy/signature/Component21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1508_0_right_p0_b1 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4c", "var/scope:2/slot:1", "root/predicate[0]/decl[1]@pos", 0, "matrix", [], [0], "RELATION[9:Component]", "9:INTERSECT[3:17:BOPEXPR_INTERSECT21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:381:4:JOIN[3:12:BOPEXPR_JOIN19:RELATION[7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:124:8:VARIABLE[3:12:dependency/021:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}131:13:GLOBALBINDING[3:5:parts30:RELATION[9:Component7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}143:13:GLOBALBINDING[3:25:alloy/signature/Component21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}", "ALL", "ONE", 0⟩
  vectorIndex := 1, coordinate := 1, ordinal := 1 }

def event1508_0_right : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [1, 0], owned := [event1508_0_right_p0_b0, event1508_0_right_p0_b1], imports := [] }], [[⟨1, 0, -1⟩]]⟩

def event1508_0_refs : DependencyInventory := ⟨[(event1508_0_left_p0_b0, []), (event1508_0_left_p0_b1, [event1508_0_left_p0_b0])], [(event1508_0_right_p0_b0, []), (event1508_0_right_p0_b1, [event1508_0_right_p0_b0])]⟩
def event1508_0_tuple (b : Binding) : List String := (([(event1508_0_left_p0_b0, ["ALL", "Component", "ONE", "0"]), (event1508_0_left_p0_b1, ["ALL", "Product", "ONE", "0"]), (event1508_0_right_p0_b0, ["ALL", "Component", "ONE", "0"]), (event1508_0_right_p0_b1, ["ALL", "Component", "ONE", "0"])].find? (fun p => p.1 == b)).map Prod.snd).getD []
def event1508_0_env : Environment := ⟨[event1508_0_left_p0_b0, event1508_0_left_p0_b1], [event1508_0_right_p0_b0, event1508_0_right_p0_b1]⟩
def event1508_0_candidate : JointCandidate (List String) := ⟨[⟨0, ["ALL", "Component", "ONE", "0"]⟩, ⟨1, ["ALL", "Product", "ONE", "0"]⟩], [⟨0, ["ALL", "Component", "ONE", "0"]⟩, ⟨1, ["ALL", "Component", "ONE", "0"]⟩], [⟨.keep, 0, some 0, some 0⟩, ⟨.update, 1, some 1, some 1⟩], [], [], []⟩
def event1508_0_program : OwnerProgram := ⟨0, 0, event1508_0_env, event1508_0_candidate⟩
def event1508_0_route : TypedRoute := ⟨⟨.update, 1, some 1, some 1, some ["ALL", "Product", "ONE", "0"], some ["ALL", "Component", "ONE", "0"]⟩, some event1508_0_left_p0_b1, some event1508_0_right_p0_b1⟩

theorem event1508_0_owner_program : ownerProgramCheck event1508_0_tuple event1508_0_left.scopes event1508_0_right.scopes event1508_0_program = true := by decide +kernel

def event1508_0_read0_before : MatrixUse := ⟨event1508_0_left_p0_b1, 0, "VARIABLE", "phase[0]", "root/child/0/child/1/child/0", "RELATION[7:Product]", "var/scope:3/slot:0"⟩
def event1508_0_read0_after : MatrixUse := ⟨event1508_0_right_p0_b1, 0, "VARIABLE", "phase[0]", "root/child/0/child/1/child/0", "RELATION[9:Component]", "var/scope:2/slot:1"⟩
def event1508_0_sourceUses := [event1508_0_read0_before]
def event1508_0_targetUses := [event1508_0_read0_after]

theorem event1508_0_read0_accepted : dependentSlotTransport event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program event1508_0_refs 1 event1508_0_sourceUses event1508_0_targetUses event1508_0_read0_before event1508_0_read0_after = some event1508_0_route := by decide +kernel

def event1508_0_read0_pair : Focused225SelectedConsumers.MatrixPair := ⟨⟨"10ac57b9c3aad1e999deeac1fc38f51e617a5bf9d3d1d598c41af1ab69017484", "/fast/phases/0/program/operations/23"⟩, 1, "metric-align", 0, event1508_0_read0_before, event1508_0_read0_after⟩
theorem event1508_0_read0_selected_pair : selectedSlotPair event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program event1508_0_refs [event1508_0_read0_pair] event1508_0_read0_pair.key event1508_0_sourceUses event1508_0_targetUses event1508_0_read0_before event1508_0_read0_after = some event1508_0_route := by decide +kernel

theorem event1508_0_read0_cross_pair_rejected : selectedSlotPair event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program event1508_0_refs [event1508_0_read0_pair] event1508_0_read0_pair.key event1508_0_sourceUses event1508_0_targetUses event1508_0_read0_before {event1508_0_read0_after with nodePath := "root/forged-sibling"} = none := by decide +kernel

theorem event1508_0_read0_typed_target (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead event1508_0_route event1508_0_left_p0_b1).map (typedRead Value valuation) = some ⟨event1508_0_right_p0_b1.origin.exactType, valuation event1508_0_right_p0_b1⟩ :=
  (typed_transport_sound event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program 1 event1508_0_sourceUses event1508_0_targetUses event1508_0_read0_before event1508_0_read0_after event1508_0_route (dependent_transport_exact event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program event1508_0_refs 1 event1508_0_sourceUses event1508_0_targetUses event1508_0_read0_before event1508_0_read0_after event1508_0_route event1508_0_read0_accepted).1 Value valuation).1

theorem event1508_0_read0_bad_type : typedSlotTransport event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program 1 event1508_0_sourceUses event1508_0_targetUses {event1508_0_read0_before with observedType := "FORGED"} event1508_0_read0_after = none := by decide +kernel

theorem event1508_0_read0_unpaid : typedSlotTransport event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program 2 event1508_0_sourceUses event1508_0_targetUses event1508_0_read0_before event1508_0_read0_after = none := by decide +kernel

theorem event1508_0_read0_dropped : typedSlotTransport event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program 1 event1508_0_sourceUses [] event1508_0_read0_before event1508_0_read0_after = none := by decide +kernel

theorem event1508_0_read0_forged_domain : typedSlotTransport event1508_0_tuple event1508_0_left event1508_0_right event1508_0_program 1 event1508_0_sourceUses event1508_0_targetUses {event1508_0_read0_before with binding := {event1508_0_left_p0_b1 with origin := {event1508_0_left_p0_b1.origin with domain := "FORGED"}}} event1508_0_read0_after = none := by decide +kernel

theorem event1508_0_old_tuple_rejected : oldPaidImportGate event1508_0_left_p0_b1 event1508_0_right_p0_b1 true = false := by decide +kernel

theorem event1508_0_domains_differ : event1508_0_left_p0_b1.origin.domain ≠ event1508_0_right_p0_b1.origin.domain := by decide +kernel

theorem event1508_0_types_differ : event1508_0_left_p0_b1.origin.exactType ≠ event1508_0_right_p0_b1.origin.exactType := by decide +kernel

def event1508_0_foreignRefs : DependencyInventory := {event1508_0_refs with source := event1508_0_refs.source.map (fun (binding, deps) => (binding, deps.map (fun dep => {dep with origin := {dep.origin with phase := dep.origin.phase + 1}})))}
theorem event1508_0_coowned_dependencies : authenticatedDependencies event1508_0_program event1508_0_refs event1508_0_left_p0_b1 event1508_0_right_p0_b1 = true := by decide +kernel

theorem event1508_0_numeric_collision_would_pass : dependencyTransport (links event1508_0_candidate.actions) event1508_0_left_p0_b1.origin.dependencies event1508_0_right_p0_b1.origin.dependencies = true := by decide +kernel

theorem event1508_0_foreign_owner_same_ordinal_rejected : authenticatedDependencies event1508_0_program event1508_0_foreignRefs event1508_0_left_p0_b1 event1508_0_right_p0_b1 = false := by decide +kernel

def event1508_1_left_p0_b0 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4c", "var/scope:2/slot:0", "root/predicate[0]/decl[0]@pos", 0, "matrix", [], [], "RELATION[9:Component]", "13:GLOBALBINDING[3:25:alloy/signature/Component21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1508_1_left_p0_b1 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4c", "var/scope:2/slot:1", "root/predicate[0]/decl[1]@pos", 0, "matrix", [], [0], "RELATION[9:Component]", "9:INTERSECT[3:17:BOPEXPR_INTERSECT21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:381:4:JOIN[3:12:BOPEXPR_JOIN19:RELATION[7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:124:8:VARIABLE[3:12:dependency/021:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}131:13:GLOBALBINDING[3:5:parts30:RELATION[9:Component7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}143:13:GLOBALBINDING[3:25:alloy/signature/Component21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}", "ALL", "ONE", 0⟩
  vectorIndex := 1, coordinate := 1, ordinal := 1 }

def event1508_1_left : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [1, 0], owned := [event1508_1_left_p0_b0, event1508_1_left_p0_b1], imports := [] }], [[⟨1, 0, -1⟩]]⟩

def event1508_1_right_p0_b0 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4", "var/scope:2/slot:0", "root/predicate[0]/decl[0]@pos", 0, "matrix", [], [], "RELATION[9:Component]", "13:GLOBALBINDING[3:25:alloy/signature/Component21:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "ALL", "ONE", 0⟩
  vectorIndex := 0, coordinate := 0, ordinal := 0 }

def event1508_1_right_p0_b1 : Binding := {
  origin := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", "inv4", "var/scope:3/slot:0", "root/predicate[0]/body[1]/decl[0]@pos", 0, "matrix", [], [0], "RELATION[7:Product]", "4:JOIN[3:12:BOPEXPR_JOIN19:RELATION[7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:124:8:VARIABLE[3:12:dependency/021:RELATION[9:Component]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}131:13:GLOBALBINDING[3:5:parts30:RELATION[9:Component7:Product]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}", "ALL", "ONE", 0⟩
  vectorIndex := 1, coordinate := 1, ordinal := 1 }

def event1508_1_right : SelectedSlotTransport.Endpoint := ⟨[{ phase := 0, path := [1, 0], owned := [event1508_1_right_p0_b0, event1508_1_right_p0_b1], imports := [] }], [[⟨1, 0, -1⟩]]⟩

def event1508_1_refs : DependencyInventory := ⟨[(event1508_1_left_p0_b0, []), (event1508_1_left_p0_b1, [event1508_1_left_p0_b0])], [(event1508_1_right_p0_b0, []), (event1508_1_right_p0_b1, [event1508_1_right_p0_b0])]⟩
def event1508_1_tuple (b : Binding) : List String := (([(event1508_1_left_p0_b0, ["ALL", "Component", "ONE", "0"]), (event1508_1_left_p0_b1, ["ALL", "Component", "ONE", "0"]), (event1508_1_right_p0_b0, ["ALL", "Component", "ONE", "0"]), (event1508_1_right_p0_b1, ["ALL", "Product", "ONE", "0"])].find? (fun p => p.1 == b)).map Prod.snd).getD []
def event1508_1_env : Environment := ⟨[event1508_1_left_p0_b0, event1508_1_left_p0_b1], [event1508_1_right_p0_b0, event1508_1_right_p0_b1]⟩
def event1508_1_candidate : JointCandidate (List String) := ⟨[⟨0, ["ALL", "Component", "ONE", "0"]⟩, ⟨1, ["ALL", "Component", "ONE", "0"]⟩], [⟨0, ["ALL", "Component", "ONE", "0"]⟩, ⟨1, ["ALL", "Product", "ONE", "0"]⟩], [⟨.keep, 0, some 0, some 0⟩, ⟨.update, 1, some 1, some 1⟩], [], [], []⟩
def event1508_1_program : OwnerProgram := ⟨0, 0, event1508_1_env, event1508_1_candidate⟩
def event1508_1_route : TypedRoute := ⟨⟨.update, 1, some 1, some 1, some ["ALL", "Component", "ONE", "0"], some ["ALL", "Product", "ONE", "0"]⟩, some event1508_1_left_p0_b1, some event1508_1_right_p0_b1⟩

theorem event1508_1_owner_program : ownerProgramCheck event1508_1_tuple event1508_1_left.scopes event1508_1_right.scopes event1508_1_program = true := by decide +kernel

def event1508_1_read0_before : MatrixUse := ⟨event1508_1_left_p0_b1, 0, "VARIABLE", "phase[0]", "root/child/0/child/1/child/0", "RELATION[9:Component]", "var/scope:2/slot:1"⟩
def event1508_1_read0_after : MatrixUse := ⟨event1508_1_right_p0_b1, 0, "VARIABLE", "phase[0]", "root/child/0/child/1/child/0", "RELATION[7:Product]", "var/scope:3/slot:0"⟩
def event1508_1_sourceUses := [event1508_1_read0_before]
def event1508_1_targetUses := [event1508_1_read0_after]

theorem event1508_1_read0_accepted : dependentSlotTransport event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program event1508_1_refs 1 event1508_1_sourceUses event1508_1_targetUses event1508_1_read0_before event1508_1_read0_after = some event1508_1_route := by decide +kernel

def event1508_1_read0_pair : Focused225SelectedConsumers.MatrixPair := ⟨⟨"2a81793a6115bcd5d31e7ea0e869a74c0c40e6c1ca8393aeb6e99ef9fad5d0d2", "/fast/phases/0/program/operations/23"⟩, 1, "metric-align", 0, event1508_1_read0_before, event1508_1_read0_after⟩
theorem event1508_1_read0_selected_pair : selectedSlotPair event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program event1508_1_refs [event1508_1_read0_pair] event1508_1_read0_pair.key event1508_1_sourceUses event1508_1_targetUses event1508_1_read0_before event1508_1_read0_after = some event1508_1_route := by decide +kernel

theorem event1508_1_read0_cross_pair_rejected : selectedSlotPair event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program event1508_1_refs [event1508_1_read0_pair] event1508_1_read0_pair.key event1508_1_sourceUses event1508_1_targetUses event1508_1_read0_before {event1508_1_read0_after with nodePath := "root/forged-sibling"} = none := by decide +kernel

theorem event1508_1_read0_typed_target (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead event1508_1_route event1508_1_left_p0_b1).map (typedRead Value valuation) = some ⟨event1508_1_right_p0_b1.origin.exactType, valuation event1508_1_right_p0_b1⟩ :=
  (typed_transport_sound event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program 1 event1508_1_sourceUses event1508_1_targetUses event1508_1_read0_before event1508_1_read0_after event1508_1_route (dependent_transport_exact event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program event1508_1_refs 1 event1508_1_sourceUses event1508_1_targetUses event1508_1_read0_before event1508_1_read0_after event1508_1_route event1508_1_read0_accepted).1 Value valuation).1

theorem event1508_1_read0_bad_type : typedSlotTransport event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program 1 event1508_1_sourceUses event1508_1_targetUses {event1508_1_read0_before with observedType := "FORGED"} event1508_1_read0_after = none := by decide +kernel

theorem event1508_1_read0_unpaid : typedSlotTransport event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program 2 event1508_1_sourceUses event1508_1_targetUses event1508_1_read0_before event1508_1_read0_after = none := by decide +kernel

theorem event1508_1_read0_dropped : typedSlotTransport event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program 1 event1508_1_sourceUses [] event1508_1_read0_before event1508_1_read0_after = none := by decide +kernel

theorem event1508_1_read0_forged_domain : typedSlotTransport event1508_1_tuple event1508_1_left event1508_1_right event1508_1_program 1 event1508_1_sourceUses event1508_1_targetUses {event1508_1_read0_before with binding := {event1508_1_left_p0_b1 with origin := {event1508_1_left_p0_b1.origin with domain := "FORGED"}}} event1508_1_read0_after = none := by decide +kernel

theorem event1508_1_old_tuple_rejected : oldPaidImportGate event1508_1_left_p0_b1 event1508_1_right_p0_b1 true = false := by decide +kernel

theorem event1508_1_domains_differ : event1508_1_left_p0_b1.origin.domain ≠ event1508_1_right_p0_b1.origin.domain := by decide +kernel

theorem event1508_1_types_differ : event1508_1_left_p0_b1.origin.exactType ≠ event1508_1_right_p0_b1.origin.exactType := by decide +kernel

def event1508_1_foreignRefs : DependencyInventory := {event1508_1_refs with source := event1508_1_refs.source.map (fun (binding, deps) => (binding, deps.map (fun dep => {dep with origin := {dep.origin with phase := dep.origin.phase + 1}})))}
theorem event1508_1_coowned_dependencies : authenticatedDependencies event1508_1_program event1508_1_refs event1508_1_left_p0_b1 event1508_1_right_p0_b1 = true := by decide +kernel

theorem event1508_1_numeric_collision_would_pass : dependencyTransport (links event1508_1_candidate.actions) event1508_1_left_p0_b1.origin.dependencies event1508_1_right_p0_b1.origin.dependencies = true := by decide +kernel

theorem event1508_1_foreign_owner_same_ordinal_rejected : authenticatedDependencies event1508_1_program event1508_1_foreignRefs event1508_1_left_p0_b1 event1508_1_right_p0_b1 = false := by decide +kernel

theorem ordered_dependencies_accepted : dependencyTransport [(3,7),(4,8)] [3,4] [7,8] = true := by decide
theorem reversed_dependencies_rejected : dependencyTransport [(3,7),(4,8)] [3,4] [8,7] = false := by decide
theorem dropped_dependency_rejected : dependencyTransport [(3,7),(4,8)] [3,4] [7] = false := by decide
end PaidSlotDomainWitnesses
