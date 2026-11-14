import PhaseOwnedJointRoutes
namespace PhaseOwnedSingleRoutes
open PhaseOwnedJointRoutes Focused225SharedContracts Focused225Concrete
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

def event154_0_source0 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3"
    occurrence := "7"
    owner := "root/predicate[0]/decl[0]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Work)"
    domain := "13:GLOBALBINDING[3:20:alloy/signature/Work16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def event154_0_source1 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3"
    occurrence := "8"
    owner := "root/predicate[0]/decl[0]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Work)"
    domain := "13:GLOBALBINDING[3:20:alloy/signature/Work16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 1
  coordinate := 1
  ordinal := 1
}

def event154_0_sourceScopes : List Scope := [{ phase := 0, path := [], owned := [event154_0_source0, event154_0_source1], imports := [] }, { phase := 1, path := [0], owned := [], imports := [event154_0_source0, event154_0_source1] }]

theorem event154_0_source0_owner : resolveBinding event154_0_sourceScopes 0 event154_0_source0 = some event154_0_source0 := by decide

theorem event154_0_source1_owner : resolveBinding event154_0_sourceScopes 0 event154_0_source1 = some event154_0_source1 := by decide

theorem event154_0_source0_import : resolveBinding event154_0_sourceScopes 1 event154_0_source0 = some event154_0_source0 := by decide

theorem event154_0_source0_no_rebinding : resolveBinding event154_0_sourceScopes 1 { event154_0_source0 with origin := { event154_0_source0.origin with phase := 1 } } = none := by decide

theorem event154_0_source1_import : resolveBinding event154_0_sourceScopes 1 event154_0_source1 = some event154_0_source1 := by decide

theorem event154_0_source1_no_rebinding : resolveBinding event154_0_sourceScopes 1 { event154_0_source1 with origin := { event154_0_source1.origin with phase := 1 } } = none := by decide

def event154_0_target0 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3c"
    occurrence := "292"
    owner := "root/predicate[0]/decl[0]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(User)"
    domain := "13:GLOBALBINDING[3:20:alloy/signature/User16:RELATION[4:User]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def event154_0_target1 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3c"
    occurrence := "299"
    owner := "root/predicate[0]/decl[1]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := [0]
    exactType := "AlloyCarrier(Work)"
    domain := "4:JOIN[3:12:BOPEXPR_JOIN16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:119:8:VARIABLE[3:12:dependency/016:RELATION[4:User]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}125:13:GLOBALBINDING[3:7:profile22:RELATION[4:User4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 1
  }
  vectorIndex := 1
  coordinate := 1
  ordinal := 1
}

def event154_0_target2 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3c"
    occurrence := "300"
    owner := "root/predicate[0]/decl[1]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := [0]
    exactType := "AlloyCarrier(Work)"
    domain := "4:JOIN[3:12:BOPEXPR_JOIN16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:119:8:VARIABLE[3:12:dependency/016:RELATION[4:User]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}125:13:GLOBALBINDING[3:7:profile22:RELATION[4:User4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 1
  }
  vectorIndex := 2
  coordinate := 2
  ordinal := 2
}

def event154_0_targetScopes : List Scope := [{ phase := 0, path := [], owned := [event154_0_target0, event154_0_target1, event154_0_target2], imports := [] }]

theorem event154_0_target0_owner : resolveBinding event154_0_targetScopes 0 event154_0_target0 = some event154_0_target0 := by decide

theorem event154_0_target1_owner : resolveBinding event154_0_targetScopes 0 event154_0_target1 = some event154_0_target1 := by decide

theorem event154_0_target2_owner : resolveBinding event154_0_targetScopes 0 event154_0_target2 = some event154_0_target2 := by decide

def event154_0Env : Environment := ⟨[event154_0_source0, event154_0_source1], [event154_0_target0, event154_0_target1, event154_0_target2]⟩
def event154_0Tuples : List (Binding × List String) := [(event154_0_source0, ["ALL", "Work", "ONE", "0"]), (event154_0_source1, ["ALL", "Work", "ONE", "0"]), (event154_0_target0, ["ALL", "User", "ONE", "0"]), (event154_0_target1, ["ALL", "Work", "ONE", "1"]), (event154_0_target2, ["ALL", "Work", "ONE", "1"])]
def event154_0Tuple (b : Binding) : List String := ((event154_0Tuples.find? (fun p => p.1 == b)).map Prod.snd).getD []

