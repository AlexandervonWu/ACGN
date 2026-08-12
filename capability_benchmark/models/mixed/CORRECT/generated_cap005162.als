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

pred cap005162 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchA and some capBenchR) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) }
pred cap005162c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS)) or (not (inv3 and ((no CapBenchA and some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005162 { cap005162 iff cap005162c }
check CapBenchEquivalent_cap005162 for 4
