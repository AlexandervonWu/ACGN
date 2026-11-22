import PhaseOwnedExecution
import PhaseOwnedSingleWitnesses
namespace PhaseOwnedExecutionWitnesses
open PhaseOwnedExecution PhaseOwnedGuardPayments PhaseOwnedJointRoutes
open PhaseOwnedSingleRoutes PhaseOwnedSingleWitnesses
open Focused225SharedContracts Focused225Concrete Focused225SelectedConsumers
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

def event154_0Identity : Identity := { candidate := "db6c65a2ce97cd0e2bb193c96d30fdef53efa03e2e5c66b6fd25bbefd02095d7", capture := "f8c3bf80cd9a819e583741e049d48017ab657103bc9f061a388fe6b83cc108cd", programPointer := "/0/directions/0/certified" }
def event154_0Guard : GuardClause Nat := { identity := event154_0Identity, sourcePointer := "/0/endpoints/1/stages/0", endpointPointer := "/0/directions/0/certified/phases/0/program/target", registry := "sha256:7f486d7fcd0a27215f7800265d05e6367a04a61dbdeb6768eaca76e1bdab0ec7", sourceSide := false, phase := 0, bindings := event154_0Env.target, guards := sourceGuards, body := sourceBody, actual := emittedClause }
def event154_0Selection : Selection Nat := { identity := event154_0Identity, program := "sha256:6e4371564ed53ff9d0d30b801a6509e074ebe24758eec38ac8989fa28711ff49", tuple := event154_0Tuple, sourceScopes := event154_0_sourceScopes, targetScopes := event154_0_targetScopes, owner := event154_0Program, matrixPairs := event154_0Pairs, sourceUses := [event154_0_use4Before, event154_0_use7Before], targetUses := [event154_0_use4After, event154_0_use7After], guards := [event154_0Guard], charges := event154_0Charges, borrows := event154_0Borrows }
def event154_0Replay : ReplayReceipt := { identity := event154_0Identity, program := "sha256:6e4371564ed53ff9d0d30b801a6509e074ebe24758eec38ac8989fa28711ff49", cost := 29 }
theorem event154_0_route4_bound : (event154_0Selection.route event154_0Pair4).isSome = true := congrArg Option.isSome event154_0_selected_pair4
theorem event154_0_route7_bound : (event154_0Selection.route event154_0Pair7).isSome = true := congrArg Option.isSome event154_0_selected_pair7
theorem event154_0_single_execution_checked : check event154_0Selection event154_0Replay event154_0Charges = true := by
  apply check_of_components
  · decide
  · exact event154_0_complete_owner_program
  · decide
  · change (event154_0Pairs.all (fun op => keyBound event154_0Identity op.key && (event154_0Selection.route op).isSome)) = true
    simp only [event154_0Pairs, List.all_cons, List.all_nil, Bool.and_true, event154_0_route4_bound, event154_0_route7_bound]
    decide
  · decide
  · exact event154_0_complete_selected_payment_coverage
