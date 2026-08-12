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

pred cap002043 { not ((inv6 and ((no CapBenchB or some capBenchS) and some CapBenchA)) and ((some CapBenchA and no CapBenchB) or no CapBenchB)) }
pred cap002043c { ((not (inv6 and ((no CapBenchB or some capBenchS) and some CapBenchA))) or (not ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002043 { cap002043 iff cap002043c }
check CapBenchEquivalent_cap002043 for 4
