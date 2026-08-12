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

pred cap002564 { not (((inv6 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) until (((some capBenchS or some capBenchS) or no CapBenchB))) }
pred cap002564c { ((not (inv6 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) releases (not ((some capBenchS or some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap002564 { cap002564 iff cap002564c }
check CapBenchEquivalent_cap002564 for 4
