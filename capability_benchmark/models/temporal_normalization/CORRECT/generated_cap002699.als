sig Node {
	adj : set Node
}
pred inv3 {
all n:Node | n not in n.^adj
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002699 { not eventually ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap002699c { always (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002699 { cap002699 iff cap002699c }
check CapBenchEquivalent_cap002699 for 4
