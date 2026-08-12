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

pred cap001236 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some capBenchR and some capBenchS) or no CapBenchB))) }
pred cap001236c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some capBenchR and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap001236 { cap001236 iff cap001236c }
check CapBenchEquivalent_cap001236 for 4
