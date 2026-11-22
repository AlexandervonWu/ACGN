import Focused225Concrete

/- Generated from the frozen native receipts and source CALL capture. See
   shared225-concrete-v1/witness-bindings.json for exact provenance. -/
namespace Focused225ConcreteWitnesses
open Focused225Concrete Focused225SharedContracts
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

def call14_0 : CallRecord := {
  sourceHash := "01048dce151c0e7f6312a022024f272746169e4d2c80d31adab84bd2b3c6f1fe"
  predicate := "inv13"
  anchor := 232
  parserOccurrence := 0
  lineage := 232
  owner := "matrix/inv13"
  phase := 0
  sourceBranch := [0, 1, 1, 1]
  semanticProfile := "16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}"
  callee := "util/integer/max"
  sourceName := "integer/max"
  kind := "call/expression"
  authority := "TYPECHECKED_IMPORT"
  resultType := "INT"
  declaredArity := 0
  nodeTree := "{\"alpha\":\"null\",\"call\":{\"arity\":0,\"authority\":\"TYPECHECKED_IMPORT\",\"callee\":\"util/integer/max\",\"kind\":\"call/expression\",\"occurrence\":0,\"sourceName\":\"integer/max\"},\"children\":[],\"flexible\":false,\"identity\":\"util/integer/max\",\"lineage\":232,\"maxArity\":0,\"metatype\":\"SET\",\"opcode\":\"CALL\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"integer/max\",\"type\":\"INT\",\"unordered\":false}"
  scopeBindings := "[{\"cardinality\":\"ONE\",\"id\":0,\"name\":\"_q0\",\"path\":\"root/predicate[0]/decl[0]@pos\",\"quantifier\":\"ALL\",\"sourceNames\":[\"x\",\"var/scope:2/slot:0\"],\"type\":\"RELATION[6:Person]\"},{\"cardinality\":\"ONE\",\"id\":1,\"name\":\"_q1\",\"path\":\"root/predicate[0]/body[1]/decl[0]@pos\",\"quantifier\":\"ALL\",\"sourceNames\":[\"y\",\"var/scope:3/slot:0\"],\"type\":\"RELATION[6:Course]\"}]"
  arguments := []
}

def call14_0Registry : List CallRecord := [call14_0]

theorem call14_0_source_accept : resolveCall call14_0Registry call14_0 = some call14_0 := source_call_resolves call14_0 (by decide)

theorem call14_0_typed_semantics (Value : String → Type)
    (interpret : (call : CallRecord) → Value call.resultType) :
    (resolveCall call14_0Registry call14_0).map (callValue Value interpret) = some (callValue Value interpret call14_0) :=
  resolved_call_evaluation Value interpret call14_0Registry call14_0 call14_0 call14_0_source_accept

theorem call14_0_reject_callee : resolveCall call14_0Registry { call14_0 with callee := "tampered" } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.callee) (by decide)

theorem call14_0_reject_resultType : resolveCall call14_0Registry { call14_0 with resultType := "INT_TAMPERED" } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.resultType) (by decide)

theorem call14_0_reject_owner : resolveCall call14_0Registry { call14_0 with owner := "foreign-owner" } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.owner) (by decide)

theorem call14_0_reject_phase : resolveCall call14_0Registry { call14_0 with phase := 99 } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.phase) (by decide)

theorem call14_0_reject_semanticProfile : resolveCall call14_0Registry { call14_0 with semanticProfile := "wrong-profile" } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.semanticProfile) (by decide)

theorem call14_0_reject_anchor : resolveCall call14_0Registry { call14_0 with anchor := 999999 } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.anchor) (by decide)

theorem call14_0_reject_scopeBindings : resolveCall call14_0Registry { call14_0 with scopeBindings := "[]" } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.scopeBindings) (by decide)

theorem call14_0_reject_payload : resolveCall call14_0Registry { call14_0 with nodeTree := call14_0.nodeTree ++ "!" } = none :=
  singleton_field_mismatch call14_0 _ (fun c => c.nodeTree) (appended_payload_differs call14_0.nodeTree)

theorem call14_0_ambiguous_anchor_rejected : resolveCall [call14_0, call14_0] call14_0 = none := duplicate_call_anchor_rejected call14_0

theorem call14_0_old_gate_reject : oldNullaryResult call14_0.kind call14_0.resultType = false := by decide

def call14_0ArgumentShapes : List ArgumentShape := []

theorem call14_0_old_closed : oldClosedNecessary call14_0 = false := by decide

theorem call14_0_old_bound : oldBoundNecessary call14_0 call14_0ArgumentShapes = false := by decide

theorem call14_0_old_nullary : oldNullaryNecessary call14_0 = false := by decide

theorem call14_0_entire_old_gate_rejected (closedRest boundRest nullaryRest : Bool) :
    oldCensusGate call14_0 call14_0ArgumentShapes false 0 closedRest boundRest nullaryRest = false :=
  old_census_rejected_by_conjuncts call14_0 call14_0ArgumentShapes call14_0_old_closed call14_0_old_bound call14_0_old_nullary 0 closedRest boundRest nullaryRest

