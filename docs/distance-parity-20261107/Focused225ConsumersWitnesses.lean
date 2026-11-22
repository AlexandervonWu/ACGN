import Focused225SelectedConsumers

namespace Focused225ConsumersWitnesses
open Focused225SelectedConsumers Focused225Concrete Focused225SharedContracts Focused225ConcreteWitnesses
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

def selected146_0Pair : MatrixPair := { key := ⟨"764dcd7d4d287e3277778a5dc463ea472d8aff11473526fbe484923842e5c50a", "/certified/phases/0/program/operations/3"⟩, declarationIndex := 2, kind := "metric-align", cost := 0, before := route146_0_sourceUse, after := route146_0_targetUse }

theorem selected146_0_paired_route : pairedRoute route146_0Tuple route146_0Env route146_0Candidate [selected146_0Pair] selected146_0Pair.key route146_0_sourceUse route146_0_targetUse = some route146_0_2 :=
  selected_pair_accepts route146_0Tuple route146_0Env route146_0Candidate selected146_0Pair route146_0_2 rfl rfl route146_0_2_selected

def selected146_0Sibling : MatrixPair := { selected146_0Pair with key := ⟨"synthetic-source-ledger-control", "second-selected-read"⟩, before := { route146_0_sourceUse with nodePath := "root/second-owned-read" }, after := { route146_0_targetUse with nodePath := "root/second-owned-read" } }

theorem selected146_0_genuine_second_pair : pairedRoute route146_0Tuple route146_0Env route146_0Candidate [selected146_0Pair, selected146_0Sibling] selected146_0Sibling.key selected146_0Sibling.before selected146_0Sibling.after = some route146_0_2 := by decide

theorem selected146_0_genuine_cross_pair_rejected : pairedRoute route146_0Tuple route146_0Env route146_0Candidate [selected146_0Pair, selected146_0Sibling] selected146_0Pair.key selected146_0Pair.before selected146_0Sibling.after = none :=
  genuine_cross_pair_rejected route146_0Tuple route146_0Env route146_0Candidate _ _ selected146_0Pair _ _ (by decide) (by intro h; have paths := congrArg MatrixUse.nodePath h; contradiction)

def selected146_0Head : HeadPoint := {
  sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
  predicate := "inv2"
  phase := 1
  ownerPhase := 0
  role := "ALWAYS"
  sourcePath := "phase[0]/temporal[0]"
  operator := "ALWAYS"
}

def selected146_0Decl0 : ChargeEntry := ⟨"selected-declaration-effect-0", ⟨"764dcd7d4d287e3277778a5dc463ea472d8aff11473526fbe484923842e5c50a", "/certified/nativeDeclarationPrograms/1/operations/0"⟩, routePayment route146_0_0⟩

def selected146_0Decl1 : ChargeEntry := ⟨"selected-declaration-effect-1", ⟨"764dcd7d4d287e3277778a5dc463ea472d8aff11473526fbe484923842e5c50a", "/certified/nativeDeclarationPrograms/1/operations/1"⟩, routePayment route146_0_1⟩

def selected146_0Decl2 : ChargeEntry := ⟨"selected-declaration-effect-2", ⟨"764dcd7d4d287e3277778a5dc463ea472d8aff11473526fbe484923842e5c50a", "/certified/nativeDeclarationPrograms/1/operations/2"⟩, routePayment route146_0_2⟩

def selected146_0Temporal : ChargeEntry := ⟨"selected-temporal-ALWAYS-head", ⟨"764dcd7d4d287e3277778a5dc463ea472d8aff11473526fbe484923842e5c50a", "/certified/nativeTemporalProgram/operations/0"⟩, route146_0Temporal⟩

def selected146_0Matrix : ChargeEntry := ⟨"selected-matrix-REF-replacement", ⟨"764dcd7d4d287e3277778a5dc463ea472d8aff11473526fbe484923842e5c50a", "/certified/phases/0/program/operations/8"⟩, ⟨{ sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", targetHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", predicatePair := "inv2->inv2c", sourceOccurrence := "root/child/0/child/1", targetOccurrence := "root/child/0/child/1", before := "[\"REF\",\"temporal-phase[1]/ALWAYS\",-1,\"null\",\"SEQUENCE\",false,\"[-1, -1, 0]\"]", after := "[\"PLUS\",\"identity=;type=AlloyRelationUnion(Rel(AlloySig:Institution),Rel(AlloySig:User))\",-1,\"null\",\"SET\",true,\"[-1, -1, 0]\"]" }, .matrix, 1⟩⟩

