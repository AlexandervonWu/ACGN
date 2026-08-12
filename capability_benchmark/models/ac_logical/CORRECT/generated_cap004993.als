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

pred cap004993 { not ((inv1 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and no CapBenchB) and no CapBenchA)) }
pred cap004993c { ((not ((no CapBenchA and no CapBenchB) and no CapBenchA)) or (not (inv1 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004993 { cap004993 iff cap004993c }
check CapBenchEquivalent_cap004993 for 4
