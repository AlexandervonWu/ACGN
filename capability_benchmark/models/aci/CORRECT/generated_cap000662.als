sig Node {
	adj : set Node
}
pred inv5 {
all n: Node | not n->n in adj
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000662 { ((inv5 and ((no CapBenchA and some capBenchR) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000662c { (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and (inv5 and ((no CapBenchA and some capBenchR) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS)) }
assert CapBenchEquivalent_cap000662 { cap000662 iff cap000662c }
check CapBenchEquivalent_cap000662 for 4
