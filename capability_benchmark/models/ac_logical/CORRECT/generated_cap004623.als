sig Node {
	adj : set Node
}
pred inv3 {
all n : Node | n not in n.^adj

no (^adj & iden)

iden - ^adj = iden
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004623 { not ((inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((some CapBenchA and some capBenchS) or some capBenchR)) }
pred cap004623c { ((not ((some CapBenchA and some capBenchS) or some capBenchR)) or (not (inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004623 { cap004623 iff cap004623c }
check CapBenchEquivalent_cap004623 for 4
