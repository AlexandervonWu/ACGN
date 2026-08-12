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

pred cap003215 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB)) and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003215c { all renamed: CapBenchA | (((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003215 { cap003215 iff cap003215c }
check CapBenchEquivalent_cap003215 for 4
