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

pred cap003471 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and some CapBenchA) or no CapBenchA)) }
pred cap003471c { all renamed: CapBenchA | (((some capBenchR and some CapBenchA) or no CapBenchA) and renamed->renamed in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003471 { cap003471 iff cap003471c }
check CapBenchEquivalent_cap003471 for 4
