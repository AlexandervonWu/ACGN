sig Node {
	adj : set Node
}
pred inv1 {
all n,m: Node | m in n.adj => n in m.adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005172 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchR and some capBenchS) or no CapBenchA)) and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
pred cap005172c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchB) or some capBenchS)) or (not (inv1 and ((some capBenchR and some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005172 { cap005172 iff cap005172c }
check CapBenchEquivalent_cap005172 for 4
