import Std

/- The lexer supplies the module-name span. The writer must preserve every
   character outside that span; absent a module header it preserves all input.
   Lexer correctness and Java substring offsets are separately tested. -/
namespace AugmentedPrelude

def rename (before name suffix : List Char) : List Char := before ++ name ++ suffix
def addHeader (name body : List Char) : List Char :=
  "module ".toList ++ name ++ ['\n'] ++ body

theorem rename_preserves_prefix (before old replacement suffix : List Char) :
    (rename before replacement suffix).take before.length =
      (rename before old suffix).take before.length := by
  simp [rename, List.append_assoc]

theorem rename_preserves_suffix (before replacement suffix : List Char) :
    (rename before replacement suffix).drop (before.length + replacement.length) = suffix := by
  simp [rename, List.drop_append]

theorem absent_header_preserves_all (name body : List Char) :
    (addHeader name body).drop (("module ".toList ++ name ++ ['\n']).length) = body := by
  simp [addHeader]

#print axioms rename_preserves_prefix
#print axioms rename_preserves_suffix
#print axioms absent_header_preserves_all
end AugmentedPrelude
