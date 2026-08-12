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

pred cap000921 { ((inv6 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) or ((no CapBenchA and no CapBenchA) and some CapBenchB) or ((some CapBenchA and some CapBenchA) or some capBenchR)) }
pred cap000921c { (((no CapBenchA and no CapBenchA) and some CapBenchB) or ((some CapBenchA and some CapBenchA) or some capBenchR) or (inv6 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000921 { cap000921 iff cap000921c }
check CapBenchEquivalent_cap000921 for 4