def call14_1 : CallRecord := {
  sourceHash := "01048dce151c0e7f6312a022024f272746169e4d2c80d31adab84bd2b3c6f1fe"
  predicate := "inv13"
  anchor := 232
  parserOccurrence := 0
  lineage := 232
  owner := "matrix/inv13"
  phase := 0
  sourceBranch := [0, 1, 1, 1]
  semanticProfile := "16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}"
  callee := "util/integer/max"
  sourceName := "integer/max"
  kind := "call/expression"
  authority := "TYPECHECKED_IMPORT"
  resultType := "INT"
  declaredArity := 0
  nodeTree := "{\"alpha\":\"null\",\"call\":{\"arity\":0,\"authority\":\"TYPECHECKED_IMPORT\",\"callee\":\"util/integer/max\",\"kind\":\"call/expression\",\"occurrence\":0,\"sourceName\":\"integer/max\"},\"children\":[],\"flexible\":false,\"identity\":\"util/integer/max\",\"lineage\":232,\"maxArity\":0,\"metatype\":\"SET\",\"opcode\":\"CALL\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"integer/max\",\"type\":\"INT\",\"unordered\":false}"
  scopeBindings := "[{\"cardinality\":\"ONE\",\"id\":0,\"name\":\"_q0\",\"path\":\"root/predicate[0]/decl[0]@pos\",\"quantifier\":\"ALL\",\"sourceNames\":[\"x\",\"var/scope:2/slot:0\"],\"type\":\"RELATION[6:Person]\"},{\"cardinality\":\"ONE\",\"id\":1,\"name\":\"_q1\",\"path\":\"root/predicate[0]/body[1]/decl[0]@pos\",\"quantifier\":\"ALL\",\"sourceNames\":[\"y\",\"var/scope:3/slot:0\"],\"type\":\"RELATION[6:Course]\"}]"
  arguments := []
}

def call14_1Registry : List CallRecord := [call14_1]

theorem call14_1_source_accept : resolveCall call14_1Registry call14_1 = some call14_1 := source_call_resolves call14_1 (by decide)

theorem call14_1_typed_semantics (Value : String → Type)
    (interpret : (call : CallRecord) → Value call.resultType) :
    (resolveCall call14_1Registry call14_1).map (callValue Value interpret) = some (callValue Value interpret call14_1) :=
  resolved_call_evaluation Value interpret call14_1Registry call14_1 call14_1 call14_1_source_accept

theorem call14_1_reject_callee : resolveCall call14_1Registry { call14_1 with callee := "tampered" } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.callee) (by decide)

theorem call14_1_reject_resultType : resolveCall call14_1Registry { call14_1 with resultType := "INT_TAMPERED" } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.resultType) (by decide)

theorem call14_1_reject_owner : resolveCall call14_1Registry { call14_1 with owner := "foreign-owner" } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.owner) (by decide)

theorem call14_1_reject_phase : resolveCall call14_1Registry { call14_1 with phase := 99 } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.phase) (by decide)

theorem call14_1_reject_semanticProfile : resolveCall call14_1Registry { call14_1 with semanticProfile := "wrong-profile" } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.semanticProfile) (by decide)

theorem call14_1_reject_anchor : resolveCall call14_1Registry { call14_1 with anchor := 999999 } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.anchor) (by decide)

theorem call14_1_reject_scopeBindings : resolveCall call14_1Registry { call14_1 with scopeBindings := "[]" } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.scopeBindings) (by decide)

theorem call14_1_reject_payload : resolveCall call14_1Registry { call14_1 with nodeTree := call14_1.nodeTree ++ "!" } = none :=
  singleton_field_mismatch call14_1 _ (fun c => c.nodeTree) (appended_payload_differs call14_1.nodeTree)

theorem call14_1_ambiguous_anchor_rejected : resolveCall [call14_1, call14_1] call14_1 = none := duplicate_call_anchor_rejected call14_1

theorem call14_1_old_gate_reject : oldNullaryResult call14_1.kind call14_1.resultType = false := by decide

def call14_1ArgumentShapes : List ArgumentShape := []

theorem call14_1_old_closed : oldClosedNecessary call14_1 = false := by decide

theorem call14_1_old_bound : oldBoundNecessary call14_1 call14_1ArgumentShapes = false := by decide

theorem call14_1_old_nullary : oldNullaryNecessary call14_1 = false := by decide

theorem call14_1_entire_old_gate_rejected (closedRest boundRest nullaryRest : Bool) :
    oldCensusGate call14_1 call14_1ArgumentShapes false 0 closedRest boundRest nullaryRest = false :=
  old_census_rejected_by_conjuncts call14_1 call14_1ArgumentShapes call14_1_old_closed call14_1_old_bound call14_1_old_nullary 0 closedRest boundRest nullaryRest

def call1498_0 : CallRecord := {
  sourceHash := "ecc82ec37ec282799eca6964836290a5bf58d12fbb5f38da855eb8d009e6efa3"
  predicate := "inv4"
  anchor := 126
  parserOccurrence := 0
  lineage := 126
  owner := "matrix/inv4"
  phase := 0
  sourceBranch := [0]
  semanticProfile := "16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}"
  callee := "util/ordering<Position>/gte"
  sourceName := "ordering/gte"
  kind := "call/formula"
  authority := "TYPECHECKED_IMPORT"
  resultType := "BOOL"
  declaredArity := 2
  nodeTree := "{\"alpha\":\"null\",\"call\":{\"arity\":2,\"authority\":\"TYPECHECKED_IMPORT\",\"callee\":\"util/ordering<Position>/gte\",\"kind\":\"call/formula\",\"occurrence\":0,\"sourceName\":\"ordering/gte\"},\"children\":[{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":129,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":130,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":127,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":133,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":135,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"parts\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":134,\"maxArity\":1,\"metatype\":\"SET\",\"opcode\":\"CLOSURE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"UNOPE_CLOSURE\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":131,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[7:Product]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":132,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":128,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"util/ordering<Position>/gte\",\"lineage\":126,\"maxArity\":2,\"metatype\":\"BOOLEAN\",\"opcode\":\"CALL\",\"parserAncestry\":false,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"ordering/gte\",\"type\":\"BOOL\",\"unordered\":false}"
  scopeBindings := "[{\"cardinality\":\"ONE\",\"id\":0,\"name\":\"_q0\",\"path\":\"root/predicate[0]/decl[0]@pos\",\"quantifier\":\"ALL\",\"sourceNames\":[\"c\",\"var/scope:2/slot:0\"],\"type\":\"RELATION[9:Component]\"}]"
  arguments := [{ exactType := "RELATION[8:Position]", sourceTree := "{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":129,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":130,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":127,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false}", lineage := 127 }, { exactType := "RELATION[8:Position]", sourceTree := "{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":133,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":135,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"parts\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":134,\"maxArity\":1,\"metatype\":\"SET\",\"opcode\":\"CLOSURE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"UNOPE_CLOSURE\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":131,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[7:Product]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":132,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":128,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false}", lineage := 128 }]
}

