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

pred cap005360 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchA and some capBenchS) or some capBenchS)) and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
pred cap005360c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchA) or some CapBenchA)) or (not (inv3 and ((some CapBenchA and some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap005360 { cap005360 iff cap005360c }
check CapBenchEquivalent_cap005360 for 4
