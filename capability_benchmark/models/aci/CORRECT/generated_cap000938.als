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

pred cap000938 { ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or some capBenchR) and some CapBenchB) and ((some CapBenchB or no CapBenchA) or some capBenchR)) }
pred cap000938c { (((some CapBenchB or no CapBenchA) or some capBenchR) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or some capBenchR) and some CapBenchB)) }
assert CapBenchEquivalent_cap000938 { cap000938 iff cap000938c }
check CapBenchEquivalent_cap000938 for 4
