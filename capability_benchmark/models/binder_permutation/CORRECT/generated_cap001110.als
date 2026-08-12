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

pred cap001110 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB))) }
pred cap001110c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap001110 { cap001110 iff cap001110c }
check CapBenchEquivalent_cap001110 for 4