def event154_0Candidate : JointCandidate (List String) := {
  source := [⟨0, ["ALL", "Work", "ONE", "0"]⟩, ⟨1, ["ALL", "Work", "ONE", "0"]⟩]
  target := [⟨0, ["ALL", "User", "ONE", "0"]⟩, ⟨1, ["ALL", "Work", "ONE", "1"]⟩, ⟨2, ["ALL", "Work", "ONE", "1"]⟩]
  declarations := [⟨.insert, 1, none, some 0⟩, ⟨.update, 1, some 0, some 1⟩, ⟨.update, 1, some 1, some 2⟩]
  variableReads := []
  otherMatrixCharges := []
  temporalCharges := []
}
def event154_0Program : OwnerProgram := ⟨0, 0, event154_0Env, event154_0Candidate⟩

theorem event154_0_complete_owner_program : ownerProgramCheck event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program = true := by decide

def event154_0_route0 : TypedRoute := ⟨⟨.insert, 1, none, some 0, none, some ["ALL", "User", "ONE", "0"]⟩, none, some event154_0_target0⟩

theorem event154_0_route0_selected : selectedRoute event154_0Tuple event154_0Env event154_0Candidate 0 (none) (some event154_0_target0) = some event154_0_route0 := by decide

def event154_0_route1 : TypedRoute := ⟨⟨.update, 1, some 0, some 1, some ["ALL", "Work", "ONE", "0"], some ["ALL", "Work", "ONE", "1"]⟩, some event154_0_source0, some event154_0_target1⟩

theorem event154_0_route1_selected : selectedRoute event154_0Tuple event154_0Env event154_0Candidate 1 (some event154_0_source0) (some event154_0_target1) = some event154_0_route1 := by decide

def event154_0_route2 : TypedRoute := ⟨⟨.update, 1, some 1, some 2, some ["ALL", "Work", "ONE", "0"], some ["ALL", "Work", "ONE", "1"]⟩, some event154_0_source1, some event154_0_target2⟩

theorem event154_0_route2_selected : selectedRoute event154_0Tuple event154_0Env event154_0Candidate 2 (some event154_0_source1) (some event154_0_target2) = some event154_0_route2 := by decide

def event154_0_use4Before : MatrixUse := { binding := event154_0_source0, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,0,\\\"_q0\\\",\\\"SEQUENCE\\\",false,\\\"[1, 2]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":0,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q0\\\"}\"}" }

def event154_0_use4After : MatrixUse := { binding := event154_0_target1, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,1,\\\"_q1\\\",\\\"SEQUENCE\\\",false,\\\"[1, 2]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q1\\\"}\"}" }

theorem event154_0_use4_accepted : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 1 [event154_0_use4Before] [event154_0_use4After] event154_0_use4Before event154_0_use4After = some event154_0_route1 := by decide

theorem event154_0_use4_old_rejected (rest : Bool) : oldPaidImportGate event154_0_source0 event154_0_target1 rest = false := old_same_quantifier_rejected event154_0_source0 event154_0_target1 rest (by decide)

theorem event154_0_use4_reject_phase : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 1 [event154_0_use4Before] [event154_0_use4After] { event154_0_use4Before with phase := 99 } event154_0_use4After = none := by decide

theorem event154_0_use4_reject_nodePath : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 1 [event154_0_use4Before] [event154_0_use4After] { event154_0_use4Before with nodePath := "foreign-occurrence" } event154_0_use4After = none := by decide

theorem event154_0_use4_wrong_binding_rejected : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 1 [event154_0_use4Before] [event154_0_use4After] { event154_0_use4Before with binding := { event154_0_source0 with origin := { event154_0_source0.origin with owner := "foreign-owner" } } } event154_0_use4After = none := by decide

theorem event154_0_use4_unpaid_rejected : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes { event154_0Program with candidate := { event154_0Candidate with declarations := [] } } 1 [event154_0_use4Before] [event154_0_use4After] event154_0_use4Before event154_0_use4After = none := by decide

def event154_0_use7Before : MatrixUse := { binding := event154_0_source1, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/1/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,1,\\\"_q1\\\",\\\"SEQUENCE\\\",false,\\\"[1, 2]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q1\\\"}\"}" }

def event154_0_use7After : MatrixUse := { binding := event154_0_target2, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/1/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,2,\\\"_q2\\\",\\\"SEQUENCE\\\",false,\\\"[1, 2]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":2,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q2\\\"}\"}" }

theorem event154_0_use7_accepted : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 2 [event154_0_use7Before] [event154_0_use7After] event154_0_use7Before event154_0_use7After = some event154_0_route2 := by decide

theorem event154_0_use7_old_rejected (rest : Bool) : oldPaidImportGate event154_0_source1 event154_0_target2 rest = false := old_same_quantifier_rejected event154_0_source1 event154_0_target2 rest (by decide)

