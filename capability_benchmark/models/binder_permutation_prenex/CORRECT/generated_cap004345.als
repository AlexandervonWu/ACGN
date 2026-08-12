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

pred cap004345 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
pred cap004345c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap004345 { cap004345 iff cap004345c }
check CapBenchEquivalent_cap004345 for 4
