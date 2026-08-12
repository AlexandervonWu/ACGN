sig Node {
	adj : set Node
}
pred inv3 {
all n:Node | n not in n.^adj
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

pred cap003130 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and some CapBenchA) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) }
pred cap003130c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003130 { cap003130 iff cap003130c }
check CapBenchEquivalent_cap003130 for 4
