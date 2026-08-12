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

pred cap005387 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap005387c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) or (not (inv3 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005387 { cap005387 iff cap005387c }
check CapBenchEquivalent_cap005387 for 4