def call1498_0Registry : List CallRecord := [call1498_0]

theorem call1498_0_source_accept : resolveCall call1498_0Registry call1498_0 = some call1498_0 := source_call_resolves call1498_0 (by decide)

theorem call1498_0_typed_semantics (Value : String → Type)
    (interpret : (call : CallRecord) → Value call.resultType) :
    (resolveCall call1498_0Registry call1498_0).map (callValue Value interpret) = some (callValue Value interpret call1498_0) :=
  resolved_call_evaluation Value interpret call1498_0Registry call1498_0 call1498_0 call1498_0_source_accept

theorem call1498_0_reject_callee : resolveCall call1498_0Registry { call1498_0 with callee := "tampered" } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.callee) (by decide)

theorem call1498_0_reject_resultType : resolveCall call1498_0Registry { call1498_0 with resultType := "INT_TAMPERED" } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.resultType) (by decide)

theorem call1498_0_reject_owner : resolveCall call1498_0Registry { call1498_0 with owner := "foreign-owner" } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.owner) (by decide)

theorem call1498_0_reject_phase : resolveCall call1498_0Registry { call1498_0 with phase := 99 } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.phase) (by decide)

theorem call1498_0_reject_semanticProfile : resolveCall call1498_0Registry { call1498_0 with semanticProfile := "wrong-profile" } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.semanticProfile) (by decide)

theorem call1498_0_reject_anchor : resolveCall call1498_0Registry { call1498_0 with anchor := 999999 } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.anchor) (by decide)

theorem call1498_0_reject_scopeBindings : resolveCall call1498_0Registry { call1498_0 with scopeBindings := "[]" } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.scopeBindings) (by decide)

theorem call1498_0_reject_payload : resolveCall call1498_0Registry { call1498_0 with nodeTree := call1498_0.nodeTree ++ "!" } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.nodeTree) (appended_payload_differs call1498_0.nodeTree)

theorem call1498_0_ambiguous_anchor_rejected : resolveCall [call1498_0, call1498_0] call1498_0 = none := duplicate_call_anchor_rejected call1498_0

def call1498_0ArgumentShapes : List ArgumentShape := [(.join .variable .global), (.join (.join .variable (.closure .global)) .global)]

theorem call1498_0_old_gate_reject : call1498_0ArgumentShapes.all oldArgumentGrammar = false := by decide

theorem call1498_0_argument_order_rejected : resolveCall call1498_0Registry { call1498_0 with arguments := call1498_0.arguments.reverse } = none :=
  singleton_field_mismatch call1498_0 _ (fun c => c.arguments.map CallArgument.lineage) (by decide)

theorem call1498_0_old_closed : oldClosedNecessary call1498_0 = false := by decide

theorem call1498_0_old_bound : oldBoundNecessary call1498_0 call1498_0ArgumentShapes = false := by decide

theorem call1498_0_old_nullary : oldNullaryNecessary call1498_0 = false := by decide

theorem call1498_0_entire_old_gate_rejected (closedRest boundRest nullaryRest : Bool) :
    oldCensusGate call1498_0 call1498_0ArgumentShapes false 0 closedRest boundRest nullaryRest = false :=
  old_census_rejected_by_conjuncts call1498_0 call1498_0ArgumentShapes call1498_0_old_closed call1498_0_old_bound call1498_0_old_nullary 0 closedRest boundRest nullaryRest

