import GuardedJoinDuplicate
namespace GuardedJoinDuplicateObserved
open GuardedJoinDuplicate
-- Bound semantic-object extraction SHA256: c660f1826d770aca0b4cc37a68667eff97ee26a38a27b9881e790b1804640036
def sourceAtom : DomainAtom := ⟨⟨"IN", "BOOL", "root/predicate[0]/or[2]/local-decl[0]", ["root/predicate[0]/decl[0]@pos"], [0, 2, 1], 0, ["EMPTY_RELATION[arity=1]", "RELATION[6:Course6:Person5:Grade]", "RELATION[5:Grade]", "RELATION[6:Course]", "RELATION[6:Course6:Person]", "EMPTY_RELATION[arity=1]"]⟩, ⟨"_l3", "root/predicate[0]/or[2]/local-decl[0]", "var/scope:3/slot:0", "EMPTY_RELATION[arity=1]"⟩, ⟨"_q0", "root/predicate[0]/decl[0]@pos", "var/scope:2/slot:0", "RELATION[6:Course]"⟩, "RELATION[6:Course6:Person5:Grade]", "RELATION[5:Grade]", "RELATION[6:Course6:Person]", "EMPTY_RELATION[arity=1]", "3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da"⟩
def retainedAtom : DomainAtom := ⟨⟨"IN", "BOOL", "root/predicate[0]/or[2]/local-decl[0]", ["root/predicate[0]/decl[0]@pos"], [0, 2, 1], 0, ["EMPTY_RELATION[arity=1]", "RELATION[6:Course6:Person5:Grade]", "RELATION[5:Grade]", "RELATION[6:Course]", "RELATION[6:Course6:Person]", "EMPTY_RELATION[arity=1]"]⟩, ⟨"_l3", "root/predicate[0]/or[2]/local-decl[0]", "var/scope:3/slot:0", "EMPTY_RELATION[arity=1]"⟩, ⟨"_q0", "root/predicate[0]/decl[0]@pos", "var/scope:2/slot:0", "RELATION[6:Course]"⟩, "RELATION[6:Course6:Person5:Grade]", "RELATION[5:Grade]", "RELATION[6:Course6:Person]", "EMPTY_RELATION[arity=1]", "3bdad8f587b547cbce4cc60b65ddc2e165a1a8cbfaf6b42ca9e54a5fe4b7f5da"⟩
def sourcePath : List Nat := [0, 2, 1, 1]
def retainedPath : List Nat := [0, 2, 1, 0, 1]
def localCount : Nat := 2
theorem decoded_atoms_equal : sourceAtom = retainedAtom := by decide
end GuardedJoinDuplicateObserved
