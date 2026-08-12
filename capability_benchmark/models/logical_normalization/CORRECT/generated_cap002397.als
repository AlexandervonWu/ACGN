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

pred cap002397 { not ((inv4 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
pred cap002397c { ((not (inv4 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002397 { cap002397 iff cap002397c }
check CapBenchEquivalent_cap002397 for 4
