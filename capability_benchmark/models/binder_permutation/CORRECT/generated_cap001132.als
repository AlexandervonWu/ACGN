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

pred cap001132 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or no CapBenchA))) }
pred cap001132c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap001132 { cap001132 iff cap001132c }
check CapBenchEquivalent_cap001132 for 4
