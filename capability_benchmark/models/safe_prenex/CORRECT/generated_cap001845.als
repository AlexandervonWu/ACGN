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

pred cap001845 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
pred cap001845c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001845 { cap001845 iff cap001845c }
check CapBenchEquivalent_cap001845 for 4
