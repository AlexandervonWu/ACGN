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

pred cap002867 { not eventually ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) }
pred cap002867c { always (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap002867 { cap002867 iff cap002867c }
check CapBenchEquivalent_cap002867 for 4
