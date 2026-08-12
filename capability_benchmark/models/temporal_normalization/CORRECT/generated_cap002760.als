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

pred cap002760 { not historically ((inv8 and ((some capBenchR and some CapBenchA) or some capBenchR))) }
pred cap002760c { once (not (inv8 and ((some capBenchR and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002760 { cap002760 iff cap002760c }
check CapBenchEquivalent_cap002760 for 4
