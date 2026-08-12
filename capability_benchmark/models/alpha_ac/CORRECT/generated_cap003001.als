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

pred cap003001 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchB or some CapBenchA) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) }
pred cap003001c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003001 { cap003001 iff cap003001c }
check CapBenchEquivalent_cap003001 for 4