def selected146_0Reference : ReferenceUse := { key := selected146_0Matrix.nativeOperation, sourceSide := true, head := selected146_0Head, nodePath := "root/child/0/child/1", originalPayload := "{\"bindingIndex\":-1,\"observationPhases\":[1],\"observationTemporalOperator\":\"ALWAYS\",\"observationType\":\"Bool\",\"payload\":\"temporal[0:1]\",\"semanticPayload\":\"temporal-phase[1]/ALWAYS\",\"lexicalVariable\":\"null\"}" }

def selected146_0Edit : TemporalEdit := ⟨selected146_0Temporal.nativeOperation, some selected146_0Head, none, selected146_0Temporal⟩

def selected146_0Context : Context := { tuple := route146_0Tuple, env := route146_0Env, candidate := route146_0Candidate, matrixPairs := [selected146_0Pair], temporalEdits := [selected146_0Edit], references := [selected146_0Reference], charges := [selected146_0Decl0, selected146_0Decl1, selected146_0Decl2, selected146_0Temporal, selected146_0Matrix] }

def selected146_0Borrows : List Borrow := [⟨selected146_0Pair.key, selected146_0Decl2.key⟩, ⟨selected146_0Reference.key, selected146_0Temporal.key⟩]

theorem selected146_0_matrix_authorized : authorize selected146_0Context ⟨selected146_0Pair.key, selected146_0Decl2.key⟩ = some selected146_0Decl2 := by decide

theorem selected146_0_reference_authorized : authorize selected146_0Context ⟨selected146_0Reference.key, selected146_0Temporal.key⟩ = some selected146_0Temporal := by decide

theorem selected146_0_ownership : ownershipCheck selected146_0Context selected146_0Context.charges selected146_0Borrows = true := by decide

theorem selected146_0_wrong_existing_token : authorize selected146_0Context ⟨selected146_0Pair.key, selected146_0Decl0.key⟩ = none := by decide

theorem selected146_0_wrong_existing_temporal_token : authorize selected146_0Context ⟨selected146_0Reference.key, selected146_0Decl2.key⟩ = none := by decide

theorem selected146_0_wrong_registered_head : authorize { selected146_0Context with references := [{ selected146_0Reference with head := { selected146_0Head with phase := 9 } }] } ⟨selected146_0Reference.key, selected146_0Temporal.key⟩ = none := by decide

theorem selected146_0_absent_consumer : authorize selected146_0Context ⟨⟨"wrong-receipt", "not-selected"⟩, selected146_0Decl2.key⟩ = none := by decide

theorem selected146_0_missing_consumer : ownershipCheck selected146_0Context selected146_0Context.charges (selected146_0Borrows.drop 1) = false := by decide

theorem selected146_0_missing_native_charge : ownershipCheck selected146_0Context (selected146_0Context.charges.drop 1) selected146_0Borrows = false := by decide

def selected146_0Reencoded : ChargeEntry := { selected146_0Temporal with displayLabel := "different-reissued-string", payment := { selected146_0Temporal.payment with owner := .matrix, effect := { selected146_0Temporal.payment.effect with before := "alternate-display-encoding" } } }

theorem selected146_0_same_logical_effect_reencoded_rejected : ownershipCheck { selected146_0Context with charges := selected146_0Context.charges ++ [selected146_0Reencoded] } (selected146_0Context.charges ++ [selected146_0Reencoded]) selected146_0Borrows = false := by decide

def selected146_0Alias : ChargeEntry := { selected146_0Temporal with displayLabel := "second-display-key" }

theorem selected146_0_alias_same_payment : selected146_0Alias.payment = selected146_0Temporal.payment := by decide

theorem selected146_0_alias_same_native_identity : selected146_0Alias.key = selected146_0Temporal.key := by decide

theorem selected146_0_different_string_same_payment_rejected : ownershipCheck { selected146_0Context with charges := [selected146_0Temporal, selected146_0Alias] , matrixPairs := [], references := [], temporalEdits := [] } [selected146_0Temporal, selected146_0Alias] [] = false := by decide

theorem selected146_0_wrong_temporal_native_operation : authorize { selected146_0Context with temporalEdits := [{ selected146_0Edit with key := selected146_0Decl0.nativeOperation }] } ⟨selected146_0Reference.key, selected146_0Temporal.key⟩ = none := by decide

theorem selected146_0_wrong_temporal_issuance : ownershipCheck { selected146_0Context with temporalEdits := [{ selected146_0Edit with key := selected146_0Decl0.nativeOperation }] } selected146_0Context.charges selected146_0Borrows = false := by decide

theorem selected146_0_forged_origin_claim : ownershipCheck selected146_0Context (selected146_0Context.charges ++ [{ selected146_0Temporal with nativeOperation := ⟨"foreign-receipt", "foreign-operation"⟩ }]) selected146_0Borrows = false := by decide