theorem event154_0_use7_reject_phase : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 2 [event154_0_use7Before] [event154_0_use7After] { event154_0_use7Before with phase := 99 } event154_0_use7After = none := by decide

theorem event154_0_use7_reject_nodePath : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 2 [event154_0_use7Before] [event154_0_use7After] { event154_0_use7Before with nodePath := "foreign-occurrence" } event154_0_use7After = none := by decide

theorem event154_0_use7_wrong_binding_rejected : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes event154_0Program 2 [event154_0_use7Before] [event154_0_use7After] { event154_0_use7Before with binding := { event154_0_source1 with origin := { event154_0_source1.origin with owner := "foreign-owner" } } } event154_0_use7After = none := by decide

theorem event154_0_use7_unpaid_rejected : selectedOwnedRoute event154_0Tuple event154_0_sourceScopes event154_0_targetScopes { event154_0Program with candidate := { event154_0Candidate with declarations := [] } } 2 [event154_0_use7Before] [event154_0_use7After] event154_0_use7Before event154_0_use7After = none := by decide

def event154_0Payments : List Payment := [routePayment event154_0_route0, routePayment event154_0_route1, routePayment event154_0_route2]

theorem event154_0_all_declarations_paid_once : paymentCheck event154_0Payments event154_0Payments = true ∧ owned .declaration event154_0Payments = 3 := by decide

theorem event154_0_duplicate_payment_rejected : paymentCheck event154_0Payments (event154_0Payments ++ [routePayment event154_0_route1]) = false := by decide

theorem event154_0_missing_payment_rejected : paymentCheck event154_0Payments (event154_0Payments.drop 1) = false := by decide

def event154_1_source0 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3c"
    occurrence := "292"
    owner := "root/predicate[0]/decl[0]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(User)"
    domain := "13:GLOBALBINDING[3:20:alloy/signature/User16:RELATION[4:User]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def event154_1_source1 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3c"
    occurrence := "299"
    owner := "root/predicate[0]/decl[1]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := [0]
    exactType := "AlloyCarrier(Work)"
    domain := "4:JOIN[3:12:BOPEXPR_JOIN16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:119:8:VARIABLE[3:12:dependency/016:RELATION[4:User]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}125:13:GLOBALBINDING[3:7:profile22:RELATION[4:User4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 1
  }
  vectorIndex := 1
  coordinate := 1
  ordinal := 1
}

def event154_1_source2 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3c"
    occurrence := "300"
    owner := "root/predicate[0]/decl[1]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := [0]
    exactType := "AlloyCarrier(Work)"
    domain := "4:JOIN[3:12:BOPEXPR_JOIN16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{2:119:8:VARIABLE[3:12:dependency/016:RELATION[4:User]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}125:13:GLOBALBINDING[3:7:profile22:RELATION[4:User4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 1
  }
  vectorIndex := 2
  coordinate := 2
  ordinal := 2
}

def event154_1_sourceScopes : List Scope := [{ phase := 0, path := [], owned := [event154_1_source0, event154_1_source1, event154_1_source2], imports := [] }]

theorem event154_1_source0_owner : resolveBinding event154_1_sourceScopes 0 event154_1_source0 = some event154_1_source0 := by decide

theorem event154_1_source1_owner : resolveBinding event154_1_sourceScopes 0 event154_1_source1 = some event154_1_source1 := by decide

theorem event154_1_source2_owner : resolveBinding event154_1_sourceScopes 0 event154_1_source2 = some event154_1_source2 := by decide

def event154_1_target0 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3"
    occurrence := "7"
    owner := "root/predicate[0]/decl[0]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Work)"
    domain := "13:GLOBALBINDING[3:20:alloy/signature/Work16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def event154_1_target1 : Binding := {
  origin := {
    sourceHash := "fe0c449662c4f69e71abf30f50a22515806e6c0e97eceaecc1d91d27a8ddcc1b"
    predicate := "inv3"
    occurrence := "8"
    owner := "root/predicate[0]/decl[0]@pos"
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Work)"
    domain := "13:GLOBALBINDING[3:20:alloy/signature/Work16:RELATION[4:Work]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 1
  coordinate := 1
  ordinal := 1
}

def event154_1_targetScopes : List Scope := [{ phase := 0, path := [], owned := [event154_1_target0, event154_1_target1], imports := [] }, { phase := 1, path := [0], owned := [], imports := [event154_1_target0, event154_1_target1] }]

theorem event154_1_target0_owner : resolveBinding event154_1_targetScopes 0 event154_1_target0 = some event154_1_target0 := by decide

