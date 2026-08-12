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

pred cap001791 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((no CapBenchB or some capBenchR) and some capBenchR))) }
pred cap001791c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((no CapBenchB or some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap001791 { cap001791 iff cap001791c }
check CapBenchEquivalent_cap001791 for 4
