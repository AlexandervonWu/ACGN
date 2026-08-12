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

pred cap002907 { not (((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) since (((some capBenchR and some CapBenchA) or some CapBenchB))) }
pred cap002907c { ((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((some capBenchR and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002907 { cap002907 iff cap002907c }
check CapBenchEquivalent_cap002907 for 4
