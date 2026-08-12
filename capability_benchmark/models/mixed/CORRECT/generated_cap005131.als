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

pred cap005131 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchB or some CapBenchA) and no CapBenchA)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap005131c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (not (inv3 and ((no CapBenchB or some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005131 { cap005131 iff cap005131c }
check CapBenchEquivalent_cap005131 for 4
