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

pred cap003857 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchS or some capBenchR) or some capBenchS))) }
pred cap003857c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some capBenchS or some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap003857 { cap003857 iff cap003857c }
check CapBenchEquivalent_cap003857 for 4
