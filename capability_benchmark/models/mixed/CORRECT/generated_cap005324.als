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

pred cap005324 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((some capBenchR and some CapBenchA) or some capBenchS)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005324c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv6 and ((some capBenchR and some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap005324 { cap005324 iff cap005324c }
check CapBenchEquivalent_cap005324 for 4
