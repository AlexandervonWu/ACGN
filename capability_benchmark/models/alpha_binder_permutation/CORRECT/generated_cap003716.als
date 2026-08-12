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

pred cap003716 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
pred cap003716c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003716 { cap003716 iff cap003716c }
check CapBenchEquivalent_cap003716 for 4
