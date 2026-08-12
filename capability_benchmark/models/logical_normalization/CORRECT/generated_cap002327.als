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

pred cap002327 { ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) iff ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002327c { (((not (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) and ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) or (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap002327 { cap002327 iff cap002327c }
check CapBenchEquivalent_cap002327 for 4
