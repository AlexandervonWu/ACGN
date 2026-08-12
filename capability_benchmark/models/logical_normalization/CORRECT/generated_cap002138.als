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

pred cap002138 { not not ((inv6 and ((no CapBenchA and some CapBenchB) and no CapBenchA))) }
pred cap002138c { (inv6 and ((no CapBenchA and some CapBenchB) and no CapBenchA)) }
assert CapBenchEquivalent_cap002138 { cap002138 iff cap002138c }
check CapBenchEquivalent_cap002138 for 4
