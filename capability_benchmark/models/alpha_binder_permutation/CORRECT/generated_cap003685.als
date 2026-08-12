sig Node {
	adj : set Node
}
pred inv2 {
no iden & adj.adj
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

pred cap003685 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap003685c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003685 { cap003685 iff cap003685c }
check CapBenchEquivalent_cap003685 for 4
