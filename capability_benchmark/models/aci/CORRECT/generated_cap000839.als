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

pred cap000839 { (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchS)) }
pred cap000839c { ((inv5 and ((no CapBenchB or no CapBenchA) and some capBenchS)) or (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000839 { cap000839 iff cap000839c }
check CapBenchEquivalent_cap000839 for 4