def call1498_1 : CallRecord := {
  sourceHash := "ecc82ec37ec282799eca6964836290a5bf58d12fbb5f38da855eb8d009e6efa3"
  predicate := "inv4"
  anchor := 126
  parserOccurrence := 0
  lineage := 126
  owner := "matrix/inv4"
  phase := 0
  sourceBranch := [0]
  semanticProfile := "16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}"
  callee := "util/ordering<Position>/gte"
  sourceName := "ordering/gte"
  kind := "call/formula"
  authority := "TYPECHECKED_IMPORT"
  resultType := "BOOL"
  declaredArity := 2
  nodeTree := "{\"alpha\":\"null\",\"call\":{\"arity\":2,\"authority\":\"TYPECHECKED_IMPORT\",\"callee\":\"util/ordering<Position>/gte\",\"kind\":\"call/formula\",\"occurrence\":0,\"sourceName\":\"ordering/gte\"},\"children\":[{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":129,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":130,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":127,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":133,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":135,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"parts\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":134,\"maxArity\":1,\"metatype\":\"SET\",\"opcode\":\"CLOSURE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"UNOPE_CLOSURE\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":131,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[7:Product]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":132,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":128,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"util/ordering<Position>/gte\",\"lineage\":126,\"maxArity\":2,\"metatype\":\"BOOLEAN\",\"opcode\":\"CALL\",\"parserAncestry\":false,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"ordering/gte\",\"type\":\"BOOL\",\"unordered\":false}"
  scopeBindings := "[{\"cardinality\":\"ONE\",\"id\":0,\"name\":\"_q0\",\"path\":\"root/predicate[0]/decl[0]@pos\",\"quantifier\":\"ALL\",\"sourceNames\":[\"c\",\"var/scope:2/slot:0\"],\"type\":\"RELATION[9:Component]\"}]"
  arguments := [{ exactType := "RELATION[8:Position]", sourceTree := "{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":129,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":130,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":127,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false}", lineage := 127 }, { exactType := "RELATION[8:Position]", sourceTree := "{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[{\"alpha\":\"_q0\",\"children\":[],\"flexible\":false,\"identity\":\"var/scope:2/slot:0\",\"lineage\":133,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"VARIABLE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"c\",\"type\":\"RELATION[9:Component]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":135,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"parts\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":134,\"maxArity\":1,\"metatype\":\"SET\",\"opcode\":\"CLOSURE\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"UNOPE_CLOSURE\",\"type\":\"RELATION[9:Component7:Product]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":131,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[7:Product]\",\"unordered\":false},{\"alpha\":\"null\",\"children\":[],\"flexible\":false,\"identity\":\"null\",\"lineage\":132,\"maxArity\":0,\"metatype\":\"ATOMIC\",\"opcode\":\"GLOBALBINDING\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"position\",\"type\":\"RELATION[9:Component8:Position]\",\"unordered\":false}],\"flexible\":false,\"identity\":\"null\",\"lineage\":128,\"maxArity\":2,\"metatype\":\"SET\",\"opcode\":\"JOIN\",\"parserAncestry\":true,\"semanticProfile\":\"16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}\",\"sourceName\":\"BOPEXPR_JOIN\",\"type\":\"RELATION[8:Position]\",\"unordered\":false}", lineage := 128 }]
}

def call1498_1Registry : List CallRecord := [call1498_1]

theorem call1498_1_source_accept : resolveCall call1498_1Registry call1498_1 = some call1498_1 := source_call_resolves call1498_1 (by decide)

theorem call1498_1_typed_semantics (Value : String → Type)
    (interpret : (call : CallRecord) → Value call.resultType) :
    (resolveCall call1498_1Registry call1498_1).map (callValue Value interpret) = some (callValue Value interpret call1498_1) :=
  resolved_call_evaluation Value interpret call1498_1Registry call1498_1 call1498_1 call1498_1_source_accept

theorem call1498_1_reject_callee : resolveCall call1498_1Registry { call1498_1 with callee := "tampered" } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.callee) (by decide)

theorem call1498_1_reject_resultType : resolveCall call1498_1Registry { call1498_1 with resultType := "INT_TAMPERED" } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.resultType) (by decide)

theorem call1498_1_reject_owner : resolveCall call1498_1Registry { call1498_1 with owner := "foreign-owner" } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.owner) (by decide)

theorem call1498_1_reject_phase : resolveCall call1498_1Registry { call1498_1 with phase := 99 } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.phase) (by decide)

theorem call1498_1_reject_semanticProfile : resolveCall call1498_1Registry { call1498_1 with semanticProfile := "wrong-profile" } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.semanticProfile) (by decide)

theorem call1498_1_reject_anchor : resolveCall call1498_1Registry { call1498_1 with anchor := 999999 } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.anchor) (by decide)

theorem call1498_1_reject_scopeBindings : resolveCall call1498_1Registry { call1498_1 with scopeBindings := "[]" } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.scopeBindings) (by decide)

theorem call1498_1_reject_payload : resolveCall call1498_1Registry { call1498_1 with nodeTree := call1498_1.nodeTree ++ "!" } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.nodeTree) (appended_payload_differs call1498_1.nodeTree)

theorem call1498_1_ambiguous_anchor_rejected : resolveCall [call1498_1, call1498_1] call1498_1 = none := duplicate_call_anchor_rejected call1498_1

def call1498_1ArgumentShapes : List ArgumentShape := [(.join .variable .global), (.join (.join .variable (.closure .global)) .global)]

theorem call1498_1_old_gate_reject : call1498_1ArgumentShapes.all oldArgumentGrammar = false := by decide

theorem call1498_1_argument_order_rejected : resolveCall call1498_1Registry { call1498_1 with arguments := call1498_1.arguments.reverse } = none :=
  singleton_field_mismatch call1498_1 _ (fun c => c.arguments.map CallArgument.lineage) (by decide)

theorem call1498_1_old_closed : oldClosedNecessary call1498_1 = false := by decide

theorem call1498_1_old_bound : oldBoundNecessary call1498_1 call1498_1ArgumentShapes = false := by decide

theorem call1498_1_old_nullary : oldNullaryNecessary call1498_1 = false := by decide

theorem call1498_1_entire_old_gate_rejected (closedRest boundRest nullaryRest : Bool) :
    oldCensusGate call1498_1 call1498_1ArgumentShapes false 0 closedRest boundRest nullaryRest = false :=
  old_census_rejected_by_conjuncts call1498_1 call1498_1ArgumentShapes call1498_1_old_closed call1498_1_old_bound call1498_1_old_nullary 0 closedRest boundRest nullaryRest

def route146_0_source0 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2"
    occurrence := "root/predicate[0]/decl[0]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(User)"
    domain := "19:alloy-binder-domain[1:4:User]{0:}"
    quantifier := "ONE"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def route146_0_source1 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2"
    occurrence := "root/predicate[0]/body[1]/decl[0]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Institution)"
    domain := "19:alloy-binder-domain[1:11:Institution]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 1
  coordinate := 1
  ordinal := 1
}

def route146_0_source2 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2"
    occurrence := "root/predicate[0]/body[1]/decl[1]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Work)"
    domain := "19:alloy-binder-domain[1:4:Work]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 2
  coordinate := 2
  ordinal := 2
}

def route146_0_target0 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2c"
    occurrence := "root/predicate[0]/decl[0]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(User)"
    domain := "19:alloy-binder-domain[1:4:User]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def route146_0Env : Environment := ⟨[route146_0_source0, route146_0_source1, route146_0_source2], [route146_0_target0]⟩
