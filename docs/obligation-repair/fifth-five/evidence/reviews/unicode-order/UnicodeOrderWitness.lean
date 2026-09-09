import Std
namespace UnicodeOrderWitness
def supplementary : String := String.ofList [Char.ofNat 65536]
def bmp : String := String.ofList [Char.ofNat 57344]
theorem scalar_order : compare supplementary bmp = Ordering.gt := by decide
#print axioms scalar_order
end UnicodeOrderWitness
