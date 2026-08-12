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

pred cap002092 { ((inv2 and ((some capBenchR and no CapBenchB) or some CapBenchB)) implies ((some CapBenchB or some CapBenchB) or some capBenchR)) }
pred cap002092c { ((not (inv2 and ((some capBenchR and no CapBenchB) or some CapBenchB))) or ((some CapBenchB or some CapBenchB) or some capBenchR)) }
assert CapBenchEquivalent_cap002092 { cap002092 iff cap002092c }
check CapBenchEquivalent_cap002092 for 4