def route146_0Tuples : List (Binding × List String) := [(route146_0_source0, ["ONE", "User", "ONE", "0"]), (route146_0_source1, ["ALL", "Institution", "ONE", "0"]), (route146_0_source2, ["ALL", "Work", "ONE", "0"]), (route146_0_target0, ["ALL", "User", "ONE", "0"])]
def route146_0Tuple (b : Binding) : List String := ((route146_0Tuples.find? (fun pair => pair.1 == b)).map Prod.snd).getD []

def route146_0Candidate : JointCandidate (List String) := {
  source := [⟨0, ["ONE", "User", "ONE", "0"]⟩, ⟨1, ["ALL", "Institution", "ONE", "0"]⟩, ⟨2, ["ALL", "Work", "ONE", "0"]⟩]
  target := [⟨0, ["ALL", "User", "ONE", "0"]⟩]
  declarations := [⟨.delete, 1, some 0, none⟩, ⟨.delete, 1, some 1, none⟩, ⟨.update, 1, some 2, some 0⟩]
  variableReads := []
  otherMatrixCharges := []
  temporalCharges := []
}

theorem route146_0_bound_native_program : boundCandidate route146_0Tuple route146_0Env route146_0Candidate = true := by decide

def route146_0_0 : TypedRoute := ⟨⟨.delete, 1, some 0, none, some ["ONE", "User", "ONE", "0"], none⟩, some route146_0_source0, none⟩

theorem route146_0_0_selected : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 0 (some route146_0_source0) (none) = some route146_0_0 := by decide

theorem route146_0_0_no_orphan : routeRead route146_0_0 route146_0_source0 = none := by decide

def route146_0_1 : TypedRoute := ⟨⟨.delete, 1, some 1, none, some ["ALL", "Institution", "ONE", "0"], none⟩, some route146_0_source1, none⟩

theorem route146_0_1_selected : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 1 (some route146_0_source1) (none) = some route146_0_1 := by decide

theorem route146_0_1_no_orphan : routeRead route146_0_1 route146_0_source1 = none := by decide

def route146_0_2 : TypedRoute := ⟨⟨.update, 1, some 2, some 0, some ["ALL", "Work", "ONE", "0"], some ["ALL", "User", "ONE", "0"]⟩, some route146_0_source2, some route146_0_target0⟩

theorem route146_0_2_selected : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 2 (some route146_0_source2) (some route146_0_target0) = some route146_0_2 := by decide

theorem route146_0_2_target : routeRead route146_0_2 route146_0_source2 = some route146_0_target0 := by decide

theorem route146_0_2_paid : route146_0_2.action.cost = 1 ∧ route146_0_source2.origin.exactType ≠ route146_0_target0.origin.exactType := by decide

theorem route146_0_2_typed_value (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead route146_0_2 route146_0_source2).map (typedRead Value valuation) = some ⟨route146_0_target0.origin.exactType, valuation route146_0_target0⟩ :=
  typed_paid_read Value valuation route146_0_2 route146_0_source2 route146_0_target0 rfl rfl

theorem route146_0_2_reject_owner : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 2 (some { route146_0_source2 with origin := { route146_0_source2.origin with owner := "wrong-owner" } }) (some route146_0_target0) = none := by decide

theorem route146_0_2_reject_phase : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 2 (some { route146_0_source2 with origin := { route146_0_source2.origin with phase := 9 } }) (some route146_0_target0) = none := by decide

theorem route146_0_2_reject_role : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 2 (some { route146_0_source2 with origin := { route146_0_source2.origin with role := "INHERITED" } }) (some route146_0_target0) = none := by decide

theorem route146_0_2_reject_dependencies : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 2 (some { route146_0_source2 with origin := { route146_0_source2.origin with dependencies := [9] } }) (some route146_0_target0) = none := by decide

theorem route146_0_2_reject_exactType : selectedRoute route146_0Tuple route146_0Env route146_0Candidate 2 (some { route146_0_source2 with origin := { route146_0_source2.origin with exactType := "AlloyCarrier(OTHER)" } }) (some route146_0_target0) = none := by decide

def route146_0_sourceUse : MatrixUse := { binding := route146_0_source2, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"certifiedAlternatives\":[],\"children\":[],\"head\":\"[\\\"VARIABLE\\\",null,2,\\\"_q2\\\",\\\"SEQUENCE\\\",false,\\\"[-1, -1, 0]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":2,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q2\\\"}\"}" }

def route146_0_targetUse : MatrixUse := { binding := route146_0_target0, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0", observedType := "Rel(AlloySig:User)", payload := "{\"certifiedAlternatives\":[],\"children\":[],\"head\":\"[\\\"VARIABLE\\\",null,0,\\\"_q0\\\",\\\"SEQUENCE\\\",false,\\\"[-1, -1, 0]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":0,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:User)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q0\\\"}\"}" }

theorem route146_0_selected_matrix_use : selectedMatrixUse route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] route146_0_sourceUse route146_0_targetUse = some route146_0_targetUse :=
  source_matrix_use_accepts route146_0Tuple route146_0Env route146_0Candidate 2 route146_0_sourceUse route146_0_targetUse route146_0_2 route146_0_2_selected

theorem route146_0_selected_matrix_value (Value : String → Type) (valuation : (use : MatrixUse) → Value use.observedType) :
    (selectedMatrixUse route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] route146_0_sourceUse route146_0_targetUse).map (matrixValue Value valuation) = some ⟨route146_0_targetUse.observedType,valuation route146_0_targetUse⟩ :=
  selected_matrix_typed_value route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] route146_0_sourceUse route146_0_targetUse route146_0_selected_matrix_use Value valuation

theorem route146_0_matrix_reject_phase : selectedMatrixUse route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] { route146_0_sourceUse with phase := 9 } route146_0_targetUse = none :=
  foreign_matrix_use_rejected route146_0Tuple route146_0Env route146_0Candidate 2 route146_0_sourceUse _ route146_0_targetUse (fun use => use.phase) (by decide)