theorem selected146_0_native_cost_preserved : (selected146_0Context.charges.map (fun p => p.payment.amount)).sum = 5 := by decide

def selected146_1Pair : MatrixPair := { key := ⟨"8d55d55cd78c032453bfbc9844e329480cc8cae643e65583a2abe0a6a82378d0", "/certified/phases/0/program/operations/3"⟩, declarationIndex := 2, kind := "metric-align", cost := 0, before := route146_1_sourceUse, after := route146_1_targetUse }

theorem selected146_1_paired_route : pairedRoute route146_1Tuple route146_1Env route146_1Candidate [selected146_1Pair] selected146_1Pair.key route146_1_sourceUse route146_1_targetUse = some route146_1_2 :=
  selected_pair_accepts route146_1Tuple route146_1Env route146_1Candidate selected146_1Pair route146_1_2 rfl rfl route146_1_2_selected

def selected146_1Sibling : MatrixPair := { selected146_1Pair with key := ⟨"synthetic-source-ledger-control", "second-selected-read"⟩, before := { route146_1_sourceUse with nodePath := "root/second-owned-read" }, after := { route146_1_targetUse with nodePath := "root/second-owned-read" } }

theorem selected146_1_genuine_second_pair : pairedRoute route146_1Tuple route146_1Env route146_1Candidate [selected146_1Pair, selected146_1Sibling] selected146_1Sibling.key selected146_1Sibling.before selected146_1Sibling.after = some route146_1_2 := by decide

theorem selected146_1_genuine_cross_pair_rejected : pairedRoute route146_1Tuple route146_1Env route146_1Candidate [selected146_1Pair, selected146_1Sibling] selected146_1Pair.key selected146_1Pair.before selected146_1Sibling.after = none :=
  genuine_cross_pair_rejected route146_1Tuple route146_1Env route146_1Candidate _ _ selected146_1Pair _ _ (by decide) (by intro h; have paths := congrArg MatrixUse.nodePath h; contradiction)

def selected146_1Head : HeadPoint := {
  sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
  predicate := "inv2c"
  phase := 1
  ownerPhase := 0
  role := "ALWAYS"
  sourcePath := "phase[0]/temporal[0]"
  operator := "ALWAYS"
}

def selected146_1Decl0 : ChargeEntry := ⟨"selected-declaration-effect-0", ⟨"8d55d55cd78c032453bfbc9844e329480cc8cae643e65583a2abe0a6a82378d0", "/certified/nativeDeclarationPrograms/1/operations/0"⟩, routePayment route146_1_0⟩

def selected146_1Decl1 : ChargeEntry := ⟨"selected-declaration-effect-1", ⟨"8d55d55cd78c032453bfbc9844e329480cc8cae643e65583a2abe0a6a82378d0", "/certified/nativeDeclarationPrograms/1/operations/1"⟩, routePayment route146_1_1⟩

def selected146_1Decl2 : ChargeEntry := ⟨"selected-declaration-effect-2", ⟨"8d55d55cd78c032453bfbc9844e329480cc8cae643e65583a2abe0a6a82378d0", "/certified/nativeDeclarationPrograms/1/operations/2"⟩, routePayment route146_1_2⟩

def selected146_1Temporal : ChargeEntry := ⟨"selected-temporal-ALWAYS-head", ⟨"8d55d55cd78c032453bfbc9844e329480cc8cae643e65583a2abe0a6a82378d0", "/certified/nativeTemporalProgram/operations/0"⟩, route146_1Temporal⟩

def selected146_1Matrix : ChargeEntry := ⟨"selected-matrix-REF-replacement", ⟨"8d55d55cd78c032453bfbc9844e329480cc8cae643e65583a2abe0a6a82378d0", "/certified/phases/0/program/operations/8"⟩, ⟨{ sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", targetHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", predicatePair := "inv2c->inv2", sourceOccurrence := "root/child/0/child/1", targetOccurrence := "root/child/0/child/1", before := "[\"PLUS\",\"identity=;type=AlloyRelationUnion(Rel(AlloySig:Institution),Rel(AlloySig:User))\",-1,\"null\",\"SET\",true,\"[2]\"]", after := "[\"REF\",\"temporal-phase[1]/ALWAYS\",-1,\"null\",\"SEQUENCE\",false,\"[2]\"]" }, .matrix, 1⟩⟩

def selected146_1Reference : ReferenceUse := { key := selected146_1Matrix.nativeOperation, sourceSide := false, head := selected146_1Head, nodePath := "root/child/0/child/1", originalPayload := "{\"bindingIndex\":-1,\"observationPhases\":[1],\"observationTemporalOperator\":\"ALWAYS\",\"observationType\":\"Bool\",\"payload\":\"temporal[0:1]\",\"semanticPayload\":\"temporal-phase[1]/ALWAYS\",\"lexicalVariable\":\"null\"}" }

