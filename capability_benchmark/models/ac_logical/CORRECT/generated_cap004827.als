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

pred cap004827 { not ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004827c { ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap004827 { cap004827 iff cap004827c }
check CapBenchEquivalent_cap004827 for 4
