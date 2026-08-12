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

pred cap002678 { not (((inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) until (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap002678c { ((not (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) releases (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002678 { cap002678 iff cap002678c }
check CapBenchEquivalent_cap002678 for 4
