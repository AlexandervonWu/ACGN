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

pred cap002067 { not ((inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap002067c { ((not (inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchB))) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap002067 { cap002067 iff cap002067c }
check CapBenchEquivalent_cap002067 for 4
