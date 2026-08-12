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

pred cap002852 { not (((inv4 and ((some CapBenchA and some capBenchR) or some capBenchS))) until (((some capBenchS or some CapBenchB) or some CapBenchA))) }
pred cap002852c { ((not (inv4 and ((some CapBenchA and some capBenchR) or some capBenchS))) releases (not ((some capBenchS or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002852 { cap002852 iff cap002852c }
check CapBenchEquivalent_cap002852 for 4
