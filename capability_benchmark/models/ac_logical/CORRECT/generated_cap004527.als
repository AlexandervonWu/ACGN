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

pred cap004527 { not ((inv6 and ((no CapBenchB or no CapBenchB) and some CapBenchA)) and ((some CapBenchA and some CapBenchB) or no CapBenchB)) }
pred cap004527c { ((not ((some CapBenchA and some CapBenchB) or no CapBenchB)) or (not (inv6 and ((no CapBenchB or no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004527 { cap004527 iff cap004527c }
check CapBenchEquivalent_cap004527 for 4
