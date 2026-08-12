sig Node {
	adj : set Node
}
pred inv8 {
all n1,n2,n3:Node | n1->n2 in adj and n2->n3 in adj implies n1->n3 in adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005184 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((some capBenchS or some capBenchR) or some capBenchS))) }
pred cap005184c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchR) or some capBenchS)) or (not (inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005184 { cap005184 iff cap005184c }
check CapBenchEquivalent_cap005184 for 4
