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

pred cap001453 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001453c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001453 { cap001453 iff cap001453c }
check CapBenchEquivalent_cap001453 for 4
