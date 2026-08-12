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

pred cap002291 { ((inv1 and ((no CapBenchB or some capBenchR) and some capBenchR)) iff ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002291c { (((not (inv1 and ((no CapBenchB or some capBenchR) and some capBenchR))) or ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((not ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (inv1 and ((no CapBenchB or some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap002291 { cap002291 iff cap002291c }
check CapBenchEquivalent_cap002291 for 4
