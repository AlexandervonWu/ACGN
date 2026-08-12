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

pred cap000461 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000461c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000461 { cap000461 iff cap000461c }
check CapBenchEquivalent_cap000461 for 4
