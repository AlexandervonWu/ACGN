import UnaryRelationPort

/- Source syntax disambiguates overloaded unary/binder opcodes. This is a
   representation law: the source child, order, owner and interpretation stay
   unchanged. Source grammar recognition is checked separately against Java. -/
namespace UnarySourceArity
open UnaryRelationPort

def unarySyntax (code : Int) : Bool := code == -6 || code == 6 || code == 16

def flexible (code : Int) (unaryOpcode old : Bool) : Bool :=
  if unaryOpcode && unarySyntax code then false else old

theorem unary_fixed (code : Int) (old : Bool) (h : unarySyntax code = true) :
    flexible code true old = false := by simp [flexible, h]

theorem other_syntax_unchanged (code : Int) (opcode old : Bool)
    (h : unarySyntax code = false) : flexible code opcode old = old := by
  simp [flexible, h]

theorem other_opcode_unchanged (code : Int) (old : Bool) :
    flexible code false old = old := by simp [flexible]

theorem singleton_encoding (child : A) :
    decode .one [child] = decode .sequence [child] := rfl

theorem singleton_semantics (child : A) (interpret : List A → Result) :
    (decode .one [child]).map interpret = (decode .sequence [child]).map interpret := rfl

theorem singleton_context (child : A) (interpret : List A → Result)
    (context : Option Result → Output) :
    context ((decode .one [child]).map interpret) =
      context ((decode .sequence [child]).map interpret) := rfl

theorem formula_source : flexible (-6) true true = false := by decide
theorem expression_source : flexible 6 true true = false := by decide
theorem expression_variant_source : flexible 16 true true = false := by decide
theorem formula_binder_retained : flexible (-3) true true = true := by decide
theorem expression_binder_retained : flexible 3 true true = true := by decide
theorem declaration_retained : flexible (-127) true true = true := by decide
theorem ordinary_sequence_retained : flexible 4 false true = true := by decide

#print axioms unary_fixed
#print axioms singleton_semantics
#print axioms singleton_context
#print axioms formula_binder_retained
end UnarySourceArity
