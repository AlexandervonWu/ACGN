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

pred cap003150 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) and ((no CapBenchB or some CapBenchA) and some capBenchS)) }
pred cap003150c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchA) and some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003150 { cap003150 iff cap003150c }
check CapBenchEquivalent_cap003150 for 4
