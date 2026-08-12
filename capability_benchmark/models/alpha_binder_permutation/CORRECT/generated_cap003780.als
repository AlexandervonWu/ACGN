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

pred cap003780 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
pred cap003780c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003780 { cap003780 iff cap003780c }
check CapBenchEquivalent_cap003780 for 4
