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

pred cap002507 { not eventually ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap002507c { always (not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap002507 { cap002507 iff cap002507c }
check CapBenchEquivalent_cap002507 for 4
