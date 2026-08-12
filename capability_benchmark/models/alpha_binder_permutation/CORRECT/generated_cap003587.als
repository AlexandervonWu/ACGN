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

pred cap003587 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) }
pred cap003587c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003587 { cap003587 iff cap003587c }
check CapBenchEquivalent_cap003587 for 4
