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

pred cap005317 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005317c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv8 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap005317 { cap005317 iff cap005317c }
check CapBenchEquivalent_cap005317 for 4
