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

pred cap001266 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
pred cap001266c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap001266 { cap001266 iff cap001266c }
check CapBenchEquivalent_cap001266 for 4
