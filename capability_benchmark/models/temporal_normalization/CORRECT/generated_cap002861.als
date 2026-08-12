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

pred cap002861 { not eventually ((inv6 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
pred cap002861c { always (not (inv6 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap002861 { cap002861 iff cap002861c }
check CapBenchEquivalent_cap002861 for 4
