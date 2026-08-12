sig Node {
	adj : set Node
}
pred inv6 {
all a, b : Node | b in a.*(~adj + adj)
}

pred inv6c {
	all n:Node | Node = n.*(adj+~adj)
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003927 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003927c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003927 { cap003927 iff cap003927c }
check CapBenchEquivalent_cap003927 for 4
