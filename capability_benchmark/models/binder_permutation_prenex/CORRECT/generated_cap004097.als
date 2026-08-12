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

pred cap004097 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
pred cap004097c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap004097 { cap004097 iff cap004097c }
check CapBenchEquivalent_cap004097 for 4
