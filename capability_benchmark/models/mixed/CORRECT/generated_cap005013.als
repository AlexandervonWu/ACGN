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

pred cap005013 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchS or some CapBenchB) or some CapBenchA)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap005013c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) or (not (inv5 and ((some capBenchS or some CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005013 { cap005013 iff cap005013c }
check CapBenchEquivalent_cap005013 for 4
