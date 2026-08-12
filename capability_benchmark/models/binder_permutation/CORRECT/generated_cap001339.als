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

pred cap001339 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap001339c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap001339 { cap001339 iff cap001339c }
check CapBenchEquivalent_cap001339 for 4
