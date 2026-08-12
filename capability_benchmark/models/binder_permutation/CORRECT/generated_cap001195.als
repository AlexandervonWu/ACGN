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

pred cap001195 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap001195c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap001195 { cap001195 iff cap001195c }
check CapBenchEquivalent_cap001195 for 4
