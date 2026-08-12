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

pred cap000192 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
pred cap000192c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000192 { cap000192 iff cap000192c }
check CapBenchEquivalent_cap000192 for 4
