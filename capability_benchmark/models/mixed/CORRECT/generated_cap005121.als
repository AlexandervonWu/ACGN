sig Node {
	adj : set Node
}
pred inv5 {
all n: Node | not n->n in adj
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005121 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR))) }
pred cap005121c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) or (not (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005121 { cap005121 iff cap005121c }
check CapBenchEquivalent_cap005121 for 4
