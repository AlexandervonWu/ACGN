import RetainedDomainAdmission
import Focused225CallViewWitnesses

namespace RetainedDomainWitnesses
open RetainedDomainAdmission Focused225CallViews ScopedCallCorrespondence
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

def domain0Frame : Frame := { sourceHash := "25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", predicate := "inv4", owner := 384, parent := 0, phase := 0, declaration := 387, domain := 391, kind := "EXISTS", type := "RELATION[8:Position]", slots := [⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/or[1]/local-decl[0]","[3,[\"pos\",\"var/scope:4/slot:0\"],\"SOME\",\"ONE\"]","RELATION[8:Position]",0⟩], enclosing := [⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/decl[0]@pos","[0,[\"c\",\"var/scope:2/slot:0\"],\"ALL\",\"ONE\"]","RELATION[9:Component]",0⟩, ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/body[1]/decl[0]@pos","[1,[\"p\",\"var/scope:3/slot:0\"],\"ALL\",\"ONE\"]","RELATION[7:Product]",0⟩] }
def domain0CurrentFrame : Frame := { sourceHash := "25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677", predicate := "inv4", owner := 384, parent := 0, phase := 0, declaration := 387, domain := 391, kind := "EXISTS", type := "RELATION[8:Position]", slots := [⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/or[1]/local-decl[0]","[3,[\"pos\",\"var/scope:4/slot:0\"],\"SOME\",\"ONE\"]","RELATION[8:Position]",0⟩], enclosing := [⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/decl[0]@pos","[0,[\"c\",\"var/scope:2/slot:0\"],\"ALL\",\"ONE\"]","RELATION[9:Component]",0⟩, ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/body[1]/decl[0]@pos","[1,[\"p\",\"var/scope:3/slot:0\"],\"ALL\",\"ONE\"]","RELATION[7:Product]",0⟩] }
theorem domain0_independent_frames_agree : domain0Frame = domain0CurrentFrame := by decide +kernel

def domain0Key : SourceKey := ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677","inv4",391,387,"384",0,[0,1,0,0]⟩
def domain0Term : Shape := (.node ⟨"ONE","UNOPE_ONE","null","RELATION[8:Position]",391,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "true", "-1"]⟩ (.cons (.node ⟨"CALL","ordering/prevs","util/ordering<Position>/prevs","RELATION[8:Position]",395,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "1", "util/ordering<Position>/prevs", "call/expression", "1", "TYPECHECKED_IMPORT", "0", "captured-opaque-anchor:0", "6e0b2cca9837d3ca74f7f6b1af2cc47faa2dde2c101c7a1771e9aaa17bd6afb7"]⟩ (.cons (.node ⟨"JOIN","BOPEXPR_JOIN","null","RELATION[8:Position]",400,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "2"]⟩ (.cons (.node ⟨"VARIABLE","c","var/scope:2/slot:0","RELATION[9:Component]",406,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ (.cons (.variable ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/decl[0]@pos","[0,[\"c\",\"var/scope:2/slot:0\"],\"ALL\",\"ONE\"]","RELATION[9:Component]",0⟩) .nil)) (.cons (.node ⟨"GLOBALBINDING","position","null","RELATION[9:Component8:Position]",407,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ .nil) .nil))) .nil)) .nil))

def domain0View0 : View := { key := domain0Key, scope := [("_q0",⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/decl[0]@pos","[0,[\"c\",\"var/scope:2/slot:0\"],\"ALL\",\"ONE\"]","RELATION[9:Component]",0⟩), ("_q1",⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/body[1]/decl[0]@pos","[1,[\"p\",\"var/scope:3/slot:0\"],\"ALL\",\"ONE\"]","RELATION[7:Product]",0⟩)], initial := [("_q0", "_q0")], ancestry := [], call := (.node ⟨"ONE","UNOPE_ONE","null","RELATION[8:Position]",391,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "true", "-1"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.node ⟨"CALL","ordering/prevs","util/ordering<Position>/prevs","RELATION[8:Position]",395,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "1", "util/ordering<Position>/prevs", "call/expression", "1", "TYPECHECKED_IMPORT", "0", "captured-opaque-anchor:0", "6e0b2cca9837d3ca74f7f6b1af2cc47faa2dde2c101c7a1771e9aaa17bd6afb7"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.node ⟨"JOIN","BOPEXPR_JOIN","null","RELATION[8:Position]",400,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "2"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.variable ⟨"VARIABLE","c","var/scope:2/slot:0","RELATION[9:Component]",406,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ "_q0" ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩) (.cons (.node ⟨"GLOBALBINDING","position","null","RELATION[9:Component8:Position]",407,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ ⟨[],[]⟩ .nil) .nil))) .nil)) .nil)) }

theorem domain0View0_resolved : resolved domain0View0 = some domain0Term := by decide +kernel

theorem domain0View0_accepted : check domain0Frame domain0CurrentFrame [domain0View0] domain0View0 = some domain0Term := by decide +kernel

def domain0View1 : View := { key := domain0Key, scope := [("_q0",⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/decl[0]@pos","[0,[\"c\",\"var/scope:2/slot:0\"],\"ALL\",\"ONE\"]","RELATION[9:Component]",0⟩), ("_q1",⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/body[1]/decl[0]@pos","[1,[\"p\",\"var/scope:3/slot:0\"],\"ALL\",\"ONE\"]","RELATION[7:Product]",0⟩)], initial := [("_q0", "_q0")], ancestry := [], call := (.node ⟨"ONE","UNOPE_ONE","null","RELATION[8:Position]",391,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "true", "-1"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.node ⟨"CALL","ordering/prevs","util/ordering<Position>/prevs","RELATION[8:Position]",395,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "1", "util/ordering<Position>/prevs", "call/expression", "1", "TYPECHECKED_IMPORT", "0", "captured-opaque-anchor:0", "6e0b2cca9837d3ca74f7f6b1af2cc47faa2dde2c101c7a1771e9aaa17bd6afb7"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.node ⟨"JOIN","BOPEXPR_JOIN","null","RELATION[8:Position]",400,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "2"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.variable ⟨"VARIABLE","c","var/scope:2/slot:0","RELATION[9:Component]",406,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ "_q0" ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩) (.cons (.node ⟨"GLOBALBINDING","position","null","RELATION[9:Component8:Position]",407,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ ⟨[],[]⟩ .nil) .nil))) .nil)) .nil)) }

theorem domain0View1_resolved : resolved domain0View1 = some domain0Term := by decide +kernel

theorem domain0View1_accepted : check domain0Frame domain0CurrentFrame [domain0View0] domain0View1 = some domain0Term := by decide +kernel

theorem domain0_well_scoped : wellFormed domain0Frame domain0Term = true := by decide +kernel

theorem domain0_decoded : (decode domain0Term).isSome = true := by decide +kernel

theorem domain0_old_rejected (globalRest minusRest : Bool) : oldExpressionGate "CALL" globalRest minusRest = false := old_call_rejected globalRest minusRest

theorem domain0_reject_owner : check domain0Frame { domain0CurrentFrame with owner := 385 } [domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_reject_parent : check domain0Frame { domain0CurrentFrame with parent := 1 } [domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_reject_phase : check domain0Frame { domain0CurrentFrame with phase := 1 } [domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_reject_domain : check domain0Frame { domain0CurrentFrame with domain := 392 } [domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_reject_type : check domain0Frame { domain0CurrentFrame with type := "foreign-type" } [domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_reject_slots : check domain0Frame { domain0CurrentFrame with slots := [] } [domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_reject_enclosing : check domain0Frame { domain0CurrentFrame with enclosing := [] } [domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_missing_source : check domain0Frame domain0Frame [] domain0View1 = none := by decide +kernel

theorem domain0_ambiguous_source : check domain0Frame domain0Frame [domain0View0,domain0View0] domain0View1 = none := by decide +kernel

theorem domain0_wrong_slot_type : check domain0Frame domain0Frame [domain0View0] { domain0View1 with scope := domain0View1.scope.map (fun e => (e.1,{ e.2 with type := "foreign-type" })) } = none := by decide +kernel

theorem domain0_wrong_dependency_owner : check domain0Frame domain0Frame [domain0View0] { domain0View1 with scope := domain0View1.scope.map (fun e => (e.1,{ e.2 with owner := "foreign-owner" })) } = none := by decide +kernel

theorem domain0_wrong_source_key : check domain0Frame domain0Frame [domain0View0] { domain0View1 with key := { domain0Key with sourceHash := "foreign-source" } } = none := by decide +kernel

def domain0SiblingView : View := { domain0View0 with scope := domain0View0.scope.map (fun e => (e.1,{ e.2 with owner := "foreign-sibling-owner" })) }
theorem domain0_same_tree_sibling_rejected : check domain0Frame domain0CurrentFrame [domain0SiblingView] domain0SiblingView = none := by decide +kernel

def domain0ForeignAnchor : View := { domain0View1 with call := (.node ⟨"ONE","UNOPE_ONE","null","RELATION[8:Position]",391,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "true", "-1"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.node ⟨"CALL","ordering/prevs","util/ordering<Position>/prevs","RELATION[8:Position]",395,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "1", "util/ordering<Position>/prevs", "call/expression", "1", "TYPECHECKED_IMPORT", "0", "foreign-opaque-anchor", "6e0b2cca9837d3ca74f7f6b1af2cc47faa2dde2c101c7a1771e9aaa17bd6afb7"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.node ⟨"JOIN","BOPEXPR_JOIN","null","RELATION[8:Position]",400,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "2"]⟩ ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩ (.cons (.variable ⟨"VARIABLE","c","var/scope:2/slot:0","RELATION[9:Component]",406,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ "_q0" ⟨[("_q0", "_q0")],[("_q0", "_q0")]⟩) (.cons (.node ⟨"GLOBALBINDING","position","null","RELATION[9:Component8:Position]",407,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "ATOMIC", "false", "false", "0"]⟩ ⟨[],[]⟩ .nil) .nil))) .nil)) .nil)) }
theorem domain0_foreign_anchor_rejected : check domain0Frame domain0CurrentFrame [domain0View0] domain0ForeignAnchor = none := by decide +kernel

theorem domain0_self_capture_rejected : wellFormed domain0Frame (.node ⟨"ONE","UNOPE_ONE","null","RELATION[8:Position]",391,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "true", "-1"]⟩ (.cons (.node ⟨"CALL","ordering/prevs","util/ordering<Position>/prevs","RELATION[8:Position]",395,["16:semantic-profile[5:1:46:FORBID14:alloy-temporal23:repaired-normal-form-v218:alloy-signature-v2]{0:}", "SET", "false", "false", "1", "util/ordering<Position>/prevs", "call/expression", "1", "TYPECHECKED_IMPORT", "0", "captured-opaque-anchor:0", "6e0b2cca9837d3ca74f7f6b1af2cc47faa2dde2c101c7a1771e9aaa17bd6afb7"]⟩ (.cons (.variable ⟨"25767bf1348b465e7fe4765f16acc3457db759331e418c5d40ecc76c1788a677:inv4:root/predicate[0]/or[1]/local-decl[0]","[3,[\"pos\",\"var/scope:4/slot:0\"],\"SOME\",\"ONE\"]","RELATION[8:Position]",0⟩) .nil)) .nil)) = false := by decide +kernel

theorem domain0_semantic_retention {V : Type} (env : Slot → V) (op : Head → List V → V) :
    ∃ original, sourceAt [domain0View0] domain0View1.key = some original ∧
      ((resolved original).bind decode).map (eval env op) = ((resolved domain0View1).bind decode).map (eval env op) :=
  checked_domain_evaluation env op domain0Frame domain0CurrentFrame [domain0View0] domain0View1 domain0Term domain0View1_accepted

end RetainedDomainWitnesses