theorem route146_0_matrix_reject_typedRole : selectedMatrixUse route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] { route146_0_sourceUse with typedRole := "BINARY_RIGHT" } route146_0_targetUse = none :=
  foreign_matrix_use_rejected route146_0Tuple route146_0Env route146_0Candidate 2 route146_0_sourceUse _ route146_0_targetUse (fun use => use.typedRole) (by decide)

theorem route146_0_matrix_reject_phasePath : selectedMatrixUse route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] { route146_0_sourceUse with phasePath := "phase[1]" } route146_0_targetUse = none :=
  foreign_matrix_use_rejected route146_0Tuple route146_0Env route146_0Candidate 2 route146_0_sourceUse _ route146_0_targetUse (fun use => use.phasePath) (by decide)

theorem route146_0_matrix_reject_nodePath : selectedMatrixUse route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] { route146_0_sourceUse with nodePath := "root/foreign" } route146_0_targetUse = none :=
  foreign_matrix_use_rejected route146_0Tuple route146_0Env route146_0Candidate 2 route146_0_sourceUse _ route146_0_targetUse (fun use => use.nodePath) (by decide)

theorem route146_0_matrix_reject_observedType : selectedMatrixUse route146_0Tuple route146_0Env route146_0Candidate 2 [route146_0_sourceUse] [route146_0_targetUse] { route146_0_sourceUse with observedType := "Rel(AlloySig:OTHER)" } route146_0_targetUse = none :=
  foreign_matrix_use_rejected route146_0Tuple route146_0Env route146_0Candidate 2 route146_0_sourceUse _ route146_0_targetUse (fun use => use.observedType) (by decide)

def route146_0Temporal : Payment := ⟨{ sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", targetHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", predicatePair := "inv2->inv2c", sourceOccurrence := "phase[0]/temporal[0]", targetOccurrence := "", before := "ALWAYS", after := "" }, .temporal, 1⟩

def route146_0Matrix : Payment := ⟨{ sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", targetHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", predicatePair := "inv2->inv2c", sourceOccurrence := "root/child/0", targetOccurrence := "root/child/0", before := "{\"certifiedAlternatives\":[],\"children\":[\"root/child/0/child/0\",\"root/child/0/child/1\"],\"head\":\"[\\\"OR\\\",\\\"identity=;type=Bool\\\",-1,\\\"null\\\",\\\"SET\\\",true,\\\"[-1, -1, 0]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":-1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Bool\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"identity=;type=Bool\\\",\\\"lexicalVariable\\\":\\\"null\\\"}\"}", after := "{\"certifiedAlternatives\":[],\"children\":[\"root/child/0/child/0\",\"root/child/0/child/1\"],\"head\":\"[\\\"IN\\\",\\\"identity=;type=Bool\\\",-1,\\\"null\\\",\\\"SEQUENCE\\\",false,\\\"[-1, -1, 0]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":-1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Bool\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"identity=;type=Bool\\\",\\\"lexicalVariable\\\":\\\"null\\\"}\"}" }, .matrix, 1⟩

def route146_0Payments : List Payment := [routePayment route146_0_0, routePayment route146_0_1, routePayment route146_0_2, route146_0Temporal, route146_0Matrix]
def route146_0Uses : List PaymentUse := (route146_0Payments.map PaymentUse.charge) ++ [.borrow .matrix (routePayment route146_0_2), .borrow .matrix route146_0Temporal]

theorem route146_0_ownership_checked : useCheck route146_0Payments route146_0Uses = true := by decide

theorem route146_0_route_borrows_declaration : paidRouteUse route146_0Payments route146_0_2 = some (.borrow .matrix (routePayment route146_0_2)) := by decide

theorem route146_0_duplicate_route_charge_rejected : useCheck route146_0Payments (route146_0Uses ++ [.charge { routePayment route146_0_2 with owner := .matrix }]) = false := by decide

theorem route146_0_duplicate_temporal_charge_rejected : useCheck route146_0Payments (route146_0Uses ++ [.charge { route146_0Temporal with owner := .matrix }]) = false := by decide

theorem route146_0_missing_charge_rejected : useCheck route146_0Payments (route146_0Uses.drop 1) = false := by decide

theorem route146_0_forged_owner_borrow_rejected : useCheck route146_0Payments (route146_0Uses ++ [.borrow .matrix { route146_0Temporal with owner := .matrix }]) = false := by decide

theorem route146_0_exact_component_total : owned .declaration route146_0Payments = 3 ∧ owned .temporal route146_0Payments = 1 ∧ owned .matrix route146_0Payments = 1 ∧ (route146_0Uses.map useCost).sum = 5 := by decide

def route146_1_source0 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2c"
    occurrence := "root/predicate[0]/decl[0]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(User)"
    domain := "19:alloy-binder-domain[1:4:User]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def route146_1_target0 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2"
    occurrence := "root/predicate[0]/decl[0]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(User)"
    domain := "19:alloy-binder-domain[1:4:User]{0:}"
    quantifier := "ONE"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 0
  coordinate := 0
  ordinal := 0
}

def route146_1_target1 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2"
    occurrence := "root/predicate[0]/body[1]/decl[0]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Institution)"
    domain := "19:alloy-binder-domain[1:11:Institution]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 1
  coordinate := 1
  ordinal := 1
}

def route146_1_target2 : Binding := {
  origin := {
    sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
    predicate := "inv2"
    occurrence := "root/predicate[0]/body[1]/decl[1]@pos"
    owner := ""
    phase := 0
    role := "MATRIX"
    branch := []
    dependencies := []
    exactType := "AlloyCarrier(Work)"
    domain := "19:alloy-binder-domain[1:4:Work]{0:}"
    quantifier := "ALL"
    cardinality := "ONE"
    disjointness := 0
  }
  vectorIndex := 2
  coordinate := 2
  ordinal := 2
}

