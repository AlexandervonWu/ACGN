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

pred cap005024 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and no CapBenchB) or some CapBenchA)) and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
pred cap005024c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchA) or no CapBenchB)) or (not (inv1 and ((some CapBenchA and no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005024 { cap005024 iff cap005024c }
check CapBenchEquivalent_cap005024 for 4
