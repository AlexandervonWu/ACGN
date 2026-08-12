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

pred cap005015 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap005015c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) or (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005015 { cap005015 iff cap005015c }
check CapBenchEquivalent_cap005015 for 4