def selected146_1Edit : TemporalEdit := ⟨selected146_1Temporal.nativeOperation, none, some selected146_1Head, selected146_1Temporal⟩

def selected146_1Context : Context := { tuple := route146_1Tuple, env := route146_1Env, candidate := route146_1Candidate, matrixPairs := [selected146_1Pair], temporalEdits := [selected146_1Edit], references := [selected146_1Reference], charges := [selected146_1Decl0, selected146_1Decl1, selected146_1Decl2, selected146_1Temporal, selected146_1Matrix] }

def selected146_1Borrows : List Borrow := [⟨selected146_1Pair.key, selected146_1Decl2.key⟩, ⟨selected146_1Reference.key, selected146_1Temporal.key⟩]

theorem selected146_1_matrix_authorized : authorize selected146_1Context ⟨selected146_1Pair.key, selected146_1Decl2.key⟩ = some selected146_1Decl2 := by decide

theorem selected146_1_reference_authorized : authorize selected146_1Context ⟨selected146_1Reference.key, selected146_1Temporal.key⟩ = some selected146_1Temporal := by decide

theorem selected146_1_ownership : ownershipCheck selected146_1Context selected146_1Context.charges selected146_1Borrows = true := by decide

theorem selected146_1_wrong_existing_token : authorize selected146_1Context ⟨selected146_1Pair.key, selected146_1Decl0.key⟩ = none := by decide

theorem selected146_1_wrong_existing_temporal_token : authorize selected146_1Context ⟨selected146_1Reference.key, selected146_1Decl2.key⟩ = none := by decide

theorem selected146_1_wrong_registered_head : authorize { selected146_1Context with references := [{ selected146_1Reference with head := { selected146_1Head with phase := 9 } }] } ⟨selected146_1Reference.key, selected146_1Temporal.key⟩ = none := by decide

theorem selected146_1_absent_consumer : authorize selected146_1Context ⟨⟨"wrong-receipt", "not-selected"⟩, selected146_1Decl2.key⟩ = none := by decide

theorem selected146_1_missing_consumer : ownershipCheck selected146_1Context selected146_1Context.charges (selected146_1Borrows.drop 1) = false := by decide

theorem selected146_1_missing_native_charge : ownershipCheck selected146_1Context (selected146_1Context.charges.drop 1) selected146_1Borrows = false := by decide

def selected146_1Reencoded : ChargeEntry := { selected146_1Temporal with displayLabel := "different-reissued-string", payment := { selected146_1Temporal.payment with owner := .matrix, effect := { selected146_1Temporal.payment.effect with before := "alternate-display-encoding" } } }

theorem selected146_1_same_logical_effect_reencoded_rejected : ownershipCheck { selected146_1Context with charges := selected146_1Context.charges ++ [selected146_1Reencoded] } (selected146_1Context.charges ++ [selected146_1Reencoded]) selected146_1Borrows = false := by decide

def selected146_1Alias : ChargeEntry := { selected146_1Temporal with displayLabel := "second-display-key" }

theorem selected146_1_alias_same_payment : selected146_1Alias.payment = selected146_1Temporal.payment := by decide

theorem selected146_1_alias_same_native_identity : selected146_1Alias.key = selected146_1Temporal.key := by decide

theorem selected146_1_different_string_same_payment_rejected : ownershipCheck { selected146_1Context with charges := [selected146_1Temporal, selected146_1Alias] , matrixPairs := [], references := [], temporalEdits := [] } [selected146_1Temporal, selected146_1Alias] [] = false := by decide

theorem selected146_1_wrong_temporal_native_operation : authorize { selected146_1Context with temporalEdits := [{ selected146_1Edit with key := selected146_1Decl0.nativeOperation }] } ⟨selected146_1Reference.key, selected146_1Temporal.key⟩ = none := by decide

theorem selected146_1_wrong_temporal_issuance : ownershipCheck { selected146_1Context with temporalEdits := [{ selected146_1Edit with key := selected146_1Decl0.nativeOperation }] } selected146_1Context.charges selected146_1Borrows = false := by decide

theorem selected146_1_forged_origin_claim : ownershipCheck selected146_1Context (selected146_1Context.charges ++ [{ selected146_1Temporal with nativeOperation := ⟨"foreign-receipt", "foreign-operation"⟩ }]) selected146_1Borrows = false := by decide

theorem selected146_1_native_cost_preserved : (selected146_1Context.charges.map (fun p => p.payment.amount)).sum = 5 := by decide

end Focused225ConsumersWitnesses
