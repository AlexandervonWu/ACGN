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

pred cap005228 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchR and some capBenchR) or no CapBenchB)) and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005228c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv5 and ((some capBenchR and some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005228 { cap005228 iff cap005228c }
check CapBenchEquivalent_cap005228 for 4
