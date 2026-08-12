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

pred cap000068 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
pred cap000068c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv4 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000068 { cap000068 iff cap000068c }
check CapBenchEquivalent_cap000068 for 4