theorem event154_1_target1_owner : resolveBinding event154_1_targetScopes 0 event154_1_target1 = some event154_1_target1 := by decide

theorem event154_1_target0_import : resolveBinding event154_1_targetScopes 1 event154_1_target0 = some event154_1_target0 := by decide

theorem event154_1_target0_no_rebinding : resolveBinding event154_1_targetScopes 1 { event154_1_target0 with origin := { event154_1_target0.origin with phase := 1 } } = none := by decide

theorem event154_1_target1_import : resolveBinding event154_1_targetScopes 1 event154_1_target1 = some event154_1_target1 := by decide

theorem event154_1_target1_no_rebinding : resolveBinding event154_1_targetScopes 1 { event154_1_target1 with origin := { event154_1_target1.origin with phase := 1 } } = none := by decide

def event154_1Env : Environment := ⟨[event154_1_source0, event154_1_source1, event154_1_source2], [event154_1_target0, event154_1_target1]⟩
def event154_1Tuples : List (Binding × List String) := [(event154_1_source0, ["ALL", "User", "ONE", "0"]), (event154_1_source1, ["ALL", "Work", "ONE", "1"]), (event154_1_source2, ["ALL", "Work", "ONE", "1"]), (event154_1_target0, ["ALL", "Work", "ONE", "0"]), (event154_1_target1, ["ALL", "Work", "ONE", "0"])]
def event154_1Tuple (b : Binding) : List String := ((event154_1Tuples.find? (fun p => p.1 == b)).map Prod.snd).getD []

def event154_1Candidate : JointCandidate (List String) := {
  source := [⟨0, ["ALL", "User", "ONE", "0"]⟩, ⟨1, ["ALL", "Work", "ONE", "1"]⟩, ⟨2, ["ALL", "Work", "ONE", "1"]⟩]
  target := [⟨0, ["ALL", "Work", "ONE", "0"]⟩, ⟨1, ["ALL", "Work", "ONE", "0"]⟩]
  declarations := [⟨.delete, 1, some 0, none⟩, ⟨.update, 1, some 1, some 0⟩, ⟨.update, 1, some 2, some 1⟩]
  variableReads := []
  otherMatrixCharges := []
  temporalCharges := []
}
def event154_1Program : OwnerProgram := ⟨0, 0, event154_1Env, event154_1Candidate⟩

theorem event154_1_complete_owner_program : ownerProgramCheck event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program = true := by decide

def event154_1_route0 : TypedRoute := ⟨⟨.delete, 1, some 0, none, some ["ALL", "User", "ONE", "0"], none⟩, some event154_1_source0, none⟩

theorem event154_1_route0_selected : selectedRoute event154_1Tuple event154_1Env event154_1Candidate 0 (some event154_1_source0) (none) = some event154_1_route0 := by decide

def event154_1_route1 : TypedRoute := ⟨⟨.update, 1, some 1, some 0, some ["ALL", "Work", "ONE", "1"], some ["ALL", "Work", "ONE", "0"]⟩, some event154_1_source1, some event154_1_target0⟩

theorem event154_1_route1_selected : selectedRoute event154_1Tuple event154_1Env event154_1Candidate 1 (some event154_1_source1) (some event154_1_target0) = some event154_1_route1 := by decide

def event154_1_route2 : TypedRoute := ⟨⟨.update, 1, some 2, some 1, some ["ALL", "Work", "ONE", "1"], some ["ALL", "Work", "ONE", "0"]⟩, some event154_1_source2, some event154_1_target1⟩

theorem event154_1_route2_selected : selectedRoute event154_1Tuple event154_1Env event154_1Candidate 2 (some event154_1_source2) (some event154_1_target1) = some event154_1_route2 := by decide

def event154_1_use4Before : MatrixUse := { binding := event154_1_source1, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,1,\\\"_q1\\\",\\\"SEQUENCE\\\",false,\\\"[-1, 0, 1]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q1\\\"}\"}" }

def event154_1_use4After : MatrixUse := { binding := event154_1_target0, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,0,\\\"_q0\\\",\\\"SEQUENCE\\\",false,\\\"[-1, 0, 1]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":0,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q0\\\"}\"}" }

theorem event154_1_use4_accepted : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 1 [event154_1_use4Before] [event154_1_use4After] event154_1_use4Before event154_1_use4After = some event154_1_route1 := by decide

theorem event154_1_use4_old_rejected (rest : Bool) : oldPaidImportGate event154_1_source1 event154_1_target0 rest = false := old_same_quantifier_rejected event154_1_source1 event154_1_target0 rest (by decide)

