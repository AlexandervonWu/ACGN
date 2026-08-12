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

pred cap001595 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) }
pred cap001595c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001595 { cap001595 iff cap001595c }
check CapBenchEquivalent_cap001595 for 4
