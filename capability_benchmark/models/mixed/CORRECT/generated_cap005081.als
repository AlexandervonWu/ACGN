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

pred cap005081 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchB or no CapBenchA) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap005081c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) or (not (inv1 and ((some CapBenchB or no CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005081 { cap005081 iff cap005081c }
check CapBenchEquivalent_cap005081 for 4
