sig Node {
	adj : set Node
}
pred inv3 {
all n : Node | n not in n.^adj

no (^adj & iden)

iden - ^adj = iden
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002739 { not (((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) since (((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002739c { ((not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) triggered (not ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002739 { cap002739 iff cap002739c }
check CapBenchEquivalent_cap002739 for 4
