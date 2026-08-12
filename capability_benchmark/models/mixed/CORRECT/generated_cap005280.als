sig Node {
	adj : set Node
}
pred inv4 {
adj = (Node -> Node)
}

pred inv4c {
	adj = Node -> Node
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005280 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchA and no CapBenchB) or some capBenchR)) and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005280c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap005280 { cap005280 iff cap005280c }
check CapBenchEquivalent_cap005280 for 4
