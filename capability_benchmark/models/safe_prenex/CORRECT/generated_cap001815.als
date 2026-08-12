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

pred cap001815 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap001815c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap001815 { cap001815 iff cap001815c }
check CapBenchEquivalent_cap001815 for 4
