sig Node {
	adj : set Node
}
pred inv8 {
all n: Node | n.adj.adj in n.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000879 { ((inv8 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) or ((some CapBenchA and some capBenchS) or some CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)) }
pred cap000879c { (((some CapBenchA and some capBenchS) or some CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB) or (inv8 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000879 { cap000879 iff cap000879c }
check CapBenchEquivalent_cap000879 for 4
