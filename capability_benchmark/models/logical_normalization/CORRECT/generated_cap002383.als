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

pred cap002383 { no x: CapBenchA | (x->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap002383c { all x: CapBenchA | not (x->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002383 { cap002383 iff cap002383c }
check CapBenchEquivalent_cap002383 for 4