theorem event154_1_use4_reject_phase : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 1 [event154_1_use4Before] [event154_1_use4After] { event154_1_use4Before with phase := 99 } event154_1_use4After = none := by decide

theorem event154_1_use4_reject_nodePath : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 1 [event154_1_use4Before] [event154_1_use4After] { event154_1_use4Before with nodePath := "foreign-occurrence" } event154_1_use4After = none := by decide

theorem event154_1_use4_wrong_binding_rejected : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 1 [event154_1_use4Before] [event154_1_use4After] { event154_1_use4Before with binding := { event154_1_source1 with origin := { event154_1_source1.origin with owner := "foreign-owner" } } } event154_1_use4After = none := by decide

theorem event154_1_use4_unpaid_rejected : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes { event154_1Program with candidate := { event154_1Candidate with declarations := [] } } 1 [event154_1_use4Before] [event154_1_use4After] event154_1_use4Before event154_1_use4After = none := by decide

def event154_1_use7Before : MatrixUse := { binding := event154_1_source2, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/1/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,2,\\\"_q2\\\",\\\"SEQUENCE\\\",false,\\\"[-1, 0, 1]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":2,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q2\\\"}\"}" }

def event154_1_use7After : MatrixUse := { binding := event154_1_target1, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/1/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"head\":\"[\\\"VARIABLE\\\",null,1,\\\"_q1\\\",\\\"SEQUENCE\\\",false,\\\"[-1, 0, 1]\\\"]\",\"certifiedAlternatives\":[],\"children\":[],\"nativeEvidence\":\"{\\\"bindingIndex\\\":1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q1\\\"}\"}" }

theorem event154_1_use7_accepted : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 2 [event154_1_use7Before] [event154_1_use7After] event154_1_use7Before event154_1_use7After = some event154_1_route2 := by decide

theorem event154_1_use7_old_rejected (rest : Bool) : oldPaidImportGate event154_1_source2 event154_1_target1 rest = false := old_same_quantifier_rejected event154_1_source2 event154_1_target1 rest (by decide)

theorem event154_1_use7_reject_phase : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 2 [event154_1_use7Before] [event154_1_use7After] { event154_1_use7Before with phase := 99 } event154_1_use7After = none := by decide

theorem event154_1_use7_reject_nodePath : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 2 [event154_1_use7Before] [event154_1_use7After] { event154_1_use7Before with nodePath := "foreign-occurrence" } event154_1_use7After = none := by decide

theorem event154_1_use7_wrong_binding_rejected : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes event154_1Program 2 [event154_1_use7Before] [event154_1_use7After] { event154_1_use7Before with binding := { event154_1_source2 with origin := { event154_1_source2.origin with owner := "foreign-owner" } } } event154_1_use7After = none := by decide

theorem event154_1_use7_unpaid_rejected : selectedOwnedRoute event154_1Tuple event154_1_sourceScopes event154_1_targetScopes { event154_1Program with candidate := { event154_1Candidate with declarations := [] } } 2 [event154_1_use7Before] [event154_1_use7After] event154_1_use7Before event154_1_use7After = none := by decide

def event154_1Payments : List Payment := [routePayment event154_1_route0, routePayment event154_1_route1, routePayment event154_1_route2]

theorem event154_1_all_declarations_paid_once : paymentCheck event154_1Payments event154_1Payments = true ∧ owned .declaration event154_1Payments = 3 := by decide

theorem event154_1_duplicate_payment_rejected : paymentCheck event154_1Payments (event154_1Payments ++ [routePayment event154_1_route1]) = false := by decide

theorem event154_1_missing_payment_rejected : paymentCheck event154_1Payments (event154_1Payments.drop 1) = false := by decide

theorem event154_guard_semantics {User Work Source Identifier : Type} (profile : Nat → User → Work → Prop)
    (source : Work → Source) (ids : Work → Identifier → Prop) (ownerTime : Nat) (u : User) :
    StructuralDeclarationTyping.sourceAllDisjoint (profile ownerTime u)
      (fun x y => source x = source y → ∀ i, ¬ (ids x i ∧ ids y i)) ↔
    (∀ x y : Work, x ≠ y → ¬ profile ownerTime u x ∨ ¬ profile ownerTime u y ∨
      (source x = source y → ∀ i, ¬ (ids x i ∧ ids y i))) :=
  dependent_disjoint_guard_lowering (profile ownerTime)
    (fun _ x y => source x = source y → ∀ i, ¬ (ids x i ∧ ids y i)) u

end PhaseOwnedSingleRoutes
