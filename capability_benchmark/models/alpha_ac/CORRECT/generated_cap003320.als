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

pred cap003320 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some CapBenchA and some CapBenchA) or some capBenchS)) and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003320c { all renamed: CapBenchA | (((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003320 { cap003320 iff cap003320c }
check CapBenchEquivalent_cap003320 for 4
