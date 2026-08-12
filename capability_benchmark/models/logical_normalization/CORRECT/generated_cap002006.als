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

pred cap002006 { not not ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA))) }
pred cap002006c { (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) }
assert CapBenchEquivalent_cap002006 { cap002006 iff cap002006c }
check CapBenchEquivalent_cap002006 for 4
