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

pred cap000525 { ((inv8 and ((some CapBenchB or no CapBenchB) or some CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap000525c { (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS) or (inv8 and ((some CapBenchB or no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000525 { cap000525 iff cap000525c }
check CapBenchEquivalent_cap000525 for 4
