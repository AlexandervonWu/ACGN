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

pred cap002895 { not (((inv2 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) since (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap002895c { ((not (inv2 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002895 { cap002895 iff cap002895c }
check CapBenchEquivalent_cap002895 for 4
