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

pred cap005258 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchA and some CapBenchA) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005258c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((no CapBenchA and some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap005258 { cap005258 iff cap005258c }
check CapBenchEquivalent_cap005258 for 4
