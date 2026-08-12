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

pred cap000199 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap000199c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap000199 { cap000199 iff cap000199c }
check CapBenchEquivalent_cap000199 for 4
