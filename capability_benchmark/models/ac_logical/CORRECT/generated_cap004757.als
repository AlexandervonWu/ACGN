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

pred cap004757 { not ((inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004757c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap004757 { cap004757 iff cap004757c }
check CapBenchEquivalent_cap004757 for 4
