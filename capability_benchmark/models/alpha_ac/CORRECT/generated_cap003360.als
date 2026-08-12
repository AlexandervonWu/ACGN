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

pred cap003360 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchA and some capBenchS) or some capBenchS)) and ((some capBenchS or no CapBenchA) or some CapBenchA)) }
pred cap003360c { all renamed: CapBenchA | (((some capBenchS or no CapBenchA) or some CapBenchA) and renamed->renamed in capBenchR and (inv6 and ((some CapBenchA and some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap003360 { cap003360 iff cap003360c }
check CapBenchEquivalent_cap003360 for 4
