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

pred cap000827 { (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) }
pred cap000827c { ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000827 { cap000827 iff cap000827c }
check CapBenchEquivalent_cap000827 for 4
