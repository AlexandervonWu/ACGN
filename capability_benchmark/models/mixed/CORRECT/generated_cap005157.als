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

pred cap005157 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchS or no CapBenchB) or no CapBenchA)) and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
pred cap005157c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchB) and some capBenchS)) or (not (inv1 and ((some capBenchS or no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005157 { cap005157 iff cap005157c }
check CapBenchEquivalent_cap005157 for 4
