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

pred cap001852 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
pred cap001852c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap001852 { cap001852 iff cap001852c }
check CapBenchEquivalent_cap001852 for 4
