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

pred cap003800 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some capBenchR))) }
pred cap003800c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap003800 { cap003800 iff cap003800c }
check CapBenchEquivalent_cap003800 for 4
