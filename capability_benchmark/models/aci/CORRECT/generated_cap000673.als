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

pred cap000673 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv4 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
pred cap000673c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv4 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap000673 { cap000673 iff cap000673c }
check CapBenchEquivalent_cap000673 for 4
