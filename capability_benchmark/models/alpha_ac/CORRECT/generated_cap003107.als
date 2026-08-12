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

pred cap003107 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and some CapBenchB)) and ((some CapBenchA and no CapBenchB) or some capBenchR)) }
pred cap003107c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap003107 { cap003107 iff cap003107c }
check CapBenchEquivalent_cap003107 for 4
