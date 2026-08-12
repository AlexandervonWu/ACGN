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

pred cap001972 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001972c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001972 { cap001972 iff cap001972c }
check CapBenchEquivalent_cap001972 for 4
