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

pred cap001729 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some capBenchS or some capBenchR) or no CapBenchB))) }
pred cap001729c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some capBenchS or some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001729 { cap001729 iff cap001729c }
check CapBenchEquivalent_cap001729 for 4