def route146_1Env : Environment := ⟨[route146_1_source0], [route146_1_target0, route146_1_target1, route146_1_target2]⟩
def route146_1Tuples : List (Binding × List String) := [(route146_1_source0, ["ALL", "User", "ONE", "0"]), (route146_1_target0, ["ONE", "User", "ONE", "0"]), (route146_1_target1, ["ALL", "Institution", "ONE", "0"]), (route146_1_target2, ["ALL", "Work", "ONE", "0"])]
def route146_1Tuple (b : Binding) : List String := ((route146_1Tuples.find? (fun pair => pair.1 == b)).map Prod.snd).getD []

def route146_1Candidate : JointCandidate (List String) := {
  source := [⟨0, ["ALL", "User", "ONE", "0"]⟩]
  target := [⟨0, ["ONE", "User", "ONE", "0"]⟩, ⟨1, ["ALL", "Institution", "ONE", "0"]⟩, ⟨2, ["ALL", "Work", "ONE", "0"]⟩]
  declarations := [⟨.insert, 1, none, some 0⟩, ⟨.insert, 1, none, some 1⟩, ⟨.update, 1, some 0, some 2⟩]
  variableReads := []
  otherMatrixCharges := []
  temporalCharges := []
}

theorem route146_1_bound_native_program : boundCandidate route146_1Tuple route146_1Env route146_1Candidate = true := by decide

def route146_1_0 : TypedRoute := ⟨⟨.insert, 1, none, some 0, none, some ["ONE", "User", "ONE", "0"]⟩, none, some route146_1_target0⟩

theorem route146_1_0_selected : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 0 (none) (some route146_1_target0) = some route146_1_0 := by decide

theorem route146_1_0_does_not_capture : routeRead route146_1_0 route146_1_source0 = some route146_1_source0 := by decide

def route146_1_1 : TypedRoute := ⟨⟨.insert, 1, none, some 1, none, some ["ALL", "Institution", "ONE", "0"]⟩, none, some route146_1_target1⟩

theorem route146_1_1_selected : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 1 (none) (some route146_1_target1) = some route146_1_1 := by decide

theorem route146_1_1_does_not_capture : routeRead route146_1_1 route146_1_source0 = some route146_1_source0 := by decide

def route146_1_2 : TypedRoute := ⟨⟨.update, 1, some 0, some 2, some ["ALL", "User", "ONE", "0"], some ["ALL", "Work", "ONE", "0"]⟩, some route146_1_source0, some route146_1_target2⟩

theorem route146_1_2_selected : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 2 (some route146_1_source0) (some route146_1_target2) = some route146_1_2 := by decide

theorem route146_1_2_target : routeRead route146_1_2 route146_1_source0 = some route146_1_target2 := by decide

theorem route146_1_2_paid : route146_1_2.action.cost = 1 ∧ route146_1_source0.origin.exactType ≠ route146_1_target2.origin.exactType := by decide

theorem route146_1_2_typed_value (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead route146_1_2 route146_1_source0).map (typedRead Value valuation) = some ⟨route146_1_target2.origin.exactType, valuation route146_1_target2⟩ :=
  typed_paid_read Value valuation route146_1_2 route146_1_source0 route146_1_target2 rfl rfl

theorem route146_1_2_reject_owner : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 2 (some { route146_1_source0 with origin := { route146_1_source0.origin with owner := "wrong-owner" } }) (some route146_1_target2) = none := by decide

theorem route146_1_2_reject_phase : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 2 (some { route146_1_source0 with origin := { route146_1_source0.origin with phase := 9 } }) (some route146_1_target2) = none := by decide

theorem route146_1_2_reject_role : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 2 (some { route146_1_source0 with origin := { route146_1_source0.origin with role := "INHERITED" } }) (some route146_1_target2) = none := by decide

theorem route146_1_2_reject_dependencies : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 2 (some { route146_1_source0 with origin := { route146_1_source0.origin with dependencies := [9] } }) (some route146_1_target2) = none := by decide

theorem route146_1_2_reject_exactType : selectedRoute route146_1Tuple route146_1Env route146_1Candidate 2 (some { route146_1_source0 with origin := { route146_1_source0.origin with exactType := "AlloyCarrier(OTHER)" } }) (some route146_1_target2) = none := by decide

def route146_1_sourceUse : MatrixUse := { binding := route146_1_source0, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0", observedType := "Rel(AlloySig:User)", payload := "{\"certifiedAlternatives\":[],\"children\":[],\"head\":\"[\\\"VARIABLE\\\",null,0,\\\"_q0\\\",\\\"SEQUENCE\\\",false,\\\"[2]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":0,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:User)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q0\\\"}\"}" }

def route146_1_targetUse : MatrixUse := { binding := route146_1_target2, phase := 0, typedRole := "NONE", phasePath := "phase[0]", nodePath := "root/child/0/child/0/child/0", observedType := "Rel(AlloySig:Work)", payload := "{\"certifiedAlternatives\":[],\"children\":[],\"head\":\"[\\\"VARIABLE\\\",null,2,\\\"_q2\\\",\\\"SEQUENCE\\\",false,\\\"[2]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":2,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Rel(AlloySig:Work)\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"null\\\",\\\"lexicalVariable\\\":\\\"_q2\\\"}\"}" }

theorem route146_1_selected_matrix_use : selectedMatrixUse route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] route146_1_sourceUse route146_1_targetUse = some route146_1_targetUse :=
  source_matrix_use_accepts route146_1Tuple route146_1Env route146_1Candidate 2 route146_1_sourceUse route146_1_targetUse route146_1_2 route146_1_2_selected

