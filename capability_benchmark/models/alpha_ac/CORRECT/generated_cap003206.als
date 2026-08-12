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

pred cap003206 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap003206c { all renamed: CapBenchA | (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003206 { cap003206 iff cap003206c }
check CapBenchEquivalent_cap003206 for 4
