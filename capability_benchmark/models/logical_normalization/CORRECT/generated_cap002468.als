sig Node {
	adj : set Node
}
pred inv2 {
all n1,n2:Node | n1->n2 in adj implies n2->n1 not in adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002468 { not not ((inv2 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002468c { (inv2 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002468 { cap002468 iff cap002468c }
check CapBenchEquivalent_cap002468 for 4
