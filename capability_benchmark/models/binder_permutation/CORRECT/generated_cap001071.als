sig Node {
	adj : set Node
}
pred inv8 {
all n: Node | n.adj.adj in n.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001071 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
pred cap001071c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap001071 { cap001071 iff cap001071c }
check CapBenchEquivalent_cap001071 for 4
