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

pred cap005426 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) }
pred cap005426c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) or (not (inv6 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005426 { cap005426 iff cap005426c }
check CapBenchEquivalent_cap005426 for 4
