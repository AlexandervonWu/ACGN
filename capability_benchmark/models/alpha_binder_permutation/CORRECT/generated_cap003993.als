sig Node {
	adj : set Node
}
pred inv1 {
adj = ~adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003993 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap003993c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003993 { cap003993 iff cap003993c }
check CapBenchEquivalent_cap003993 for 4
