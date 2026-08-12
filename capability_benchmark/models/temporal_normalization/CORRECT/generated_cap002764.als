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

pred cap002764 { not always ((inv6 and ((some CapBenchA and some CapBenchB) or some capBenchR))) }
pred cap002764c { eventually (not (inv6 and ((some CapBenchA and some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002764 { cap002764 iff cap002764c }
check CapBenchEquivalent_cap002764 for 4
