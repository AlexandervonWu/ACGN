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

pred cap005420 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or no CapBenchA) or some CapBenchB))) }
pred cap005420c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchA) or some CapBenchB)) or (not (inv3 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005420 { cap005420 iff cap005420c }
check CapBenchEquivalent_cap005420 for 4
