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

pred cap004869 { not ((inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) }
pred cap004869c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) or (not (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap004869 { cap004869 iff cap004869c }
check CapBenchEquivalent_cap004869 for 4
