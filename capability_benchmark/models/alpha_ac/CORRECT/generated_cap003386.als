sig Node {
	adj : set Node
}
pred inv5 {
all n: Node | not n->n in adj
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003386 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)) }
pred cap003386c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003386 { cap003386 iff cap003386c }
check CapBenchEquivalent_cap003386 for 4