theorem route146_1_selected_matrix_value (Value : String → Type) (valuation : (use : MatrixUse) → Value use.observedType) :
    (selectedMatrixUse route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] route146_1_sourceUse route146_1_targetUse).map (matrixValue Value valuation) = some ⟨route146_1_targetUse.observedType,valuation route146_1_targetUse⟩ :=
  selected_matrix_typed_value route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] route146_1_sourceUse route146_1_targetUse route146_1_selected_matrix_use Value valuation

theorem route146_1_matrix_reject_phase : selectedMatrixUse route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] { route146_1_sourceUse with phase := 9 } route146_1_targetUse = none :=
  foreign_matrix_use_rejected route146_1Tuple route146_1Env route146_1Candidate 2 route146_1_sourceUse _ route146_1_targetUse (fun use => use.phase) (by decide)

theorem route146_1_matrix_reject_typedRole : selectedMatrixUse route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] { route146_1_sourceUse with typedRole := "BINARY_RIGHT" } route146_1_targetUse = none :=
  foreign_matrix_use_rejected route146_1Tuple route146_1Env route146_1Candidate 2 route146_1_sourceUse _ route146_1_targetUse (fun use => use.typedRole) (by decide)

theorem route146_1_matrix_reject_phasePath : selectedMatrixUse route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] { route146_1_sourceUse with phasePath := "phase[1]" } route146_1_targetUse = none :=
  foreign_matrix_use_rejected route146_1Tuple route146_1Env route146_1Candidate 2 route146_1_sourceUse _ route146_1_targetUse (fun use => use.phasePath) (by decide)

theorem route146_1_matrix_reject_nodePath : selectedMatrixUse route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] { route146_1_sourceUse with nodePath := "root/foreign" } route146_1_targetUse = none :=
  foreign_matrix_use_rejected route146_1Tuple route146_1Env route146_1Candidate 2 route146_1_sourceUse _ route146_1_targetUse (fun use => use.nodePath) (by decide)

theorem route146_1_matrix_reject_observedType : selectedMatrixUse route146_1Tuple route146_1Env route146_1Candidate 2 [route146_1_sourceUse] [route146_1_targetUse] { route146_1_sourceUse with observedType := "Rel(AlloySig:OTHER)" } route146_1_targetUse = none :=
  foreign_matrix_use_rejected route146_1Tuple route146_1Env route146_1Candidate 2 route146_1_sourceUse _ route146_1_targetUse (fun use => use.observedType) (by decide)

def route146_1Temporal : Payment := ⟨{ sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", targetHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", predicatePair := "inv2c->inv2", sourceOccurrence := "", targetOccurrence := "phase[0]/temporal[0]", before := "", after := "ALWAYS" }, .temporal, 1⟩

def route146_1Matrix : Payment := ⟨{ sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", targetHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4", predicatePair := "inv2c->inv2", sourceOccurrence := "root/child/0", targetOccurrence := "root/child/0", before := "{\"certifiedAlternatives\":[],\"children\":[\"root/child/0/child/0\",\"root/child/0/child/1\"],\"head\":\"[\\\"IN\\\",\\\"identity=;type=Bool\\\",-1,\\\"null\\\",\\\"SEQUENCE\\\",false,\\\"[2]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":-1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Bool\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"identity=;type=Bool\\\",\\\"lexicalVariable\\\":\\\"null\\\"}\"}", after := "{\"certifiedAlternatives\":[],\"children\":[\"root/child/0/child/0\",\"root/child/0/child/1\"],\"head\":\"[\\\"OR\\\",\\\"identity=;type=Bool\\\",-1,\\\"null\\\",\\\"SET\\\",true,\\\"[2]\\\"]\",\"nativeEvidence\":\"{\\\"bindingIndex\\\":-1,\\\"observationPhases\\\":[],\\\"observationTemporalOperator\\\":\\\"null\\\",\\\"observationType\\\":\\\"Bool\\\",\\\"payload\\\":\\\"null\\\",\\\"semanticPayload\\\":\\\"identity=;type=Bool\\\",\\\"lexicalVariable\\\":\\\"null\\\"}\"}" }, .matrix, 1⟩

def route146_1Payments : List Payment := [routePayment route146_1_0, routePayment route146_1_1, routePayment route146_1_2, route146_1Temporal, route146_1Matrix]
def route146_1Uses : List PaymentUse := (route146_1Payments.map PaymentUse.charge) ++ [.borrow .matrix (routePayment route146_1_2), .borrow .matrix route146_1Temporal]

theorem route146_1_ownership_checked : useCheck route146_1Payments route146_1Uses = true := by decide

theorem route146_1_route_borrows_declaration : paidRouteUse route146_1Payments route146_1_2 = some (.borrow .matrix (routePayment route146_1_2)) := by decide

theorem route146_1_duplicate_route_charge_rejected : useCheck route146_1Payments (route146_1Uses ++ [.charge { routePayment route146_1_2 with owner := .matrix }]) = false := by decide

theorem route146_1_duplicate_temporal_charge_rejected : useCheck route146_1Payments (route146_1Uses ++ [.charge { route146_1Temporal with owner := .matrix }]) = false := by decide

theorem route146_1_missing_charge_rejected : useCheck route146_1Payments (route146_1Uses.drop 1) = false := by decide

theorem route146_1_forged_owner_borrow_rejected : useCheck route146_1Payments (route146_1Uses ++ [.borrow .matrix { route146_1Temporal with owner := .matrix }]) = false := by decide

theorem route146_1_exact_component_total : owned .declaration route146_1Payments = 3 ∧ owned .temporal route146_1Payments = 1 ∧ owned .matrix route146_1Payments = 1 ∧ (route146_1Uses.map useCost).sum = 5 := by decide

end Focused225ConcreteWitnesses
