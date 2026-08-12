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

pred cap004642 { not ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap004642c { ((not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) or (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004642 { cap004642 iff cap004642c }
check CapBenchEquivalent_cap004642 for 4
