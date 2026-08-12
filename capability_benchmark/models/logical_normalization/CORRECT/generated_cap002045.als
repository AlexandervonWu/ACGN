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

pred cap002045 { ((inv5 and ((some capBenchS or some capBenchS) or some CapBenchA)) iff ((no CapBenchA and no CapBenchB) and no CapBenchB)) }
pred cap002045c { (((not (inv5 and ((some capBenchS or some capBenchS) or some CapBenchA))) or ((no CapBenchA and no CapBenchB) and no CapBenchB)) and ((not ((no CapBenchA and no CapBenchB) and no CapBenchB)) or (inv5 and ((some capBenchS or some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap002045 { cap002045 iff cap002045c }
check CapBenchEquivalent_cap002045 for 4
