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

pred cap000499 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap000499c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv6 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000499 { cap000499 iff cap000499c }
check CapBenchEquivalent_cap000499 for 4
