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

pred cap000852 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv8 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
pred cap000852c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv8 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap000852 { cap000852 iff cap000852c }
check CapBenchEquivalent_cap000852 for 4
