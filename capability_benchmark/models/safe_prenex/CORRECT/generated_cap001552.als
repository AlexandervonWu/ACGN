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

pred cap001552 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap001552c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001552 { cap001552 iff cap001552c }
check CapBenchEquivalent_cap001552 for 4
