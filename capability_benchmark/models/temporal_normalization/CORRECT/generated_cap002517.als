sig Node {
	adj : set Node
}
pred inv2 {
all n1,n2:Node | n1->n2 in adj implies n2->n1 not in adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002517 { not (((inv2 and ((some CapBenchB or no CapBenchA) or some CapBenchA))) since (((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap002517c { ((not (inv2 and ((some CapBenchB or no CapBenchA) or some CapBenchA))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002517 { cap002517 iff cap002517c }
check CapBenchEquivalent_cap002517 for 4
