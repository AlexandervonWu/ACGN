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

pred cap001895 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001895c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001895 { cap001895 iff cap001895c }
check CapBenchEquivalent_cap001895 for 4