theorem event154_0_mixed_capture_replay_rejected : check event154_0Selection { event154_0Replay with identity := { event154_0Identity with capture := "foreign-capture" } } event154_0Charges = false := foreign_replay_rejected _ _ _ (by decide)
theorem event154_0_same_cost_substituted_program_rejected : check event154_0Selection { event154_0Replay with program := "same-cost-other-selected-path" } event154_0Charges = false := substituted_program_rejected _ _ _ (by decide)
theorem event154_0_mixed_capture_guard_rejected : guardCheck event154_0Selection { event154_0Guard with identity := { event154_0Identity with capture := "foreign-capture" } } = false := foreign_guard_rejected _ _ (by decide)
theorem event154_0_foreign_guard_owner_rejected : guardCheck event154_0Selection { event154_0Guard with phase := 99 } = false := by decide
theorem event154_0_foreign_direction_key_rejected : keyBound event154_0Identity ⟨"f8c3bf80cd9a819e583741e049d48017ab657103bc9f061a388fe6b83cc108cd", "/0/directions/1/certified/phases/0/program/operations/4"⟩ = false := by decide
theorem event154_0_replayed_total : (event154_0Charges.map (fun c => c.payment.amount)).sum = 29 := (checked_total_and_replay _ _ _ event154_0_single_execution_checked).2.2.2.2
def event154_1Identity : Identity := { candidate := "db6c65a2ce97cd0e2bb193c96d30fdef53efa03e2e5c66b6fd25bbefd02095d7", capture := "f8c3bf80cd9a819e583741e049d48017ab657103bc9f061a388fe6b83cc108cd", programPointer := "/0/directions/1/certified" }
def event154_1Guard : GuardClause Nat := { identity := event154_1Identity, sourcePointer := "/0/endpoints/1/stages/0", endpointPointer := "/0/directions/1/certified/phases/0/program/source", registry := "sha256:7f486d7fcd0a27215f7800265d05e6367a04a61dbdeb6768eaca76e1bdab0ec7", sourceSide := true, phase := 0, bindings := event154_1Env.source, guards := sourceGuards, body := sourceBody, actual := emittedClause }
def event154_1Selection : Selection Nat := { identity := event154_1Identity, program := "sha256:678783dfd216491c5807e022722964645e00e03d43ca03a7a1f348c05da88333", tuple := event154_1Tuple, sourceScopes := event154_1_sourceScopes, targetScopes := event154_1_targetScopes, owner := event154_1Program, matrixPairs := event154_1Pairs, sourceUses := [event154_1_use4Before, event154_1_use7Before], targetUses := [event154_1_use4After, event154_1_use7After], guards := [event154_1Guard], charges := event154_1Charges, borrows := event154_1Borrows }
def event154_1Replay : ReplayReceipt := { identity := event154_1Identity, program := "sha256:678783dfd216491c5807e022722964645e00e03d43ca03a7a1f348c05da88333", cost := 29 }
theorem event154_1_route4_bound : (event154_1Selection.route event154_1Pair4).isSome = true := congrArg Option.isSome event154_1_selected_pair4
theorem event154_1_route7_bound : (event154_1Selection.route event154_1Pair7).isSome = true := congrArg Option.isSome event154_1_selected_pair7
theorem event154_1_single_execution_checked : check event154_1Selection event154_1Replay event154_1Charges = true := by
  apply check_of_components
  · decide
  · exact event154_1_complete_owner_program
  · decide
  · change (event154_1Pairs.all (fun op => keyBound event154_1Identity op.key && (event154_1Selection.route op).isSome)) = true
    simp only [event154_1Pairs, List.all_cons, List.all_nil, Bool.and_true, event154_1_route4_bound, event154_1_route7_bound]
    decide
  · decide
  · exact event154_1_complete_selected_payment_coverage
theorem event154_1_mixed_capture_replay_rejected : check event154_1Selection { event154_1Replay with identity := { event154_1Identity with capture := "foreign-capture" } } event154_1Charges = false := foreign_replay_rejected _ _ _ (by decide)
theorem event154_1_same_cost_substituted_program_rejected : check event154_1Selection { event154_1Replay with program := "same-cost-other-selected-path" } event154_1Charges = false := substituted_program_rejected _ _ _ (by decide)
theorem event154_1_mixed_capture_guard_rejected : guardCheck event154_1Selection { event154_1Guard with identity := { event154_1Identity with capture := "foreign-capture" } } = false := foreign_guard_rejected _ _ (by decide)
theorem event154_1_foreign_guard_owner_rejected : guardCheck event154_1Selection { event154_1Guard with phase := 99 } = false := by decide
theorem event154_1_foreign_direction_key_rejected : keyBound event154_1Identity ⟨"f8c3bf80cd9a819e583741e049d48017ab657103bc9f061a388fe6b83cc108cd", "/0/directions/0/certified/phases/0/program/operations/4"⟩ = false := by decide
theorem event154_1_replayed_total : (event154_1Charges.map (fun c => c.payment.amount)).sum = 29 := (checked_total_and_replay _ _ _ event154_1_single_execution_checked).2.2.2.2
end PhaseOwnedExecutionWitnesses
