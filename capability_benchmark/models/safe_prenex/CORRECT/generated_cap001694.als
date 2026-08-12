sig Node {
	adj : set Node
}
pred inv8 {
all n1,n2,n3:Node | n1->n2 in adj and n2->n3 in adj implies n1->n3 in adj
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

pred cap001694 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
pred cap001694c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchA and some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001694 { cap001694 iff cap001694c }
check CapBenchEquivalent_cap001694 for 4
