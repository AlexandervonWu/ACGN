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

pred cap002161 { no x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
pred cap002161c { all x: CapBenchA | not (x->x in capBenchR and (inv6 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap002161 { cap002161 iff cap002161c }
check CapBenchEquivalent_cap002161 for 4
