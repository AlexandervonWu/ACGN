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

pred cap002985 { not (((inv1 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) since (((no CapBenchA and no CapBenchA) and no CapBenchA))) }
pred cap002985c { ((not (inv1 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) triggered (not ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002985 { cap002985 iff cap002985c }
check CapBenchEquivalent_cap002985 for 4
