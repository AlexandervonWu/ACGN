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

pred cap004810 { not ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004810c { ((not ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)))) }
assert CapBenchEquivalent_cap004810 { cap004810 iff cap004810c }
check CapBenchEquivalent_cap004810 for 4
