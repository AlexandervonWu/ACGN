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

pred cap005199 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap005199c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005199 { cap005199 iff cap005199c }
check CapBenchEquivalent_cap005199 for 4
