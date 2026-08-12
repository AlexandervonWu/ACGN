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

pred cap001644 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
pred cap001644c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001644 { cap001644 iff cap001644c }
check CapBenchEquivalent_cap001644 for 4
