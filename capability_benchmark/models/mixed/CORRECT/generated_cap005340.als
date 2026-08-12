sig Node {
	adj : set Node
}
pred inv3 {
all n:Node | n not in n.^adj
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

pred cap005340 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchR and no CapBenchA) or some capBenchS)) and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
pred cap005340c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchA) or some CapBenchA)) or (not (inv3 and ((some capBenchR and no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap005340 { cap005340 iff cap005340c }
check CapBenchEquivalent_cap005340 for 4
