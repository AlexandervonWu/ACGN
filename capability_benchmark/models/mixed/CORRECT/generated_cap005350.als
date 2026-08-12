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

pred cap005350 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) and ((no CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap005350c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchB) and some CapBenchA)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap005350 { cap005350 iff cap005350c }
check CapBenchEquivalent_cap005350 for 4
