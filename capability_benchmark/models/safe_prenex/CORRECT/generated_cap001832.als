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

pred cap001832 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
pred cap001832c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001832 { cap001832 iff cap001832c }
check CapBenchEquivalent_cap001832 for 4
