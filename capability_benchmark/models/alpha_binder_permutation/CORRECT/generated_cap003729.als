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

pred cap003729 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or some capBenchR) or no CapBenchB))) }
pred cap003729c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some capBenchS or some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap003729 { cap003729 iff cap003729c }
check CapBenchEquivalent_cap003729 for 4
