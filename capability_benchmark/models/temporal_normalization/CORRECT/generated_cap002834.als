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

pred cap002834 { not (((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) until (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002834c { ((not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) releases (not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002834 { cap002834 iff cap002834c }
check CapBenchEquivalent_cap002834 for 4
