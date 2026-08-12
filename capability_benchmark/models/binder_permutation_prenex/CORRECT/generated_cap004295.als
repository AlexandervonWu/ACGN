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

pred cap004295 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR))) }
pred cap004295c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap004295 { cap004295 iff cap004295c }
check CapBenchEquivalent_cap004295 for 4
