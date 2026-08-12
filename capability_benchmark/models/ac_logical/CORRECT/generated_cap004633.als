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

pred cap004633 { not ((inv8 and ((some capBenchS or some CapBenchA) or no CapBenchA)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
pred cap004633c { ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) or (not (inv8 and ((some capBenchS or some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004633 { cap004633 iff cap004633c }
check CapBenchEquivalent_cap004633 for 4
