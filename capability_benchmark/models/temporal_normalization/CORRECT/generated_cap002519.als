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

pred cap002519 { not eventually ((inv2 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap002519c { always (not (inv2 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap002519 { cap002519 iff cap002519c }
check CapBenchEquivalent_cap002519 for 4
