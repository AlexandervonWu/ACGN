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

pred cap001704 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
pred cap001704c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001704 { cap001704 iff cap001704c }
check CapBenchEquivalent_cap001704 for 4
