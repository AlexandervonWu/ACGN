import RetainedLexicalResolution

/- Generated from immutable event248 scope and collision probes. Object tokens
   0 and 1 denote the two distinct references observed by Java's != check, not
   serialized IDs promoted to live reference authority. Capture-local lineage
   numbers from different probes are deliberately not equated. -/
namespace RetainedLexicalWitnesses
open RetainedLexicalResolution Focused225CallViews

def binding0 : Ref :=
  ⟨0, ⟨⟨"56db843ecbc8042d5f61db6f31287f3d1ae483a5ab2076fd10ee8783e86a1cce", "inv7c", "_l7",
    "root/predicate[0]/or[0]/not_in[1]/join[1]/closure[0]/local-decl[0]", 0, "LOCAL", [], [], "RELATION[5:State]",
    "13:GLOBALBINDING[3:21:alloy/signature/State17:RELATION[5:State]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "COMPREHENSION", "ONE", 0⟩,
    0, 0, 7⟩⟩

def binding1 : Ref :=
  ⟨1, ⟨⟨"56db843ecbc8042d5f61db6f31287f3d1ae483a5ab2076fd10ee8783e86a1cce", "inv7c", "_l10",
    "root/predicate[0]/or[1]/some[0]/intersect[1]/join[1]/closure[0]/local-decl[0]", 0, "LOCAL", [], [], "RELATION[5:State]",
    "13:GLOBALBINDING[3:21:alloy/signature/State17:RELATION[5:State]64:3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da]{0:}", "COMPREHENSION", "ONE", 0⟩,
    1, 0, 10⟩⟩

def alias : String := "@fast-local:0:0"
def identity : SlotMap := [(alias, alias)]
def first : Context := [(alias, binding0)]
def second : Context := [(alias, binding1)]

theorem old_global_rejects : oldInsert first alias binding1 = none := by decide
theorem first_owner_accepts : resolveUse [first] identity [] alias binding0 = some binding0 := by simp [resolveUse, ancestors, lookup, checkName, first, identity]
theorem second_owner_accepts : resolveUse [second] identity [] alias binding1 = some binding1 := by simp [resolveUse, ancestors, lookup, checkName, second, identity]
theorem wrong_owner_rejected : resolveUse [second] identity [] alias binding0 = none := by decide
theorem union_of_contexts_rejected : resolveUse [first, second] identity [] alias binding0 = none := by 
  have different : binding1 ≠ binding0 := by decide
  simp [resolveUse, ancestors, lookup, checkName, first, second, identity, different]
theorem absent_alias_rejected : resolveUse [first] [(alias, "foreign")] [] alias binding0 = none := by decide
theorem repeated_visit_accepts : resolveUse [first, first] identity [] alias binding0 = some binding0 := by simp [resolveUse, ancestors, lookup, checkName, first, identity]
theorem foreign_object_rejected :
    resolveUse [[(alias, { binding0 with object := 99 })]] identity [] alias binding0 = none := by decide
theorem altered_phase_rejected :
    resolveUse [[(alias, { binding0 with data.origin.phase := 1 })]] identity [] alias binding0 = none := by decide
theorem altered_dependencies_rejected :
    resolveUse [[(alias, { binding0 with data.origin.dependencies := [1] })]] identity [] alias binding0 = none := by decide

theorem both_reads_preserved (V : Type) (valuation : Ref → V) :
    (resolveUse [first] identity [] alias binding0).map valuation = some (valuation binding0) ∧
    (resolveUse [second] identity [] alias binding1).map valuation = some (valuation binding1) := by
  rw [first_owner_accepts, second_owner_accepts]
  exact ⟨rfl, rfl⟩

end RetainedLexicalWitnesses
