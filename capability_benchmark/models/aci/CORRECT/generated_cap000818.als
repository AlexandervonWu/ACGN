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

pred cap000818 { ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB) and ((some CapBenchB or no CapBenchB) or no CapBenchA)) }
pred cap000818c { (((some CapBenchB or no CapBenchB) or no CapBenchA) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000818 { cap000818 iff cap000818c }
check CapBenchEquivalent_cap000818 for 4
