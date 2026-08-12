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

pred cap001331 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and some capBenchS))) }
pred cap001331c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap001331 { cap001331 iff cap001331c }
check CapBenchEquivalent_cap001331 for 4
