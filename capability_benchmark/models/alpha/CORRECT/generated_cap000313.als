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

pred cap000313 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap000313c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000313 { cap000313 iff cap000313c }
check CapBenchEquivalent_cap000313 for 4
