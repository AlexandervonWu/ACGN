sig Node {
	adj : set Node
}
pred inv2 {
all n1,n2:Node | n1->n2 in adj implies n2->n1 not in adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004201 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
pred cap004201c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap004201 { cap004201 iff cap004201c }
check CapBenchEquivalent_cap004201 for 4
