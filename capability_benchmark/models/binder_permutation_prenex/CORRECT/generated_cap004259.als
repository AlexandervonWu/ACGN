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

pred cap004259 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap004259c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap004259 { cap004259 iff cap004259c }
check CapBenchEquivalent_cap004259 for 4
