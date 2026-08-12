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

pred cap002379 { not ((inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((some CapBenchA and some capBenchS) or some CapBenchA)) }
pred cap002379c { ((not (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) or (not ((some CapBenchA and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap002379 { cap002379 iff cap002379c }
check CapBenchEquivalent_cap002379 for 4
